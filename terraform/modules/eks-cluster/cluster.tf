# The EKS Cluster

resource "aws_eks_cluster" "main" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"
  version  = "${var.kube_version}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids         = ["${aws_subnet.main.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]
}
