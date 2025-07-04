# IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name}-eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

resource "aws_iam_role_policy_attachment" "service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_vpc_resource_controller_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}


# IAM Role for EKS Node Group 
resource "aws_iam_role" "eks_nodegroup_role" {
  name =  "${var.name}-eks-nodegroup-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_nodegroup_role.name}"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks_nodegroup_role.name}"
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks_nodegroup_role.name}"
}

# resource "aws_iam_instance_profile" "demo-node" {
#   name = "terraform-eks-demo"
#   role = "${aws_iam_role.eks_nodegroup_role.name}"
# }


resource "aws_iam_role" "ebs_csi_driver" {
  name = "eks-cluster-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ebs_csi_driver_policy" {
  name = "ebs-csi-driver-policy"
  role = aws_iam_role.ebs_csi_driver.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      }
    ]
  })
}
