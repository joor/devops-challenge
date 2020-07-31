data "aws_route_table" "eks-interview" {
  vpc_id = "${module.eks-interview.vpc_id}"
}

data "aws_acm_certificate" "interview_joordev_wildcard" {
  domain = "*.interview.joordev.com"
}
