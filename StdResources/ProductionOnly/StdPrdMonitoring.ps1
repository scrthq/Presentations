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
