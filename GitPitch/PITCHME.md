---?color=#282C34

@snap[west]
<h3>Building Dynamic CloudFormation Templates with <a href='https://vaporshell.io/'>VaporShell</a></h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i></h4>
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

@transition[none]

### _Why_ VaporShell?

VaporShell offers a number of benefits over creating templates in JSON or YAML, including...

@ul
- Parameter validation and intellisense/tab completion ✔️
- Familiar PowerShell syntax 🤔
- Dynamic template creation 💪
- Full stack management 🚀
- Native shared configuration support 🤝
- No longer having to work with JSON or YAML 😃
@ulend

---?color=#282C34

### What are we building today?

We'll be building 2 CloudFormation templates:

@ol
- A single-script RDS stack useful for something purpose-built
- A generic web stack using shared, standardized resources that we'll fill out using a configuration file
@olend

---?code=StdSqlExpressRDS.ps1&lang=powershell&color=#282C34&title=Creating a single-script stack

@[1-6](Parameterize the script so we can set the environment we are deploying to)
@[7](Import the VaporShell module)
@[8-11](Initialize the template object with a useful description for the stack)
@[13-28](Create the custom resource that will fetch the RDS Master Password from AWS Secrets Manager...)
@[22](...using the `$Environment` parameter to set the SecretId)
@[29](Store the call to `Fn::GetAtt` to avoid repetitive code)
@[31-45](Create an ingress rule for the Security Group to allow access from the specified CIDR)
@[36-39](If we're in `dev`, allow access from our current public IP using a quick call to `ipinfo.io` 👍...)
@[40-42](...otherwise, let's lock it down to our private VPC CIDR block)
@[47-52](Create the Security Group and attach the ingress rule we just created...)
@[53](...and store the GroupId in a variable to use next)
@[55-78](Create the RDS instance...)
@[61-68](...and only set it as PubliclyAccessible if we're deploying to dev)
@[80-84](Add the created resources to the template)
@[86-93](If we're deploying to `dev`, let's also create an output to allow us to view the fetched RDS Master Password after the stack is created and add that to the template)
@[86-93](DEMO ONLY! Don't ever output something sensitive like this in real life! ☠️)
@[95-97](Cast the template to YAML, validate the template syntax using the AWS CloudFormation SDK then pause to inspect it in the console)
@[99-105](Finally, deploy the template as a new CloudFormation stack!)

---?code=StdWebASGStack.ps1&lang=powershell&color=#282C34&title=Creating a stack using standardized resources and a configuration file

@[1-10](Parameterize the script so we can set config file path and the environment we are deploying to)
@[11](Import the VaporShell module)
@[13](Import the config at path with specified key. This also automatically sets the `$global:VSConfig` variable so it's accessible from other scripts in the same session)
@[15](Initialize a template object at the global scope so it's also accessible from other scripts)
@[17-19](Compile the tags from the config into an array of CloudFormation-formatted Tags)
@[21-24](Add an S3 bucket for the front-end hosts to access resources from using a standard script)
@[26-29](Add our UserData for our Launch Configuration using the `Add-UserData` helper function, replacing strings in the script contents using the supplied hashtable)
@[31-33](Add in the components necessary for our web stack, including an ASG, ELB, Launch Config and EC2 Role...)
@[31-33](If we're deploying to production, we'll also add in our production monitoring resources)
@[35](We're going to export the template to file for backup purposes, so let's save it as YAML using the template name provided in the configuration by passing the file path to the `ToYAML` method)
@[37-49](Finally, let's validate the template and deploy it)
@[37-49](This time, we'll add some more error handling around it so we don't deploy an invalid template that could just fail)
@[40](We'll check if the stack exists...)
@[41](If it does, we'll create a Change Set for that stack...)
@[44](Otherwise we'll deploy it as a new stack entirely)

---?code=StdResources/StdS3Bucket.ps1&lang=powershell&color=#282C34&title=The S3 Bucket script

Simple S3 bucket script without any bells or whistles. Usually all you'll need.

---?code=StdResources/StdAutoScalingGroup.ps1&lang=powershell&color=#282C34&title=The AutoScalingGroup script

This one is a bit more complex due to how many additional resources are needed for a standard AutoScalingGroup

---?color=#282C34

@snap[west]
<h3>Thank you for your time!</h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i></h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[slack] @scrthq](http://slack.poshcode.org/)</h5>
@snapend
