---?color=#282C34

### Building Dynamic CloudFormation Templates with VaporShell<br><br>
##### Nate Ferrell<br>Systems & DevOps Engineer
###### [@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[github] @scrthq](https://github.com/scrthq)


---?code=StdSqlExpressRDS.ps1&lang=powershell&color=#282C34
@[1](Import the VaporShell module)
@[2-4](Initialize the template object)
@[7-21](Add the custom resource details that will fetch the RDS Master Password from Secrets Manager)
@[22](Store the call to `Fn::GetAtt` to remove repetitive code)
@[24-31](Add an ingress rule for the Security Group to allow access from local only...)
@[28-29](...using a quick call to `ipinfo.io` to get our current public IP for that ingress rule :wink:)
@[33-38](Adding the Security Group and attaching the ingress rule we just created)
