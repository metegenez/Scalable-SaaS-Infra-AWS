//terraform apply -var-file="secret.tfvars"

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

# module "cognito" {
#   source = "./modules/cognito"
# }



module "elb" {
  source                 = "./modules/elb"
  load_balancer_sg       = module.vpc.load_balancer_sg
  load_balancer_subnet_a = module.vpc.load_balancer_subnet_a
  load_balancer_subnet_b = module.vpc.load_balancer_subnet_b
  load_balancer_subnet_c = module.vpc.load_balancer_subnet_c
  vpc                    = module.vpc.vpc
}

module "iam" {
  source = "./modules/iam"
  elb    = module.elb.elb
}

module "ecs" {
  source               = "./modules/ecs"
  ecs_role             = module.iam.ecs_role
  ecs_sg               = module.vpc.ecs_sg
  ecs_subnet_a         = module.vpc.ecs_subnet_a
  ecs_subnet_b         = module.vpc.ecs_subnet_b
  ecs_subnet_c         = module.vpc.ecs_subnet_c
  ecs_target_group     = module.elb.ecs_target_group
  backend_ecr          = module.codedeploy.backend_ecr
  aws_rds_cluster_host = module.rds.aws_rds_cluster_host
  aws_rds_cluster_name = module.rds.aws_rds_cluster_name
}

module "autoscaling" {
  source      = "./modules/autoscaling"
  ecs_cluster = module.ecs.ecs_cluster
  ecs_service = module.ecs.ecs_backend_service


}

# module "onlycodedeploy" {
#   source                     = "git::https://github.com/tmknom/terraform-aws-codedeploy-for-ecs.git?ref=tags/1.2.0"
#   name                       = "example"
#   ecs_cluster_name           = module.ecs.ecs_cluster.name
#   ecs_service_name           = module.ecs.ecs_backend_service.name
#   lb_listener_arns           = ["${var.lb_listener_arns}"]
#   blue_lb_target_group_name  = var.blue_lb_target_group_name
#   green_lb_target_group_name = var.green_lb_target_group_name
# }

module "codedeploy" {
  source                       = "./modules/codedeploy"
  github_personal_access_token = var.github_personal_token
  ecs_backend_service          = module.ecs.ecs_backend_service
  ecs_cluster                  = module.ecs.ecs_cluster
  ecs_backend_taskdefinition   = module.ecs.ecs_backend_taskdefinition
  ecs_target_group             = module.elb.ecs_target_group
  ecs_test_target_group        = module.elb.ecs_test_target_group
  aws_backend_lb_listener      = module.elb.aws_backend_lb_listener

}

module "rds" {
  source         = "./modules/rds"
  db_username    = var.db_username
  db_password    = var.db_password
  rds_cluster_sg = module.vpc.rds_cluster_sg
  rds_subnet_a   = module.vpc.rds_subnet_a
  rds_subnet_b   = module.vpc.rds_subnet_b
  rds_subnet_c   = module.vpc.rds_subnet_c
}

