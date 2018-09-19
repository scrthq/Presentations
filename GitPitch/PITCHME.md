---?color=#282C34

@snap[west]
<h3>Building Dynamic CloudFormation Templates with VaporShell</h3>
<hr>
<h4>Nate Ferrell<br><i>Systems & DevOps Engineer</i></h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)</h5>
@snapend

---?code=StdSqlExpressRDS.ps1&lang=powershell&color=#282C34
@[1](Import the VaporShell module)
@[2-5](Initialize the template object with a useful description for the stack)
@[7-22](Create the custom resource that will fetch the RDS Master Password from AWS Secrets Manager)
@[23](Store the call to `Fn::GetAtt` to remove repetitive code)
@[25-32](Create an ingress rule for the Security Group to allow access from local only...)
@[29-30](...using a quick call to `ipinfo.io` to get our current public IP for that ingress rule 👍)
@[34-40](Create the Security Group and attach the ingress rule we just created)
@[42-58](Create the RDS instance)
@[60-64](Add the created resources to the template)
@[66-70](Create an output to allow us to view the fetched RDS Master Password after the stack is created...)
@[66-70](...yeah, don't ever do something like this in real life! ☠️)
@[71](Add the output to the template)
@[73-74](Cast the template to YAML and pause to inspect)
