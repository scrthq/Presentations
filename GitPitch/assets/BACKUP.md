<!--
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
-->