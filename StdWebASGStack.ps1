#Requires -Modules @{ModuleName='Vaporshell';ModuleVersion='2.5.4'}

# Should be Dev, Stg or Prd per our config.psd1
Param([String]$ConfigPath="$PSScriptRoot\Configs\Demo_VS_Config.psd1",[String]$ConfigKey='Dev')

# Import the config at path with specified key. This also sets the $global:VSConfig variable so it's accessible from other scripts in the same session.
$conf = Import-VSTemplateConfig -Path $ConfigPath -Key $ConfigKey

# Initialize a template object at the global scope
$global:template = Initialize-Vaporshell -Description $conf.Description

# Create a global array to house notification configs. This will be filled if environment is production
$global:notificationConfig = @()

# Compile the tags into an array
$stackTags = $conf.Tags.Keys | ForEach-Object{
    Add-VSTag -Key $_ -Value $conf.Tags[$_]
}

# Add an S3 bucket for the front-end hosts to access resources from
. "$PSScriptRoot\StdResources\StdS3Bucket.ps1" -BucketName $conf.S3BucketName -Tags $stackTags | ForEach-Object {
    $global:template.AddResource($_)
}

# Create UserData from existing PowerShell script file, replacing container values per the supplied hashtable
$userData = Add-UserData -File "$PSScriptRoot\UserData\$($conf.UserDataFile)" -UseJoin -Replace @{
    '#{stackname}' = $conf.StackName
    '#{region}' = $conf.AvailabilityZones[0] -replace ".$"
}

# Add an AutoScalingGroup, ELB, Launch Config, & EC2 role.
# If this is the production environment, let's also add our production monitoring configuration.
. "$PSScriptRoot\StdResources\StdAutoScalingGroup.ps1" -Tags $stackTags -BucketName $conf.S3BucketName -UserData $userData | ForEach-Object {
    $global:template.AddResource($_)
}

# Export template to YAML via cfn-flip
$global:template.ToYAML("$PSScriptRoot\Templates\$($conf.TemplateName)")

# Validate the template's syntax using the AWS .NET SDK using credentials from the 'default' profile on the AWS Shared Credentials file (~\.aws\credentials)
$global:template.Validate($conf.Environment,$true)

# Template build, now let's deploy it.
# If the stack already exists, we'll create a change set instead for review
try {
    Get-VSStack -StackId $conf.StackName -ProfileName $conf.Environment -ErrorAction Stop
    New-VSChangeSet -TemplateBody $template -StackName $conf.StackName -ChangeSetName "$($conf.StackName)_$(Get-Date -Format "yyyy_MM_dd")" -ProfileName $conf.Environment -WhatIf
}
catch {
    New-VSStack -TemplateBody $template -StackName $conf.StackName -ProfileName $conf.Environment -WhatIf
}
