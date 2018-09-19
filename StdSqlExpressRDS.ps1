Import-Module VaporShell
$template = Initialize-Vaporshell -Description "My SQL Server RDS stack"

$customResource = New-VaporResource -LogicalId "SecretsManagerCustomResource" -Type "Custom::SecretsManager" -Properties @{
    ServiceToken = (Add-FnJoin -Delimiter "" -ListOfValues 'arn:aws:lambda:',(Add-FnRef $_AWSRegion),':',(Add-FnRef $_AWSAccountId),':function:SecretsManagerCustomResource')
    SecretId = 'development/RDS'
    SecretKey = 'RDSMasterPassword'
}
$secretValue = Add-FnGetAtt $customResource -AttributeName 'Secret'

$securityGroupIngress = Add-VSEC2SecurityGroupIngress -CidrIp "$(Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty IP)/32" -FromPort '1433' -ToPort '1433' -IpProtocol 'tcp'
$ec2SecurityGroup = New-VSEC2SecurityGroup -LogicalId 'RDSSecurityGroup' -GroupDescription 'Port 1433 access to RDS from local only' -SecurityGroupIngress $securityGroupIngress

$rdsInstance = New-VSRDSDBInstance -LogicalId "SqlServerExpress" -MasterUsername 'rdsmaster' -MasterUserPassword $secretValue -DBInstanceClass 'db.t2.micro' -PubliclyAccessible $true -Engine 'sqlserver-ex' -MultiAZ $false -StorageType 'gp2' -EngineVersion "13.00.4451.0.v1" -DBInstanceIdentifier 'cf-sqlserver-ex-1' -AllocatedStorage '25' -AvailabilityZone 'us-west-2a' -VPCSecurityGroups (Add-FnGetAtt $ec2SecurityGroup 'GroupId') -DependsOn $ec2SecurityGroup

$template.AddResource($customResource,$ec2SecurityGroup,$rdsInstance)
$template.AddOutput(
    (New-VaporOutput -LogicalId RDSMasterPassword -Value $secretValue)
)

New-VSStack -TemplateBody $template -StackName "my-sql-express-stack" -ProfileName dev -WhatIf