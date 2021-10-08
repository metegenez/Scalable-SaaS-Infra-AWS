provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

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
  source           = "./modules/ecs"
  ecs_role         = module.iam.ecs_role
  ecs_sg           = module.vpc.ecs_sg
  ecs_subnet_a     = module.vpc.ecs_subnet_a
  ecs_subnet_b     = module.vpc.ecs_subnet_b
  ecs_subnet_c     = module.vpc.ecs_subnet_c
  ecs_target_group = module.elb.ecs_target_group
}

module "rds" {
  source       = "./modules/rds"
  db_username  = var.db_username
  db_password  = var.db_password
  vpc          = module.vpc.vpc
  ecs_subnet_a = module.vpc.ecs_subnet_a
  ecs_subnet_b = module.vpc.ecs_subnet_b
  ecs_subnet_c = module.vpc.ecs_subnet_c
}

