# Scalable SaaS Boilerplate

The boilerplate implementation helps developers launch a scalable serverless containerized infrastructure to host frontend and services, store data in RDS. The solution supports a sample three-tier web application to a single Docker node in AWS. The application consists of frontend, backend, and database tiers. The frontend is static, the backend is stateless and the database is relational. The solution provides a AWS Fargate service for docker orhastration, AWS Codebuild and CodeDeploy for blue/green deployment, AWS S3&Cloudfront for client-side and AWS Aurora for relational database. Scability is ensured by autoscale groups attacted to Fargate services and Aurora. The solution is configured Development, Stage and Production environments separately. 

# Solution Overview

The diagram below presents the architecture you can automatically deploy using the solution's implementation guide and accompanying Terraform template template.

!['https://s3.us-west-2.amazonaws.com/secure.notion-static.com/8958b6f8-10eb-4694-b91b-ea9b779ae82d/cloudvisor_%281%29.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAT73L2G45O3KS52Y5%2F20211101%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20211101T221900Z&X-Amz-Expires=86400&X-Amz-Signature=c33bc1754ee12abd19a849fa1f5903b59d3f64d84fbc52690c0076a91eb5d0b7&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D"cloudvisor%2520%281%29.png')

Launching this stack will not be covered [AWS Free Tier](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-free-tier.html)

# Automated deployment

Before you launch the automated deployment, review the architecture, configuration, and other
considerations discussed in this guide. Follow the step-by-step instructions in this section to configure and deploy the solution into your account.
**Time to deploy: Approximately 12 minutes**

You must have the latest version of the Terraform /AWS CLI installed. 

## Overview

In Terraform Structure, we used several internal modules to easy expansion if needed. Frontend module is implemented seperately, since there is a clear subsitute with AWS Amplify which is currently not supported in Terraform.

```powershell
│   backend.tf
│   environments.tf
│   main.tf
│   secret.tfvars
│   variables.tf
├───.terraform
└───modules
    ├───autoscaling
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───codedeploy
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───ecs
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───elb
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───frontend
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───iam
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───rds
    │       main.tf
    │       output.tf
    │       variables.tf
    │
    ├───route
    │       main.tf
    │       output.tf
    │       variable.tf
    │
    └───vpc
            main.tf
            output.tf
            variables.tf
```

# Prerequisites

- Create a S3 bucket to store Terraform state.
- Create a Hosted Zone for your domain.

## Prepare Remote Terraform Backend

In backend.tf file, we used S3 bucket to store our Terraform state.

```powershell
terraform {
  backend "s3" {
    bucket = "xxxxxxxxx"
    region = "us-east-1"
    key = "terraform.tfstate"
  }
}
```

Please create a S3 bucket from AWS UI before start.

## Prepare Terraform Workspaces

To support different development environments, we used Terraform Workspaces. Terraform starts with a single workspace named "default". This workspace is special both because it is the default and also because it cannot ever be deleted. If you've never explicitly used workspaces, then you've only ever worked on the "default" workspace.  Workspaces are managed with the `terraform workspace` set of commands. To create a new workspace and switch to it, you can use `terraform workspace new`; to switch workspaces you can use `terraform workspace select`.

In this project, we didnot use "default" workspace. We created 3 workspaces for development environments. Creating necessrary workspaces

```powershell
cd deployment
terraform workspace new dev
terraform workspace new stage
```

and start with

```powershell
terraform workspace select dev
```

## Prepare AWS Secret Manager

First, login to the AWS Secrets Manager UI, click “store a new secret,” and enter the secrets

```powershell
db_username
db_password
github_personal_token
SECRET_KEY
```

- db_username is any name you provide.
- db_password is any password you provide.
- Github Personal Access Token is used for accessing your Github Repository and capture PUSH events.
- SECRET_KEY is for Django Web App. You can generate a key from [https://djecrety.ir](https://djecrety.ir/).

After adding these to secret manager, get the ARN of secret. 

See: [Create and retrieve a secret](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_basic.html)

## Prepare config.tfvars

```powershell
region="us-east-1"
hosted_zone_id=""
acm_certificate="arn:aws:acm:us-east-1:xxxxxxxxxxxx"
aws_secret_manager_secret_arn="arn:aws:secretsmanager:us-east-1:xxxxxxxxxxxx"
branch = {
    dev   = "dev"
    stage = "stage"
    prod  = "master"
}
domain_name="xxxxx.co"
backend_sub_domain_prefix="xxxx-api"
frontend_sub_domain_prefix="xxxx"
github_repository="https://github.com/xxxxx.git"
```

- hosted_zone_id: This is ID of Hosted Zone on Route53. This must be your main domain.

See: [Creating a public hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)

- acm_certificate: ARN of the SSL certificate provided by AWS Certificate Manager to your domain.

See: [Requesting a public certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)

- aws_secret_manager_secret_arn: ARN of secret.
- branch: Mapping the Terraform Workspaces into the Github Repo braches
- domain_name: Domain name of your hosted zone.
- github_repository: Yout Github repository.
- backend_sub_domain_prefix: Backend service will serve from **"${var.backend_sub_domain_prefix}-${terraform.workspace}.${var.domain_name}"**
- frontend_sub_domain_prefix: Frontend will serve from "${var.frontend_sub_domain_prefix}-${terraform.workspace}.${var.domain_name}"

Fill the blanks at your interest. Do not make the "backend_sub_domain_prefix" and "frontend_sub_domain_prefix" same subdomain.

## Setup

- Fork repository

```powershell
https://github.com/metegenez/Scalable-SaaS-Infra-AWS
```

- Apply Terraform

```powershell
cd deployment
terraform workspace select dev
terraform apply -var-file="config.tfvars"
```

- Initiate Codebuild for Frontend on fresh start. Just change anything in /frontend folder and push.
- Initiate Codebuild for Backend service on fresh start. This is due to creating first Elatic Container Registry for the service. Just change anything in /frontend folder and push.

Initiation operations can be done with codes in buildspec.yml's as well. But pushing something to repository is less error prone.

All done!

### Blue/Green Deployment

Blue/green deployments provide releases with near zero-downtime and rollback capabilities. The fundamental idea behind blue/green deployment is to shift traffic between two identical environments that are running different versions of your application. The blue environment represents the current application version serving production traffic. In parallel, the green environment is staged running a different version of your application. After the green environment is ready and tested, production traffic is redirected from blue to green. If any problems are identified, you can roll back by reverting traffic back to the blue environment.

### Ignore_changes

We created 2 target groups for backend service named:

```powershell
resource "aws_lb_target_group" "target_a" {...}
resource "aws_lb_target_group" "target_b" {...}
```

After blue/green deployment successful, it messes up with Terraform state. Our unique listener has a default action, which is forwarding the port traffic to a target group and this default action's target group is switched after each deployment. This change is beyond the scope of Terraform and we need ignore changes on 

```
resource "aws_ecs_service" "node1" {
  name = "cloudvisor-node-${terraform.workspace}"
  ...conf
  load_balancer {
    target_group_arn = var.ecs_target_group_a.arn
    container_name   = "backend"
    container_port   = 8000
  }
  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

}
```

and 

```
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.elb.arn
  ...
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_a.arn
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}
```

Be aware this ignoring part if you want to change resources explicitly.

### Continous Deployment

CodeBuild and CodeDeploy works together. The mechanism coded here 

- CodeBuild webhook integrates with Github repository.
- After each push to dev/stage/master branches, CodeBuild starts building new image and create a CodeDeploy.

Caution: Sometimes CodeBuild fails due to `You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limits` error. Retry it later.

This stage is fully automated. No action is needed.
