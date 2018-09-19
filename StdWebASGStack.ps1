# Should be Dev, Stg or Prd per our config.psd1
Param(
    [parameter(Mandatory = $false)]
    [ValidateScript({Test-Path $_})]
    [String]
    $ConfigPath="$PSScriptRoot\Configs\Demo_VS_Config.psd1",
    [parameter(Mandatory = $false)]
    [String]
    $ConfigKey='dev'
)
Import-Module VaporShell -MinimumVersion 2.5.4

$conf = Import-VSTemplateConfig -Path $ConfigPath -Key $ConfigKey

$global:template = Initialize-Vaporshell -Description $conf.Description

$global:notificationConfig = @()

# Compile the tags into an array
$stackTags = $conf.Tags.Keys | ForEach-Object{
    Add-VSTag -Key $_ -Value $conf.Tags[$_]
}

. "$PSScriptRoot\StdResources\StdS3Bucket.ps1" -BucketName $conf.S3BucketName -Tags $stackTags |
ForEach-Object {
    $global:template.AddResource($_)
}

$userData = Add-UserData -File "$PSScriptRoot\UserData\$($conf.UserDataFile)" -UseJoin -Replace @{
    '#{stackname}' = $conf.StackName
    '#{region}' = $conf.AvailabilityZones[0] -replace ".$"
}

. "$PSScriptRoot\StdResources\StdAutoScalingGroup.ps1" -Tags $stackTags -BucketName $conf.S3BucketName -UserData $userData | ForEach-Object {
    $global:template.AddResource($_)
}

$global:template.ToYAML("$PSScriptRoot\Templates\$($conf.TemplateName)")

try {
    $global:template.Validate($conf.Environment)
    try {
        Get-VSStack -StackId $conf.StackName -ProfileName $conf.Environment -ErrorAction Stop
        New-VSChangeSet -TemplateBody $template -StackName $conf.StackName -ChangeSetName "$($conf.StackName)_$(Get-Date -Format "yyyy_MM_dd")" -ProfileName $conf.Environment -WhatIf
    }
    catch {
        New-VSStack -TemplateBody $template -StackName $conf.StackName -ProfileName $conf.Environment -WhatIf
    }
}
catch {
    Write-Error $_
}
