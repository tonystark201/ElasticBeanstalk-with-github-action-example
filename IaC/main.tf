
###################
# Create s3 bucket to store the EB version
###################

resource "aws_s3_bucket" "eb_bucket" {
  bucket = "flask-eb-demo-bucket-123456"
  tags = local.tags
}

resource "aws_s3_bucket_acl" "eb_bucket_acl" {
  bucket = aws_s3_bucket.eb_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "eb_bucket_encryption" {
  bucket = aws_s3_bucket.eb_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_object" "eb_object" {
  key    = "deploy.zip"
  bucket = aws_s3_bucket.eb_bucket.id
  source = data.archive_file.server_deploy.output_path
  tags   = local.tags
}

###################
# Create instance profile
###################

resource "aws_iam_instance_profile" "ec2_eb_profile" {
  name = "flask-eb-ec2-profile"
  role = aws_iam_role.ec2_role.name
  tags = local.tags
}

resource "aws_iam_role" "ec2_role" {
  name               = "flask-eb-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  ]

  inline_policy {
    name   = "eb-application-permissions"
    policy = data.aws_iam_policy_document.permissions.json
  }
  tags = local.tags
}

###################
# Use Default VPC and Create Security Group
###################

resource "aws_default_vpc" "default" {
  tags = local.tags
}

resource "aws_default_subnet" "default-1a" {
  availability_zone = "us-east-1a"
  tags = local.tags
}

resource "aws_default_subnet" "default-1b" {
  availability_zone = "us-east-1b"
  tags = local.tags
}

resource "aws_default_subnet" "default-1c" {
  availability_zone = "us-east-1c"
  tags = local.tags
}

resource "aws_security_group" "eb_sg" {
  name   = "flask_eb_sg"
  vpc_id = aws_default_vpc.default.id
}

resource "aws_security_group_rule" "allow_80" {
  type              = "ingress"
  to_port           = 80
  protocol          = "tcp"
  from_port         = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eb_sg.id
}

resource "aws_security_group_rule" "allow_8000" {
  type              = "ingress"
  to_port           = 8000
  protocol          = "tcp"
  from_port         = 8000
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eb_sg.id
}

resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eb_sg.id
}

###################
# Create Elastic Beanstalk
###################

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = var.eb_app_name
  description = "the demo using flask server"
  tags        = local.tags
}


resource "aws_elastic_beanstalk_application_version" "eb_version" {
  name        = var.eb_version_label
  application = aws_elastic_beanstalk_application.eb_app.name
  description = "flask application version created by terraform"
  bucket      = aws_s3_bucket.eb_bucket.id
  key         = "deploy.zip"
  tags        = local.tags

  depends_on = [
    aws_s3_bucket.eb_bucket,
    aws_s3_object.eb_object
  ]
}

resource "aws_elastic_beanstalk_environment" "eb_env" {
  name          = var.eb_env_name
  application   = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = var.solution_stack_name
  version_label = aws_elastic_beanstalk_application_version.eb_version.name
  tags          = local.tags

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_eb_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_sg.id
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_instance_count
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_sg.id
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstancePort"
    value     = 80 # nginx in the EC2 run on 80 port
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_default_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_default_subnet.default-1a.id},${aws_default_subnet.default-1b.id},${aws_default_subnet.default-1c.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = 200
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health_check"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }
}

# Setup output variable to show endpoint url to eb app
# Refer to variable in output.tf
