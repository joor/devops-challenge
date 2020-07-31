#
# EKS Worker Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

locals {
  default_tags = [
    {
      key                 = "Name"
      value               = "${var.name}"
      propagate_at_launch = true
    },

    {
      key                 = "jooraccess.com/asg"
      value               = "${var.name}"
      propagate_at_launch = true
    },

    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },

    {
      key                 = "jooraccess.com/cluster"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    },
  ]

  node-userdata = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh ${var.cluster_name} --kubelet-extra-args "${var.kubelet_options}"
USERDATA

}

data "aws_region" "current" {}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["${var.ami_prefix}*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.cluster_name}"
  role = "${var.workers_iam_role_name}"
}

resource "aws_launch_configuration" "worker" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.worker.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.name}"
  security_groups             = ["${var.workers_security_group_id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"
  key_name                    = "${var.key_name}"

  root_block_device {
    volume_size = "${var.disk_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
      "name",
    ]
  }
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  triggers = {
    "before" = "${aws_autoscaling_group.workers.id}"
  }
}

resource "aws_autoscaling_group" "workers" {
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.worker.id}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  name                 = "${var.name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  target_group_arns    = ["${var.alb_tg_arn}"]

  tags = ["${concat(
    var.asg_tags,
    local.default_tags
  )}"]

  lifecycle {
    ignore_changes = [
      "desired_capacity"
    ]
  }
}
