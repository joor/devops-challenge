provider "aws" {
  region = "us-east-1"
}

module "groups" {
  source = "./modules/groups"
}
