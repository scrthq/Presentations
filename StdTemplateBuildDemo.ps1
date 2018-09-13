#Requires -Modules @{ModuleName='Vaporshell';ModuleVersion='2.5.1'}
Param([String]$ConfigPath="$PSScriptRoot\Configs\Demo_VS_Config.psd1",[String]$ConfigKey='Prd') # Should be Dev, Stg or Prd per our config.psd1
$conf = Import-VSTemplateConfig -Path $ConfigPath -Key $ConfigKey # Import the config at path with specified key. This also sets the $global:VSConfig variable so it's accessible from other scripts in the same session.
$global:template = Initialize-Vaporshell -Description $conf.Description # Initialize a template object at the global scope
$global:notificationConfig = @() # Create a global array to house notification configs. This will be filled if environment is production
$stackTags = $conf.Tags.Keys|ForEach-Object{Add-VSTag -Key $_ -Value $conf.Tags[$_]} # Compile the tags into an array
. "$PSScriptRoot\StdResources\StdS3Bucket.ps1" -BucketName $conf.S3BucketName -Tags $stackTags | ForEach-Object { $global:template.AddResource($_) } # Add an S3 bucket for the hosts to access
if ($conf.Environment -eq 'prd') {
    foreach ($file in Get-ChildItem "$PSScriptRoot\StdResources\ProductionOnly" -Recurse -Filter "*.ps1") {
        . $file.FullName | ForEach-Object { $global:template.AddResource($_) }
    }
} # If our environment is production, add the host to monitoring tools and set appropriate notifications for ASG events
$userData = Add-UserData -File "$PSScriptRoot\UserData\$($conf.UserDataFile)" -UseJoin -Replace @{
    '#{stackname}' = $conf.StackName
    '#{region}' = $conf.AvailabilityZones[0] -replace ".$"
} # Create UserData from existing PowerShell script file, replacing container values per the supplied hashtable
. "$PSScriptRoot\StdResources\StdAutoScalingGroup.ps1" -Tags $stackTags -BucketName $conf.S3BucketName -UserData $userData | ForEach-Object { $global:template.AddResource($_) } # Add ASG, ELB, etc to template

$global:template.ToYAML("$PSScriptRoot\Templates\$($conf.TemplateName)",$true) # Export template to YAML with cfn-flip
$global:template.Validate('default',$true) # Validate the template's syntax using the AWS .NET SDK
