#####
# Cluster
#####

# EC2 Security Group to allow networking traffic with EKS cluster

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "${var.cluster_name} communication with workers"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_name}-cluster"
  }
}

#####
# Workers
#####

resource "aws_security_group" "workers" {
  name        = "${var.worker_prefix}"
  description = "Security group for ${var.worker_prefix} workers in the ${var.cluster_name} cluster"
  vpc_id      = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.worker_prefix}",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "ingress-node-ssh" {
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow ssh on port 22 to the worker nodes"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive HTTPS communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-alb" {
  description              = "Allow worker to communicate with the ALB"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.alb-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
