variable "account_id" { default = "488458563198" }
variable "kube_version" { default = "1.12" }
variable "ami_prefix" { default = "amazon-eks-node-1.12-v20190614" }

variable "joor_ecr_project_names" {
  type    = "list"
  default = [ "api.python","backend","deployer","pgbouncer","postgres","web.php" ]
}
