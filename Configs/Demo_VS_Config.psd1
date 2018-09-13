@{
    Dev = @{
        # Let's keep the Dev autoscaling group smaller in size for cost
        AMI = "ami-f582359e"
        ASGDesired = "1"
        ASGMax = "1"
        ASGMin = "1"
        AvailabilityZones = @( "us-west-2a", "us-west-2b" )
        Description = "Core Web Tier DEVELOPMENT"
        EC2Key = "WindowsDev"
        Environment = "dev"
        InstanceType = "t2.micro"
        S3BucketName = "MyBucket_Dev"
        StackName = "web-tier-core"
        Tags = @{
            Application = "MyCoolWebApp"
            Department = "technology"
            Division = "infrastructure"
            Environment = "development"
            Name = "cf-web-d-1"
            Role = "web"
        }
        TemplateName = "Web-Tier-Core-DEV.yml"
        UserDataFile = "StdUserData.ps1"
    }
    Stg = @{
        # Let's bump up the staging autoscaling group a bit to get us closer to production
        AMI = "ami-f582359e"
        ASGDesired = "2"
        ASGMax = "2"
        ASGMin = "1"
        AvailabilityZones = @( "us-west-2a", "us-west-2b" )
        Description = "Core Web Tier STAGING"
        EC2Key = "WindowsStg"
        Environment = "stg"
        InstanceType = "t2.medium"
        S3BucketName = "MyBucket_Stg"
        StackName = "web-tier-core"
        Tags = @{
            Application = "MyCoolWebApp"
            Department = "technology"
            Division = "infrastructure"
            Environment = "staging"
            Name = "cf-web-s-1"
            Role = "web"
        }
        TemplateName = "Web-Tier-Core-STG.yml"
        UserDataFile = "StdUserData.ps1"
    }
    Prd = @{
        AMI = "ami-f582359e"
        ASGDesired = "4"
        ASGMax = "4"
        ASGMin = "2"
        AvailabilityZones = @( "us-west-2a", "us-west-2b" )
        Description = "Core Web Tier PRODUCTION"
        EC2Key = "WindowsPrd"
        Environment = "prd"
        InstanceType = "t2.large"
        S3BucketName = "MyBucket_Prd"
        StackName = "web-tier-core"
        Tags = @{
            Application = "MyCoolWebApp"
            Department = "technology"
            Division = "infrastructure"
            Environment = "production"
            Name = "cf-web-1"
            Role = "web"
        }
        TemplateName = "Web-Tier-Core-PRD.yml"
        UserDataFile = "StdUserData.ps1"
    }
}
