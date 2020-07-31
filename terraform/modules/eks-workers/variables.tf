variable "alb_tg_arn" {}
variable "ami_prefix" {}
variable "asg_tags" { type = "list" }
variable "cluster_name" {}
variable "cluster_certificate_authority" {}
variable "cluster_endpoint" {}
variable "cluster_security_group_id" {}
variable "desired_capacity" {}
variable "disk_size" {}
variable "instance_type" {}
variable "key_name" {}
variable "kubelet_options" {}
variable "max_size" {}
variable "min_size" {}
variable "name" {}
variable "subnet_ids" { type = "list" }
variable "vpc_id" {}
variable "workers_iam_role_arn" {}
variable "workers_iam_role_name" {}
variable "workers_security_group_id" {}
