Import-Module VaporShell
$initializeVaporshellSplat = @{
    Description = "My SQL Server RDS stack"
}
$template = Initialize-Vaporshell @initializeVaporshellSplat

$newVaporResourceSplat = @{
    Properties = @{
        ServiceToken = (Add-FnJoin "" @(
            'arn:aws:lambda:'
            (Add-FnRef $_AWSRegion)
            ':'
            (Add-FnRef $_AWSAccountId)
            ':function:SecretsManagerCustomResource')
        )
        SecretId = 'development/RDS'
        SecretKey = 'RDSMasterPassword'
    }
    Type = "Custom::SecretsManager"
    LogicalId = "SecretsManagerCustomResource"
}
$customResource = New-VaporResource @newVaporResourceSplat
$secretValue = Add-FnGetAtt $customResource 'Secret'

$ec2SGIngressParams = @{
    IpProtocol = 'tcp'
    ToPort = '1433'
    FromPort = '1433'
    CidrIp = "$(Invoke-RestMethod http://ipinfo.io/json |
                Select-Object -ExpandProperty IP)/32"
}
$sgIngress = Add-VSEC2SecurityGroupIngress @ec2SGIngressParams

$ec2SGParams = @{
    GroupDescription = 'Port 1433 access to RDS from local'
    SecurityGroupIngress = $sgIngress
    LogicalId = 'RDSSecurityGroup'
}
$ec2SecurityGroup = New-VSEC2SecurityGroup @ec2SGParams
$vpcGroupId = Add-FnGetAtt $ec2SecurityGroup 'GroupId'

$newVSRDSDBInstanceSplat = @{
    AllocatedStorage = '25'
    MasterUserPassword = $secretValue
    LogicalId = "SqlServerExpress"
    EngineVersion = "13.00.4451.0.v1"
    DBInstanceIdentifier = 'cf-sqlserver-ex-1'
    PubliclyAccessible = $true
    VPCSecurityGroups = $vpcGroupId
    MasterUsername = 'rdsmaster'
    StorageType = 'gp2'
    DependsOn = $ec2SecurityGroup
    AvailabilityZone = 'us-west-2a'
    MultiAZ = $false
    Engine = 'sqlserver-ex'
    DBInstanceClass = 'db.t2.micro'
}
$rdsInstance = New-VSRDSDBInstance @newVSRDSDBInstanceSplat

$template.AddResource(
    $customResource,
    $ec2SecurityGroup,
    $rdsInstance
)

$newVaporOutputSplat = @{
    Value = $secretValue
    LogicalId = 'RDSMasterPassword'
}
$output = New-VaporOutput @newVaporOutputSplat
$template.AddOutput($output)

$template.ToYAML()
Read-Host "Press [enter] to continue"

$template.Validate('default')

$newVSStackSplat = @{
    TemplateBody = $template
    StackName = "my-sql-express-stack"
    ProfileName = 'default'
    WhatIf = $true
}
New-VSStack @newVSStackSplat
