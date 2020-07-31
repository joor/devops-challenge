output "developers" {
  value = "${aws_iam_group.developers.name}"
}

output "developers_arn" {
  value = "${aws_iam_group.developers.arn}"
}
