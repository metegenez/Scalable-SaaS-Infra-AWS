//terraform apply -var-file="secret.tfvars"

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "frontend" {
  source = "./modules/frontend"
  branch = var.branch
  frontend_sub_domain_prefix = var.frontend_sub_domain_prefix
  backend_sub_domain_prefix = var.backend_sub_domain_prefix
  hosted_zone_id = var.hosted_zone_id
  aws_secret_manager_secret_arn = var.aws_secret_manager_secret_arn
  github_repository = var.github_repository
  acm_certificate = var.acm_certificate
  domain_name = var.domain_name
}

module "elb" {
  source                   = "./modules/elb"
  load_balancer_sg         = module.vpc.load_balancer_sg
  load_balancer_subnet_a   = module.vpc.load_balancer_subnet_a
  load_balancer_subnet_b   = module.vpc.load_balancer_subnet_b
  load_balancer_subnet_c   = module.vpc.load_balancer_subnet_c
  vpc                      = module.vpc.vpc
  acm_certificate = var.acm_certificate
}

module "iam" {
  source = "./modules/iam"
  elb    = module.elb.elb
}

module "route" {
  source         = "./modules/route"
  hosted_zone_id = var.hosted_zone_id
  domain_name = var.domain_name
  backend_sub_domain_prefix = var.backend_sub_domain_prefix
  elb            = module.elb.elb
}

module "ecs" {
  source                   = "./modules/ecs"
  ecs_role                 = module.iam.ecs_role
  ecs_sg                   = module.vpc.ecs_sg
  ecs_subnet_a             = module.vpc.ecs_subnet_a
  ecs_subnet_b             = module.vpc.ecs_subnet_b
  ecs_subnet_c             = module.vpc.ecs_subnet_c
  ecs_target_group_b       = module.elb.ecs_target_group_b
  ecs_target_group_a       = module.elb.ecs_target_group_a
  backend_ecr              = module.codedeploy.backend_ecr
  aws_rds_cluster_host     = module.rds.aws_rds_cluster_host
  aws_rds_cluster_name     = module.rds.aws_rds_cluster_name
  aws_rds_cluster_ro_host  = module.rds.aws_rds_cluster_ro_host
  backend_sub_domain_prefix = var.backend_sub_domain_prefix
  domain_name = var.domain_name
  aws_secret_manager_secret_arn = var.aws_secret_manager_secret_arn
}

module "autoscaling" {
  source                   = "./modules/autoscaling"
  ecs_cluster              = module.ecs.ecs_cluster
  ecs_service              = module.ecs.ecs_backend_service
  aws_rds_cluster_id = module.rds.aws_rds_cluster_id

}

module "codedeploy" {
  source                       = "./modules/codedeploy"
  branch = var.branch
  github_repository = var.github_repository
  ecs_backend_service          = module.ecs.ecs_backend_service
  ecs_cluster                  = module.ecs.ecs_cluster
  ecs_backend_taskdefinition   = module.ecs.ecs_backend_taskdefinition
  ecs_target_group_b           = module.elb.ecs_target_group_b
  ecs_target_group_a           = module.elb.ecs_target_group_a
  aws_backend_lb_listener      = module.elb.aws_backend_lb_listener
  aws_secret_manager_secret_arn = var.aws_secret_manager_secret_arn
}

module "rds" {
  source         = "./modules/rds"
  rds_cluster_sg = module.vpc.rds_cluster_sg
  rds_subnet_a   = module.vpc.rds_subnet_a
  rds_subnet_b   = module.vpc.rds_subnet_b
  rds_subnet_c   = module.vpc.rds_subnet_c
  aws_secret_manager_secret_arn = var.aws_secret_manager_secret_arn
}

