###################
# AWS Config
###################

variable "aws_region" {
  default     = "us-east-1"
  description = "aws region where our resources going to create choose"
}

variable "aws_access_key" {
  type = string
  description = "aws_access_key"
}

variable "aws_secret_key" {
  type = string
  description = "aws_secret_key"
}

###################
# Project Config
###################

variable "solution_stack_name" {
  type        = string
  description = "EB solution stack name"
  default     = "64bit Amazon Linux 2 v3.3.15 running Python 3.7"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "max_instance_count" {
  type        = number
  description = "Max instance count in auto scaling group"
  default     = 2
}

variable "eb_app_name" {
  type        = string
  description = "EB application lable"
  default     = "flask-eb-demo"
}

variable "eb_env_name" {
  type        = string
  description = "EB environment name"
  default     = "flask-eb-env"
}

variable "eb_version_label" {
  type        = string
  description = "EB version label"
  default     = "flask-version-one"
}

###################
# VPC Subnets
###################

variable "eb_subnet1a" {
  type        = string
  description = "subnet1"
  default     = "us-east-1a"
}

variable "eb_subnet1b" {
  type        = string
  description = "subnet1"
  default     = "us-east-1b"
}

variable "eb_subnet1c" {
  type        = string
  description = "subnet1"
  default     = "us-east-1c"
}
