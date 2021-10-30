resource "aws_vpc" "vpc" {
  cidr_block           = "192.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "internal_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internal_gateway.id
  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "elb_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "elb_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "elb_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "ecs_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "ecs_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.4.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "ecs_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.5.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "rds_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.6.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "rds_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.7.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_subnet" "rds_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.0.8.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_route_table_association" "elb_a" {
  subnet_id      = aws_subnet.elb_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "elb_b" {
  subnet_id      = aws_subnet.elb_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "elb_c" {
  subnet_id      = aws_subnet.elb_c.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_a" {
  subnet_id      = aws_subnet.ecs_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_b" {
  subnet_id      = aws_subnet.ecs_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_c" {
  subnet_id      = aws_subnet.ecs_c.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rds_a" {
  subnet_id      = aws_subnet.rds_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rds_b" {
  subnet_id      = aws_subnet.rds_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rds_c" {
  subnet_id      = aws_subnet.rds_c.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_security_group" "ecs_task" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

//

resource "aws_security_group" "rds_cluster" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}
resource "aws_security_group_rule" "ingress_rds_cluster" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_cluster.id
  to_port                  = 5432
  source_security_group_id = aws_security_group.ecs_task.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_rds_cluster" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.rds_cluster.id
}

//


resource "aws_security_group_rule" "ingress_load_balancer_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 80
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_load_balancer_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 443
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_ecs_task_elb" {
  from_port                = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task.id
  to_port                  = 8000
  source_security_group_id = aws_security_group.load_balancer.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_load_balancer" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "egress_ecs_task" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}


resource "aws_security_group" "vpc_endpoint" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_security_group_rule" "ingress_vpc_endpoint_https" {
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "egress_vpc_endpoint" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_endpoint.id
}


resource "aws_vpc_endpoint" "ecr" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.ecs_a.id, aws_subnet.ecs_c.id, aws_subnet.ecs_b.id
  ]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.ecs_a.id, aws_subnet.ecs_c.id, aws_subnet.ecs_b.id
  ]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}
resource "aws_vpc_endpoint" "secretmanager-api" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.ecs_a.id, aws_subnet.ecs_c.id, aws_subnet.ecs_b.id
  ]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}
