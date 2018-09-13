Param (
    [parameter(Mandatory = $false, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $LogicalId = 'StdS3Bucket',
    [parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $BucketName,
    [parameter(Mandatory = $true, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [object]
    $Tags
)
$resourceParams = @{
    LogicalId = $LogicalId
    AccessControl = 'BucketOwnerFullControl'
    BucketName = $BucketName
    Tags = $Tags
}
New-VSS3Bucket @resourceParams
