Param (
    [parameter(Mandatory = $false,Position = 0)]
    [ValidateSet('dev','stg','prd')]
    [String]
    $Environment
)

Import-Module VaporShell

$tempParams = @{
    Description = "My SQL Server RDS stack"
}
$template = Initialize-Vaporshell @tempParams

$newVaporResourceSplat = @{
    LogicalId  = "SecretsManagerCustomResource"
    Type       = "Custom::SecretsManager"
    Properties = @{
        ServiceToken = (Add-FnJoin "" @(
            'arn:aws:lambda:',
            (Add-FnRef $_AWSRegion),
            ':',
            (Add-FnRef $_AWSAccountId),
            ':function:SecretsManagerCustomResource'
        ))
        SecretId     = "$Environment/RDS"
        SecretKey    = 'RDSMasterPassword'
    }
}
$customResource = New-VaporResource @newVaporResourceSplat

$secretValue = Add-FnGetAtt $customResource 'Secret'
$myPublicIp = (Invoke-RestMethod "http://ipinfo.io/json").IP

$ingressParams = @{
    IpProtocol = 'tcp'
    ToPort     = '1433'
    FromPort   = '1433'
    CidrIp     = "$($myPublicIp)/32"
}
$securityGroupIngress = Add-VSEC2SecurityGroupIngress @ingressParams

$sgParams = @{
    LogicalId            = 'RDSSecurityGroup'
    GroupDescription     = 'Port 1433 access to RDS from local only'
    SecurityGroupIngress = $securityGroupIngress
}
$ec2SecurityGroup = New-VSEC2SecurityGroup @sgParams
$groupId = Add-FnGetAtt $ec2SecurityGroup 'GroupId'

$rdsParams = @{
    LogicalId            = "SqlServerExpress"
    MasterUsername       = 'rdsmaster'
    MasterUserPassword   = $secretValue
    VPCSecurityGroups    = $groupId
    PubliclyAccessible   = $true
    AllocatedStorage     = '25'
    EngineVersion        = "13.00.4451.0.v1"
    DBInstanceIdentifier = 'cf-sqlserver-ex-1'
    StorageType          = 'gp2'
    AvailabilityZone     = 'us-west-2a'
    MultiAZ              = $false
    Engine               = 'sqlserver-ex'
    DBInstanceClass      = 'db.t2.micro'
    DependsOn            = $ec2SecurityGroup
}
$rdsInstance = New-VSRDSDBInstance @rdsParams

$template.AddResource(
    $customResource,
    $ec2SecurityGroup,
    $rdsInstance
)

$newVaporOutputSplat = @{
    Value = $secretValue
    LogicalId = 'RDSMasterPassword'
}
$pwOutput = New-VaporOutput @newVaporOutputSplat
$template.AddOutput($pwOutput)

$newVSStackSplat = @{
    StackName    = "my-sql-express-stack"
    TemplateBody = $template
    ProfileName  = $Environment
    Verbose      = $true
    WhatIf       = $true
}
New-VSStack @newVSStackSplat
