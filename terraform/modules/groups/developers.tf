variable "developers" {
  type = "list"

  default = [
    "kmckew",
    "nicolas",
    "joor-interview-user",
  ]
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers"
  group = "developers"
  users = ["${var.developers}"]
}
