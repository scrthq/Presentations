---?color=#282C34

@snap[west]
<h3>Building Dynamic CloudFormation Templates with <a href='https://vaporshell.io/'>VaporShell</a></h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i><br>AWS Certified Associate (All 3)</h4>
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
- Parameter validation and intellisense/tab completion ✔️
- Familiar PowerShell syntax 🤔
- Dynamic template creation 💪
- Full stack management 🚀
- Native shared configuration support 🤝
- No longer having to work with JSON or YAML 😃
@ulend

---?color=#282C34

### What are we building today?

We'll be building a CloudFormation stack containing the following resources:

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

---?code=StdWebASGStack.ps1&lang=powershell&color=#282C34

@snap[north]
<h3>The Stack</h3>
@snapend

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

This one is a _bit_ more complex due to how many additional resources are needed for a standard AutoScalingGroup.

---?color=#282C34

@snap[west]
<h3>Thank you for your time!</h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i><br>AWS Certified Associate (All 3)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[slack] @scrthq](http://slack.poshcode.org/)</h5>
@snapend
