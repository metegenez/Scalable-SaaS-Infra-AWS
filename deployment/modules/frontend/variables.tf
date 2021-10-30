variable "branch" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "master"
  }

}
