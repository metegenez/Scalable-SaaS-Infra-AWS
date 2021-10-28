variable "github_personal_access_token" {
  description = "Personal access tokens function like ordinary OAuth access tokens. They can be used instead of a password for Git over HTTPS, or can be used to authenticate to the API over Basic Authentication."
  type        = string
  sensitive   = true
}


variable "branch" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "master"
  }

}

variable "ecs_cluster" {

}

variable "ecs_backend_service" {

}

variable "ecs_backend_taskdefinition" {

}


variable "ecs_test_target_group" {

}

variable "ecs_target_group" {

}
variable "aws_backend_lb_listener" {

}
