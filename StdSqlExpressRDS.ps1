Param (
    [parameter(Mandatory = $false,Position = 0)]
    [ValidateSet('dev','stg','prd')]
    [String]
    $Environment
)
Import-Module VaporShell
$template = Initialize-Vaporshell -Description "My SQL Server RDS stack"

$newVaporResourceSplat = @{
    LogicalId  = "SecretsManagerCustomResource"
    Type       = "Custom::SecretsManager"
    Properties = @{
        ServiceToken = (Add-FnJoin -Delimiter "" -ListOfValues @(
                'arn:aws:lambda:',
                (Add-FnRef $_AWSRegion),
                ':',
                (Add-FnRef $_AWSAccountId),
                ':function:SecretsManagerCustomResource'
            ))
        SecretId     = 'development/RDS'
        SecretKey    = 'RDSMasterPassword'
    }
}
$customResource = New-VaporResource @newVaporResourceSplat

$secretValue = Add-FnGetAtt $customResource -AttributeName 'Secret'
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

$rdsParams = @{
    AllocatedStorage     = '25'
    MasterUserPassword   = $secretValue
    LogicalId            = "SqlServerExpress"
    EngineVersion        = "13.00.4451.0.v1"
    DBInstanceIdentifier = 'cf-sqlserver-ex-1'
    PubliclyAccessible   = $true
    VPCSecurityGroups    = (Add-FnGetAtt $ec2SecurityGroup 'GroupId')
    MasterUsername       = 'rdsmaster'
    StorageType          = 'gp2'
    DependsOn            = $ec2SecurityGroup
    AvailabilityZone     = 'us-west-2a'
    MultiAZ              = $false
    Engine               = 'sqlserver-ex'
    DBInstanceClass      = 'db.t2.micro'
}
$rdsInstance = New-VSRDSDBInstance @rdsParams

$template.AddResource(
    $customResource,
    $ec2SecurityGroup,
    $rdsInstance
)

$pwOutput = New-VaporOutput -LogicalId RDSMasterPassword -Value $secretValue
$template.AddOutput($pwOutput)

$newVSStackSplat = @{
    StackName    = "my-sql-express-stack"
    TemplateBody = $template
    ProfileName  = $Environment
    Verbose      = $true
}
New-VSStack @newVSStackSplat
