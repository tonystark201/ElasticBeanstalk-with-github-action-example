
data "archive_file" "server_deploy" {
  type        = "zip"
  source_dir = local.server_path
  output_path = local.deploy_path
}


data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "permissions" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeInstanceStatus",
      "ssm:*",
      "ec2messages:*",
      "s3:*",
      "sqs:*"
    ]
    resources = ["*"]
  }
}
