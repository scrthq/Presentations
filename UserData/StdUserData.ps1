param(
	$stackname = '#{stackname}',
	$region = '#{region}'
)
$flagsDir = "C:\Flags"
$cfnSignalFlag = Join-Path $flagsDir "cfn-signal.flag"
if (!(Test-Path $flagsDir)) {
	New-Item -Path $flagsDir -ItemType Directory
}
$name = "WIN-$((Get-NetAdapter | Select-Object -First 1).MacAddress.Replace('-','').SubString(1,11))"
if ($env:COMPUTERNAME -ne $name) {
	Rename-Computer $name -Force -Restart
}
elseif ($env:USERDOMAIN -eq $env:COMPUTERNAME) {

}
elseif (!(Test-Path $cfnSignalFlag)) {
	& cfn-signal.exe -e 0 --resource AutoScalingGroup --stack $stackname --region $region
	New-Item -Path $cfnSignalFlag -ItemType File
}
