resource "aws_eks_cluster" "default" {
  name     = "${var.env}-${var.service}-${var.role}"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.eks_cluster_subnets
    endpoint_public_access  = var.eks_endpoint_public_access
    endpoint_private_access = var.eks_endpoint_private_access
    public_access_cidrs     = var.eks_trusted_networks
  }

  tags = {
    Name        = "${var.env}-${var.service}-${var.role}-default-cluster"
    Service     = var.service
    Role        = var.role
    Environment = var.env
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-${var.env}-${var.service}-${var.role}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.default.name
  node_group_name = "${var.env}-${var.service}-${var.role}-default-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.eks_cluster_subnets
  disk_size       = var.eks_nodes_disk_size
  instance_types  = var.eks_nodes_instance_types
  release_version = var.eks_nodes_release_version

  scaling_config {
    desired_size = var.eks_node_pool_desired_size
    max_size     = var.eks_node_pool_max_size
    min_size     = var.eks_node_pool_min_size
  }

  tags = {
    Name        = "${var.env}-${var.service}-${var.role}-default-node-group"
    Service     = var.service
    Role        = var.role
    Environment = var.env
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_worker_nodes_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    kubernetes_config_map.aws_auth
  ]
}

locals {
  eks_asg_name = lookup(element(lookup(element(aws_eks_node_group.default.resources, 0), "autoscaling_groups", []), 0), "name", "")
}

resource "null_resource" "awscli" {
  triggers = {
    asg_id = local.eks_asg_name
  }
  provisioner "local-exec" {
    command = <<EOF
# Install AWS cli in TF runner environnement (Latest Ubuntu LTS based)
if ${var.aws_cli_install}; then
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  unzip awscli-bundle.zip
  ./awscli-bundle/install -b ~/bin/aws
fi
EOF
  }
}

resource "null_resource" "custom_eks_asg_config" {
  triggers = {
    asg_id = local.eks_asg_name
  }
  depends_on = [
  null_resource.awscli]
  provisioner "local-exec" {
    command = <<EOF

if ${var.aws_cli_install}; then
  AWS_CLI=/home/terraform/bin
else
  AWS_CLI=/usr/local/bin
fi

# Add Custom Tags to eks autoscaling group
$AWS_CLI/aws autoscaling create-or-update-tags \
  --region ${var.region} \
  --tags ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=Name,Value=eks-cluster-default-group-node,PropagateAtLaunch=true \
  ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=Service,Value=${var.service},PropagateAtLaunch=true \
  ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=Role,Value=${var.role}-node,PropagateAtLaunch=true \
  ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=Environment,Value=${var.env},PropagateAtLaunch=true \
  ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=Datadog,Value=${var.datadog_metrics_enabled},PropagateAtLaunch=true \
  ResourceId=${local.eks_asg_name},ResourceType=auto-scaling-group,Key=stop,Value=${var.start_stop_enabled},PropagateAtLaunch=true


# Get Instance ID
INSTANCE_IDS=$($AWS_CLI/aws autoscaling describe-auto-scaling-instances \
  --region ${var.region} \
  --query 'AutoScalingInstances[?AutoScalingGroupName==`${local.eks_asg_name}`].InstanceId' \
  --output text)

for i in $INSTANCE_IDS
do
  # Terminate Instance
  $AWS_CLI/aws autoscaling terminate-instance-in-auto-scaling-group \
    --region ${var.region} \
    --instance-id $i \
    --no-should-decrement-desired-capacity
done;

EOF
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-${var.env}-${var.service}-${var.role}-nodes"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_nodes_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

locals {
  eks_roles = [
    {
      rolearn  = aws_iam_role.eks_nodes.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = tolist(concat(
        [
          "system:bootstrappers",
          "system:nodes",
        ],
        []
      ))
    },
    {
      rolearn  = var.admin_role_arn
      username = "devops"
      groups = tolist(concat(
        [
          "system:masters"
        ],
        []
      ))
    },
    {
      rolearn  = var.user_role_arn
      username = "user"
      groups = tolist(concat(
        [
          "system:basic-user",
          "system:public-info-viewer"
        ],
        []
      ))
    }
  ]
}

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [
  aws_eks_cluster.default]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles    = yamlencode(local.eks_roles)
    mapUsers    = yamlencode(var.eks_authorized_users)
    mapAccounts = yamlencode(var.eks_authorized_accounts)
  }
}

data "external" "thumbprint" {
  program = [
    "${path.module}/bin/thumbprint.sh",
  var.region]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = [
  "sts.amazonaws.com"]
  thumbprint_list = [
  data.external.thumbprint.result.thumbprint]
  url = aws_eks_cluster.default.identity[0].oidc[0].issuer
}