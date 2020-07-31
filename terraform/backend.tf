terraform {
  backend "s3" {
    bucket = "joor-dev-terraform"
    key    = "interview-code-challenge/terraform-eks-interview.tfstate"
    region = "us-east-1"
  }
}
