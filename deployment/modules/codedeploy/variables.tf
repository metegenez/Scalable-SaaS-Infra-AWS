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