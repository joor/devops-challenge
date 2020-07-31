resource "aws_key_pair" "eks-interview" {
  key_name   = "eks-interview"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNJTE9f7Vjhn/Km414/gger+mwIBwwxffx37S+rqbfL69gArCU2LCEkpGp9deZkBNQPgOnRuZXHM/qYgYBo+0tkFUMBo5cwr/AeNCgi1jy2hfbRVf7yHIuanEQ6SXBMBm1ftCFUxnXF63kaSDhRt2sYWYz4m7yX1vK1doERLNozNrKViz0/cgVOhwHB95qpIzNcJMJRKYOk7huOt2VxQg9Bdusr+FERSULkW3YOTa6JRsdHi7vv1apNUl+npoCUciAcZwQq6270kRLmd6RTK/eOtbb60oiPO4Cl6s32x/lLOJ+LAmO23sdCQPOzVPCsepwVz9WS6rseE6O0BaNHPZL"
}

module "eks-interview" {
  source = "./modules/eks-cluster"

  cluster_name = "eks-interview"
  vpc_cidr = "10.70.0.0/16"
  subnet_newbits = 1
  kube_version = "${var.kube_version}"
  domain_certificate_id = "${data.aws_acm_certificate.interview_joordev_wildcard.arn}"
  alb_target_port = 32555
  alb_secgroup_ports = ["80","443"]

  # create 1 subnet per availability zone
  # EKS capacity is limited in other zones
  availability_zones = [
    "us-east-1b",
    "us-east-1c"
  ]

  worker_prefix = "eks-interview-workers-default"
}

module "eks-interview-workers-default" {
  source = "./modules/eks-workers"

  name = "eks-interview-workers-default"
  min_size = 0
  max_size = 10
  desired_capacity = 4

  # Root FS size in GB
  disk_size = 100

  instance_type = "m5.xlarge"
  key_name = "${aws_key_pair.eks-interview.key_name}"
  kubelet_options = "--node-labels jooraccess.com/asg=default"
  ami_prefix = "${var.ami_prefix}"

  # wire to cluster
  cluster_name = "${module.eks-interview.name}"
  cluster_certificate_authority = "${module.eks-interview.certificate_data}"
  cluster_endpoint = "${module.eks-interview.endpoint}"
  cluster_security_group_id = "${module.eks-interview.security_group_id}"
  subnet_ids = ["${module.eks-interview.subnets}"]
  alb_tg_arn = "${module.eks-interview.alb_tg_arn}"
  vpc_id = "${module.eks-interview.vpc_id}"
  workers_iam_role_arn = "${module.eks-interview.workers_iam_role_arn}"
  workers_iam_role_name = "${module.eks-interview.workers_iam_role_name}"
  workers_security_group_id = "${module.eks-interview.workers_security_group_id}"

  asg_tags = [
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "default"
      propagate_at_launch = false
    },

    {
      key                 = "k8s.io/cluster-autoscaler/${module.eks-interview.name}"
      value               = "owned"
      propagate_at_launch = false
    },
  ]
}

##
# Outputs
#

output "eks-interview-kubeconfig" {
  value = "${module.eks-interview.kubeconfig}"
}

output "eks-interview-worker-aws-auth" {
  value = "${module.eks-interview.worker-aws-auth}"
}

#
# Allow any user in the developer group to access the eks-interview cluster via kubectl by impersonating a role
#

resource "aws_iam_role" "eks-interview-admin" {
  name = "eks-interview-admin"
  description = "A role for users to impersonate when connecting to EKS eks-interview cluster. This saves us from adding every IAM user to the cluster configmap to give them kubectl access to the cluster."
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
        "AWS": "arn:aws:iam::488458563198:root"
      },
      "Action":"sts:AssumeRole",
      "Condition":{}
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "assume-eks-interview-admin" {
  name        = "assume-eks-interview-admin"
  description = "Allow users in group to assume the eks-interview-admin role"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "${aws_iam_role.eks-interview-admin.arn}"
  }
}
POLICY
}

resource "aws_iam_policy_attachment" "assume-interview-cluster-role-attachment" {
  name       = "assume-interview-cluster-role-attachment"
  groups     = ["${module.groups.developers}"]
  policy_arn = "${aws_iam_policy.assume-eks-interview-admin.arn}"
}

# grant eks-interview-admin access to ECR
resource "aws_iam_policy" "eks-interview-admin-ecr" {
  name        = "eks-interview-admin-ecr"
  description = "Grant read access to ECR"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:GetAuthorizationToken",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetRepositoryPolicy"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "eks-interview-admin-ecr-attachment" {
  name       = "eks-interview-admin-ecr-attachment"
  roles      = ["${aws_iam_role.eks-interview-admin.name}"]
  policy_arn = "${aws_iam_policy.eks-interview-admin-ecr.arn}"
}

# grant eks-interview-admin access to S3
resource "aws_iam_policy" "eks-interview-admin-s3" {
  name        = "eks-interview-admin-s3"
  description = "Grant read access to S3"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketByTags",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketTagging",
                "s3:GetInventoryConfiguration",
                "s3:GetObjectVersionTagging",
                "s3:ListBucketVersions",
                "s3:GetBucketLogging",
                "s3:ListBucket",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketPolicy",
                "s3:GetObjectVersionTorrent",
                "s3:GetObjectAcl",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketRequestPayment",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectTagging",
                "s3:GetMetricsConfiguration",
                "s3:GetIpConfiguration",
                "s3:ListBucketMultipartUploads",
                "s3:GetBucketWebsite",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:GetBucketNotification",
                "s3:GetReplicationConfiguration",
                "s3:ListMultipartUploadParts",
                "s3:GetObject",
                "s3:GetObjectTorrent",
                "s3:GetBucketCORS",
                "s3:GetAnalyticsConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::*/*",
                "arn:aws:s3:::s3-joordev-com"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:HeadBucket"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "eks-interview-admin-s3-attachment" {
  name       = "eks-interview-admin-s3-attachment"
  roles      = ["${aws_iam_role.eks-interview-admin.name}"]
  policy_arn = "${aws_iam_policy.eks-interview-admin-s3.arn}"
}
