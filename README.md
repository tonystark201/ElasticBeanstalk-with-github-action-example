# ElasticBeanstalk Tutorial

## Overview

### What is AWS-EB

> **AWS Elastic Beanstalk** is an AWS managed service for web applications. Elastic beanstalk is a pre-configured EC2 server that can directly take up your application code and environment configurations and use it to automatically provision and deploy the required resources within AWS to run the web application. 

### The features of AWS-EB

> + Fast and simplest way to deploy your application on the AWS.
> + Enable you to focus on writing code and spending less time or not need to focus on managing and configuring your server and environment.
> + Automatically scales your application up and down according to the specific needs.
> + Give you freedom to select the AWS resource.

### The components of AWS-EB

> + **Application:** Elastic Beanstalk directly takes in out project code. An application is a collection of components including environments, versions, configurations, etc.
> + __Version__: A version of code can be deployed on the AWS, which maybe store on S3 or other files.
> + __Environments:__ Users may want their application to run on different environments like DEV, UAT and PROD. Each environment runs only a single application version at a time.
> + __Environments Health:__One of the most lucrative features about running application on AWS or most of the other cloud platforms is the automated health checks.(Red, Yellow, Grey, Green)
> + __Environment Tier:__
>   + Web Server Environment
>     + Beanstalk Environment
>     + ALB
>     + ASG
>     + EC2 Instance
>     + Host Manager
>     + SG
>   + Worker Environment
>   + Note：Web Server communicate with Worker by SQS

## Infrastructure

There are many ways to build infrastructure, for example, you can use AWS CLI or create infrastructure in the console interface. Or you can use automated build tools like AWS CloudFormation, Terraform, etc. Since Terraform is a mature and easy-to-use IaC tool, as a demonstration project, we choose to use Terraform to create an infrastructure here.
+ initialization: Initialize the terraform environment

  ```shell
  terraform init
  ```
+ Validation: Check the syntax error

  ```shell
  terraform validation
  ```
+ Plan: check the deploy plan

  ```shell
  terraform plan
  ```
+ Apply: deploy the infrastructure

  ```shell
  terraform apply
  ```
+ Destroy: Delete all the infrastructure

  ```shell
  terraform destroy
  ```

Note: All the demo code about how to create the elastic beanstalk infrastructure, __you can view the code in the IaC folder in this repo__. Also, You must provide your AWS key and secret, and give the value in the "terraform.tfvars" as below:

```shell
# provider
aws_region = "us-east-1"
aws_access_key = "xxxxxx"
aws_secret_key = "xxxxxx"
```
When the infrastructure build successfully, you will see the output as below.

```shell
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.
Outputs:
endpoint_url = "flask-eb-env.eba-xxx.us-east-1.elasticbeanstalk.com"
```

When you visit the endpoint url, you will visit the minimum usable program. __The MVP we upload to S3 you can find in the folder of "mvp" in this Repo.__ Open you brower and visit the website, if "Hello, world!" display in the page, it means the beanstalk is ok now. Otherwise, you need to check if there is something wrong about your configuration.
One more word, why I use Terraform? Because it's easy to clean up all the infrastructure I've created. And I don't need to worry about something sitting in some forgotten corner that hasn't been cleaned up.

## GitHub Action

We use Github Action to implement automated deployment, __please view the code(which is in the folder of ".github") for the specific CICD Pipeline__.
In this case, our automated deployment pipeline is divided into two types of jobs: CI and CD. CI mainly implements static analysis and unit testing of code, and CD mainly implements packaging and updating Elastic Beanstalk status. Please pay attention to the conditions for executing CICD actions in this case, and you can adjust all the pipeline job steps according to the actual situation.
The workflow as below:

+ CI
  + Checkout the Code to the github runner
  + Lint the code, you can run flake8 or other tools to check the code format.
  + Run the unittest, you can use tox, pytets, unittest or some tools to implement the unit test of the code.
+ CD
  + Checkout the Code to the github runner
  + Generate deployment package. We use zip tools to compress the code to deploy.zip file
  + Configure AWS Credentials
  + Upload the zip file to S3.
  + Update Application Version of the beanstalk.
  Note:
1. You need to add your secret key in the Repo.(Click settings of the Repo you will find the place to add secret key)
2. We use Terraform build the Beanstalk and run the minimum usable program, so the in the CI jobs, we just need to update the beanstalk environment when the file is updated in the S3.

## Demo Display

+ Generate requirements
```shell
pipenv requirements >> requirements.txt
```
+ Knowledge points you will learn
  + Github Action
  + Terraform with AWS
  + Flask with the Extension Lib
  + Bootstrap5 with fontawesome
  + AWS Elastic Beanstalk

+ The Demo Web page

  + The index page you can input some information

  + The home page will show your information when you click submit in the index page.



## Summary

In fact, Beanstalk helps developer build a set of frameworks for different codes, which mainly use resources such as load balancers, EC2 instances with autoscaling, and security groups. Developer only need to care about the code, and do not need to spend the time to build the infrastructures. Beanstalk is similar to a scaffold, which initializes various resources required by the application through configuration, thereby reducing the burden of operation and maintenance personnel. If the developer use Terraform, they can quickly build the resources required by the application, such as load balancers, EKS, ECS, and so on. Therefore, using the combination of ALB and ECS(EKS) is also a good way for the application deployment.
__Welcome to fork and learn, and thank you for your reading.__

## Reference

+ [YouTube: ElasticBeanstalk introduction](https://www.youtube.com/watch?v=96DJ2Og90hU)
+ [Introduction to AWS Elastic Beanstalk](https://www.geeksforgeeks.org/introduction-to-aws-elastic-beanstalk/)
+ [Bootstrap5 Document](https://mdbootstrap.com/docs/)
+ [Deploying a Flask Application to Elastic Beanstalk](https://testdriven.io/blog/flask-elastic-beanstalk/)
+ [Terraform official resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application)
+ [AWS: Extending Elastic Beanstalk Linux platforms](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html#platforms-linux-extend.example)
+ [AWS Elastic Beanstalk Samples](https://github.com/awsdocs/elastic-beanstalk-samples/tree/master)
+ [AWS Elastic Beanstalk general options for all environments](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-autoscalingasg)
+ [AWS elasticbeanstalk commandline](https://docs.aws.amazon.com/cli/latest/reference/elasticbeanstalk/index.html)

  

