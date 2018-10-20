---?color=#282C34

@snap[west]
<h3>Building Dynamic CloudFormation Templates with <a href='https://vaporshell.io/'>VaporShell</a></h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i><br>AWS Certified Associate (<i>S.A., Dev, SysOps</i>)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[slack] @scrthq](http://slack.poshcode.org/)</h5>
@snapend

---?color=#282C34

### _What_ is VaporShell?

VaporShell is a PowerShell module designed to abstract AWS CloudFormation template building out of JSON or YAML while also providing the full range of PowerShell capabilites out-of-the-box

📦

---?color=#282C34

### _Why_ VaporShell?

<img src="https://i.kym-cdn.com/entries/icons/facebook/000/022/978/yNlQWRM.jpg" width="400"/>

---?color=#282C34

### _Why_ VaporShell?

VaporShell offers a number of benefits over creating templates in JSON or YAML, including...

@ul
- Parameter validation and intellisense/tab completion ✔
- Familiar PowerShell syntax 🤔
- Dynamic template creation 💪
- Full stack management 🚀
- Native shared configuration support 🤝
- No longer having to work with JSON or YAML 😃
@ulend

---?color=#282C34

### The Single Script Approach

@ul
- The quick and easy way to get going with stack creation
- Everything going into the stack is on the same ps1 file
- Perfect for unique deployment scenarios or quick stack creation
  @ulend

---?color=#282C34

### Single Script Resources

@ul
- RDS Instance
- Security group
- Custom Resource to retrieve secrets from AWS Secrets Manager
@ulend

---?code=SqlExpressRDS.ps1&lang=powershell&color=#282C34&title=The Single Script Stack

@[1-6](Parameterize the script so we can set the environment we are deploying to)
@[8](Import the VaporShell module)
@[10-13](Initialize the template object with a useful description for the stack)
@[15-30](Create the custom resource that will fetch the RDS Master Password from AWS Secrets Manager...)
@[26](...using the `$Environment` parameter to set the SecretId)
@[32](Call `Fn::GetAtt` to retrieve the `Secret` attribute of the custom resource)
@[33-38](Set our CIDR block for our SQL ingress rule...)
@[33-35](...if we're deploying to `dev`, get our current public IP...)
@[36-38](...otherwise, set it to the company's local CIDR block)
@[40-46](Create our ingress rule using TCP 1433 and the CIDR)
@[48-53](Create the Security Group and attach the ingress rule we just created...)
@[54](...and store the GroupId in a variable to use next)
@[56-74](Create the RDS instance...)
@[61-63](...and only set it as PubliclyAccessible if we're deploying to dev)
@[76-80](Add the created resources to the template)
@[82-89](If we're in `dev`, let's also add an output containing the RDS Master Password to the template)
@[82-89](DEMO ONLY! Don't ever output something sensitive like this in real life! ☠️)
@[91-93](Validate the template syntax using the AWS CloudFormation SDK, cast the template to YAML, then pause to inspect it in the console)
@[95-102](Finally, deploy the template as a new CloudFormation stack!)

---?color=#282C34

### Single Script - Pros

@ul
- Quick to get going
- Easy to visually confirm everything being added to the stack
- Simple to manage with even large scripts
@ulend

---?color=#282C34

### Single Script - Cons

@ul
- Repetitive code with similar stack builds
- Copy/paste nightmares when small things change
@ulend

---?color=#282C34

## So, how do we approach this _better_?

---?color=#282C34

### With modular, reusable scripts!

<img src="https://static.dezeen.com/uploads/2016/06/move-wear-link-play-seymour-powell-modular-tech-design-product-concept-open-hardware-additional_dezeen_2.2.gif" width="400"/>

---?color=#282C34

### The Modular Script Approach

@ul
- All variable values extracted into a configuration psd1
- Common resources and resource groups stored in standardized scripts
- Perfect for resources that are standardized, i.e. web/API server stacks
@ulend

---?color=#282C34

### Modular Stack Resources

@ul
- S3 Bucket
- S3 Bucket Policy
- EC2 Role
- Instance Profile
- Launch Configuration
- AutoScaling Group
- Elastic Load Balancer
- Custom Resource to add a CNAME to DNS for the ELB
@ulend

---?color=#282C34

### Anything else?


Deploying to production? Let's add these as well:

@ul
- AutoScaling Group Notification Config to notify via SNS when the ASG scales up or down
- SNS Topic to push the ASG events to SQS so that production monitoring can add or remove hosts as needed
@ulend

---?code=StdWebASGStack.ps1&lang=powershell&color=#282C34&title=The Standardized Stack

@[1-10](Parameterize the script so we can set config file path and the environment we are deploying to)
@[11](Import the VaporShell module)
@[13](Import the config at path with specified key. This also automatically sets the `$global:VSConfig` variable so it's accessible from other scripts in the same session)
@[15](Initialize a template object at the global scope so it's also accessible from other scripts)
@[17-19](Compile the tags from the config into an array of CloudFormation-formatted Tags)
@[21-24](Add an S3 bucket for the front-end hosts to access resources from using a standard script)
@[26-29](Add our UserData for our Launch Configuration using the `Add-UserData` helper function, replacing strings in the script contents using the supplied hashtable)
@[31-34](Add in the components necessary for our web stack, including an ASG, ELB, Launch Config and EC2 Role...)
@[31-34](If we're deploying to production, we'll also add in our production monitoring resources)
@[36](We're going to export the template to file for backup purposes, so let's save it as YAML using the template name provided in the configuration by passing the file path to the `ToYAML` method)
@[38-50](Finally, let's validate the template and deploy it)
@[38-50](We'll add some more error handling around it so we don't deploy an invalid template that could just fail)
@[41](We'll check if the stack exists...)
@[42](If it does, we'll create a Change Set for that stack...)
@[45](Otherwise we'll deploy it as a new stack entirely)

---?code=Configs/Demo_VS_Config.psd1&lang=powershell&color=#282C34&title=The shared PSD1 config

This is the configuration file containing the variable values for each environment.

---?code=StdResources/StdS3Bucket.ps1&lang=powershell&color=#282C34&title=The S3 Bucket script

Simple S3 bucket script without any bells or whistles. Usually all you'll need.

---?code=StdResources/StdAutoScalingGroup.ps1&lang=powershell&color=#282C34&title=The AutoScalingGroup script

This one is a _bit_ more complex due to how many additional resources are needed for a standard AutoScalingGroup.

---?color=#282C34


### Modular Stack - Pros

@ul
- Enables repeatable, reliable infrastructure builds when working with semi-standard stacks
- Shortens primary script down to just the connecting components
- Shortened script also increases visibility towards the unique components of the target stack
@ulend

---?color=#282C34

### Modular Stack - Cons

@ul
- Requires an understanding of what is "standardized" in your environment
- "Speed-to-market" can be slower as it takes more thought designing reusable components compared to building directly
@ulend

---?color=#282C34

@snap[west]
<h3>Thank you for your time!</h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i><br>AWS Certified Associate (All 3)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[slack] @scrthq](http://slack.poshcode.org/)</h5>
@snapend
