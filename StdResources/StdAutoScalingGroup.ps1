Param (
    [parameter(Mandatory = $false, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $BucketName,
    [parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [object]
    $Tags,
    [parameter(Mandatory = $false)]
    [object]
    $UserData
)
$policyParams = @{
    PolicyName = 'DefaultEC2Policy'
    PolicyDocument = @{
        Statement = @(
            @{
                # Allow CloudWatch logging
                Effect = "Allow"
                Action = @(
                    "logs:CreateLogStream"
                    "logs:DescribeLogGroups"
                    "logs:DescribeLogStreams"
                    "logs:PutLogEvents"
                )
                Resource = @("*")
            },
            @{
                # Allow EC2 instances in ASG to retrieve the stack's tags
                Effect = "Allow"
                Action = @(
                    "ec2:CreateTags"
                    "ec2:DeleteTags"
                    "ec2:DescribeTags"
                )
                Condition = @{
                    StringEquals = @{
                        'ec2:ResourceTag/aws:cloudformation:stack-name' = $Global:VSConfig.StackName + "-" + $Global:VSConfig.Environment
                    }
                }
                Resource = @("*")
            }
        )
    }
}
if ($PSBoundParameters.Keys -contains 'BucketName') {
    # If a BucketName or list of BucketNames is specified, add permission to Get and List bucket and bucket objects
    $bucketResources = foreach ($bucket in $PSBoundParameters['BucketName']) {
        Add-FnJoin -Delimiter "" -ListOfValues @("arn:aws:s3:::", $bucket)
        Add-FnJoin -Delimiter "" -ListOfValues @("arn:aws:s3:::", $bucket, "/*")
    }
    $policyParams.PolicyDocument.Statement += @{
        Effect = "Allow"
        Action = @(
            "s3:Get*"
            "s3:List*"
        )
        Resource = $bucketResources
    }
}
$resourceParams = @{
    LogicalId = 'StdEC2Role'
    Path = "/"
    Policies = @(
        (Add-VSIAMRolePolicy @policyParams)
    )
    ManagedPolicyArns = @("arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy")
    AssumeRolePolicyDocument = @{
        Statement = @(
            @{
                Action = @("sts:AssumeRole")
                Effect = "Allow"
                Principal = @{
                    Service = @("ec2.amazonaws.com")
                }
            }
        )
    }
}
New-VSIAMRole @resourceParams

New-VSIAMInstanceProfile -LogicalId "StdEC2InstanceProfile" -Roles (Add-FnRef "StdEC2Role")

if ($PSBoundParameters.Keys -contains 'BucketName') {
    # If a BucketName or list of BucketNames is specified, add S3BucketPolicy to StdEC2Role
    $s3PolicyParams = @{
        LogicalId = "StdS3Policy"
        PolicyName = "StdS3Policy"
        PolicyDocument = @{
            Statement = @(
                @{
                    Effect = "Allow"
                    Action = @(
                        "s3:DeleteObject"
                        "s3:GetObject"
                        "s3:ListBucket"
                        "s3:PutObject"
                    )
                    Resource = $bucketResources
                }
            )
        }
        Roles = (Add-FnRef "StdEC2Role")
    }
    New-VSIAMPolicy @s3PolicyParams
}

if ($Global:VSConfig.Environment -eq 'prd') {
    $topicParams = @{
        LogicalId = 'StdPRDMonitoringTopic'
        Subscription = @(
            Add-VSSNSTopicSubscription -Endpoint (Add-FnJoin -Delimiter "" -ListOfValues "arn:aws:sqs:",(Add-FnRef $_AWSRegion),":",(Add-FnRef $_AWSAccountId),"MonitoringQueue") -Protocol 'sqs'
        )
        TopicName = (Add-FnJoin -Delimiter "" -ListOfValues 'Monitoring_Environment-',$global:VSConfig.Environment,'_Application-',$global:VSConfig.StackName)
    }
    New-VSSNSTopic @topicParams

    $global:notificationConfig += Add-VSAutoScalingAutoScalingGroupNotificationConfiguration -NotificationTypes @(
        'autoscaling:EC2_INSTANCE_LAUNCH'
        'autoscaling:EC2_INSTANCE_LAUNCH_ERROR'
        'autoscaling:EC2_INSTANCE_TERMINATE'
        'autoscaling:EC2_INSTANCE_TERMINATE_ERROR'
    ) -TopicARN (Add-FnRef 'StdPRDMonitoringTopic')

    New-VaporResource -LogicalId "StdPRDMonitoringHostTemplate" -Type "Custom::MonitoringHostTemplate" -Properties @{
        ServiceToken = (Add-FnJoin -Delimiter "" -ListOfValues "arn:aws:sns:",(Add-FnRef $_AWSRegion),":",(Add-FnRef $_AWSAccountId),"MonitoringHostTemplateTopic")
        AccountId = (Add-FnRef $_AWSAccountId)
        HostTemplateName = $global:VSConfig.StackName + "-" + $global:VSConfig.Environment
        HostTemplateDescription = "Host template for " + $global:VSConfig.StackName + "-" + $global:VSConfig.Environment + " stack."
    }
}

$elbParams = @{
    LogicalId = "StdElasticLoadBalancer"
    ConnectionDrainingPolicy = (Add-VSElasticLoadBalancingLoadBalancerConnectionDrainingPolicy -Enabled:$true -Timeout 300)
    Subnets = @(
        Add-FnImportValue "subnet-web-front-end-us-west-2a"
        Add-FnImportValue "subnet-web-front-end-us-west-2b"
    )
    HealthCheck = (Add-VSElasticLoadBalancingLoadBalancerHealthCheck -Target "HTTPS:443/healthcheck.htm" -HealthyThreshold '2' -UnhealthyThreshold '2' -Interval '12' -Timeout '10')
    Listeners = @(
        Add-VSElasticLoadBalancingLoadBalancerListeners -LoadBalancerPort '80' -InstancePort '80' -InstanceProtocol 'HTTP' -Protocol 'HTTP'
        Add-VSElasticLoadBalancingLoadBalancerListeners -LoadBalancerPort '443' -InstancePort '443' -InstanceProtocol 'TCP' -Protocol 'TCP'
    )
    CrossZone = $true
    SecurityGroups = (Add-FnImportValue "webserver-sec-group")
    LoadBalancerName = (Add-FnJoin "-" @($Global:VSConfig.StackName,$Global:VSConfig.Environment))
    Scheme = "Internal"
    Tags = $Tags
}
New-VSElasticLoadBalancingLoadBalancer @elbParams

$launchConfigParams = @{
    LogicalId = 'StdLaunchConfiguration'
    ImageId = $Global:VSConfig.AMI
    KeyName = $Global:VSConfig.EC2Key
    SecurityGroups = @(
        Add-FnImportValue "monitorpatching-sec-group"
        Add-FnImportValue "windowsmanagement-sec-group"
        Add-FnImportValue "ad-sec-group"
        Add-FnImportValue "webserver-sec-group"
    )
    InstanceType = $Global:VSConfig.InstanceType
    IamInstanceProfile = (Add-FnRef 'StdEC2InstanceProfile')
}
if ($PSBoundParameters.Keys -contains 'UserData') {
    $launchConfigParams['UserData'] = if ($UserData.PSTypeNames[0] -eq 'Vaporshell.Resource.UserData') {
        $UserData
    }
    elseif (Test-Path $UserData) {
        Add-UserData -File $UserData
    }
    else {
        Add-UserData -String $UserData
    }
}
New-VSAutoScalingLaunchConfiguration @launchConfigParams

$asgUpdatePolicy = @{
    PauseTime = 'PT1H'
    MaxBatchSize = [Math]::Round(($Global:VSConfig.ASGDesired/2),0)
    MinInstancesInService = $Global:VSConfig.ASGMin
    WaitOnResourceSignals = $true
    SuspendProcesses = @(
        "HealthCheck"
        "ReplaceUnhealthy"
        "AZRebalance"
        "AlarmNotification"
        "ScheduledActions"
    )
}
$asgCreationPolicy = @{
    MinSuccessfulInstancesPercent = 100
    Count = $Global:VSConfig.ASGDesired
    Timeout = 'PT1H'
}
$asgParams = @{
    LogicalId = 'StdAutoScalingGroup'
    MinSize = $Global:VSConfig.ASGMin
    MaxSize = $Global:VSConfig.ASGMax
    DesiredCapacity = $Global:VSConfig.ASGDesired
    AvailabilityZones = $Global:VSConfig.AvailabilityZones
    LaunchConfigurationName = (Add-FnRef 'StdLaunchConfiguration')
    LoadBalancerNames = @(
        Add-FnRef 'StdElasticLoadBalancer'
    )
    Tags = $(foreach ($Tag in $Tags) {
        Add-VSAutoScalingAutoScalingGroupTagProperty -Key $Tag.Key -Value $Tag.Value -PropagateAtLaunch $true
    })
    VPCZoneIdentifier = @(
        Add-FnImportValue 'subnet-web-front-end-us-west-2a'
        Add-FnImportValue 'subnet-web-front-end-us-west-2b'
    )
    HealthCheckType = 'EC2'
    UpdatePolicy = (Add-UpdatePolicy @asgUpdatePolicy)
    CreationPolicy = (Add-CreationPolicy @asgCreationPolicy)
    NotificationConfigurations = $Global:notificationConfig
}

New-VSAutoScalingAutoScalingGroup @asgParams

New-VaporResource -LogicalId "StdElbDnsEntry" -Type "Custom::DNSEntry" -Properties @{
    ServiceToken = (Add-FnImportValue 'dns-entry-sns-arn')
    RecordName = $Global:VSConfig.StackName + '-' + $Global:VSConfig.Environment
    RecordData = (Add-FnGetAtt 'StdElasticLoadBalancer' 'DNSName')
}
