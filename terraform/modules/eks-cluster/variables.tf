variable "cluster_name" {}
variable "worker_prefix" {}
variable "vpc_cidr" {}
variable "subnet_newbits" {}
variable "availability_zones" { type = "list" }
variable "kube_version" {}
variable "domain_certificate_id" {}

# Port used to redirect traffic from the ALB to the target group
# this is usually the port where traefik is listening
variable "alb_target_port" {}

variable "alb_secgroup_ports" { type = "list" }
