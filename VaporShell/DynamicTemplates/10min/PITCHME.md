@snap[west]
<h3>Building Dynamic CloudFormation Templates with <a href='https://vaporshell.io/'>VaporShell</a></h3>
<hr>
<h4>Nate Ferrell<br><i>Sr. Systems & DevOps Engineer</i><br>AWS Certified Associate (<i>S.A., Dev, SysOps</i>)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[slack] @scrthq](https://aka.ms/PSSlack)</h5>
@snapend

---

### _What_ is VaporShell?

VaporShell is a PowerShell module designed to abstract AWS CloudFormation template building out of JSON or YAML while also providing the full range of PowerShell capabilites out-of-the-box

📦

---

### _Why_ VaporShell?

<img src="https://i.kym-cdn.com/entries/icons/facebook/000/022/978/yNlQWRM.jpg" width="400"/>

---

### _Why_ VaporShell?

VaporShell offers a number of benefits over creating templates in JSON or YAML, including...

@snap[text-08]
@ul
- Parameter validation and intellisense/tab completion ✔
- Familiar PowerShell syntax 🤔
- Dynamic template creation 💪
- Full stack management 🚀
- Native shared configuration support 🤝
- No longer having to work with JSON or YAML 😃
@ulend
@snapend

---

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

---

### Anything else?


Deploying to production? Let's add these as well:

@ul
- AutoScaling Group Notification Config to notify via SNS when the ASG scales up or down
- SNS Topic to push the ASG events to SQS so that production monitoring can add or remove hosts as needed
@ulend

---

The Stack

@code[powershell code-blend code-wrap](VaporShell/DynamicTemplates/StdWebASGStack.ps1)

@[1-10](Parameterize the script so we can set config file path and the environment we are deploying to)
@[11](Import the VaporShell module)
@[13](Import the config at path with specified key. This also automatically sets the `$global:VSConfig` variable so it's accessible from other scripts)
@[15](Initialize a template object at the global scope so it's also accessible from other scripts)
@[17-19](Compile the tags from the config into an array of CloudFormation-formatted Tags)
@[21-24](Add an S3 bucket for the front-end hosts to access resources from using a standard script)
@[26-29](Add our UserData for our Launch Configuration using the `Add-UserData` helper function, replacing strings in the script contents using the supplied hashtable)
@[31-34](Add in the components necessary for our web stack, including an ASG, ELB, Launch Config and EC2 Role...)
@[31-34](If we're deploying to production, we'll also add in our production monitoring resources)
@[36](We're going to export the template to file for backup purposes, so let's save it as YAML using the template name provided in the configuration by passing the file path to the `ToYAML` method)
@[38-56](Finally, let's validate the template and deploy it)
@[38-56](We'll add some more error handling around it so we don't deploy an invalid template that could just fail)
@[41](We'll check if the stack exists...)
@[42-48](If it does, we'll create a Change Set for that stack...)
@[51](Otherwise we'll deploy it as a new stack entirely)

---

The S3 Bucket script

@code[powershell code-noblend code-wrap](VaporShell/DynamicTemplates/StdResources/StdS3Bucket.ps1)

Simple S3 bucket script without any bells or whistles. Usually all you'll need.

---

The AutoScaling Group Script

@code[powershell code-noblend code-wrap](VaporShell/DynamicTemplates/StdResources/StdAutoScalingGroup.ps1)

This one is a _bit_ more complex due to how many additional resources are needed.

---

@snap[west]
<h3>Thank you for your time!</h3>
<hr>
<h4>Nate Ferrell<br><i>Sr. Systems & DevOps Engineer</i><br>AWS Certified Associate (<i>S.A., Dev, SysOps</i>)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[slack] @scrthq](https://aka.ms/PSSlack)</h5>
@snapend
