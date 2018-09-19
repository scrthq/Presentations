---?color=#282C34

@snap[west]
<h3>Building Dynamic CloudFormation Templates with VaporShell</h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i></h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)</h5>
@snapend

---

### What is VaporShell?

VaporShell is a PowerShell module designed to abstract AWS CloudFormation template building out of JSON...

@ul
- to abstract
@ulend

---?code=StdSqlExpressRDS.ps1&lang=powershell&color=#282C34&title=Creating a stack without a config file
@[1-6](Parameterize the script )
@[7](Import the VaporShell module)
@[8-11](Initialize the template object with a useful description for the stack)
@[13-28](Create the custom resource that will fetch the RDS Master Password from AWS Secrets Manager...)
@[22](...using the `$Environment` parameter to set the SecretId)
@[29](Store the call to `Fn::GetAtt` to avoid repetitive code)
@[31-39](Let's set our CIDR range based on the `$Environment` we're deploying to)
@[31-39](Create an ingress rule for the Security Group to allow access from local only...)
@[29-30](...using a quick call to `ipinfo.io` to get our current public IP for that ingress rule 👍)
@[34-40](Create the Security Group and attach the ingress rule we just created)
@[42-58](Create the RDS instance)
@[60-64](Add the created resources to the template)
@[66-70](Create an output to allow us to view the fetched RDS Master Password after the stack is created...)
@[66-70](...yeah, don't ever do something like this in real life! ☠️)
@[71](Add the output to the template)
@[73-75](Cast the template to YAML, validate the template syntax using the AWS CloudFormation SDK then pause to inspect it in the console)
@[77-83](Finally, deploy the template as a new CloudFormation stack!)
