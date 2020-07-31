resource "aws_ecr_repository" "joor_repos" {
  count = "${length(var.joor_ecr_project_names)}"
  name  = "joor-${var.joor_ecr_project_names[count.index]}"
}
