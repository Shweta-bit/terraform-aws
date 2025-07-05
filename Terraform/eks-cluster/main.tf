module "network" {
  source              = "../modules/network"
  vpc_cidr            = var.vpc_cidr
  name                = var.name   
  public_subnet_cidr_1    = var.public_subnet_cidr_1
  public_subnet_cidr_2    = var.public_subnet_cidr_2
  private_subnet_cidr_1   = var.private_subnet_cidr_1
  private_subnet_cidr_2   = var.private_subnet_cidr_2
  availability_zone_1     = var.availability_zone_1
  availability_zone_2     = var.availability_zone_2
}

module "ec2" {
  source         = "../modules/ec2"
  instance_type  = var.instance_type
  key_name       = module.key_pair.key_name
  subnet_id      = module.network.public_subnet_ids[0]
  sg_id          = module.network.sg_id
  name           = var.name
}

module "iam_roles" {
    source         = "../modules/iam_roles/base"
    name           = var.name
}

module "key_pair" {
  source    = "../modules/key_pair"
  key_name  = "sc-key"
}

resource "aws_eks_cluster" "eks_cluster" {
  name            = "${var.cluster_name}"
  role_arn        =  module.iam_roles.eks_cluster_role_arn
  version         = var.cluster_version

  vpc_config {
    subnet_ids         = concat(module.network.public_subnet_ids, module.network.private_subnet_ids)
    
    security_group_ids = [module.network.sg_id]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
    
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }


    # Enable EKS Cluster Control Plane Logging
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  depends_on = [module.iam_roles]
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0c5e9b6d9"] # Standard AWS thumbprint
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


# Now, OIDC available, pass it to IRSA-specific IAM Roles
module "iam_roles_irsa" {
  source           = "../modules/iam_roles/irsa"
  name             = var.name
  account_id       = var.account_id
  oidc_issuer_url  = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  depends_on = [aws_eks_cluster.eks_cluster]
}



data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

# create aws eks node group - public
resource "aws_eks_node_group" "eks_node_group_public" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}-node_group_public"
  node_role_arn   = module.iam_roles.eks_nodegroup_role_arn
  subnet_ids = module.network.public_subnet_ids

  # vpc_config {
  #   subnet_ids         = module.network.subnet_id
  #   }
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  version         = var.cluster_version

  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  capacity_type = var.eks_node_group_public_capacity_type
  disk_size = 20
  instance_types = var.node_instance_type
  
  remote_access {
    ec2_ssh_key = module.key_pair.key_name
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [module.iam_roles]

  tags = {
    Name = "${var.name}-Public-Node-Group"
  }
}

# create aws eks node group - private
resource "aws_eks_node_group" "eks_node_group_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}-node_group_private"
  node_role_arn   = module.iam_roles.eks_nodegroup_role_arn
  subnet_ids = module.network.private_subnet_ids


  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  version         = var.cluster_version

  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  capacity_type = var.eks_node_group_public_capacity_type
  disk_size = 20
  instance_types = var.node_instance_type
  
  remote_access {
    ec2_ssh_key = module.key_pair.key_name
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [module.iam_roles]

  tags = {
    Name = "${var.name}-Private-Node-Group"
  }
}




module "eks-add-ons" {
  source = "../modules/eks-add-ons"

  cluster_name      = aws_eks_cluster.eks_cluster.name
  coredns_version   = var.coredns_version
  vpc_cni_version   = var.vpc_cni_version
  kube_proxy_version = var.kube_proxy_version
  ebs_csi_version   = var.ebs_csi_version
  ebs_csi_driver_role_arn = module.iam_roles_irsa.ebs_csi_driver_role_arn

  depends_on = [
    module.iam_roles,
    module.iam_roles_irsa,
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_node_group_public,
    aws_eks_node_group.eks_node_group_private
  ]
}

locals {
  argo_app_yaml = templatefile("${path.module}/application-template.yaml", {
    vpc_id = module.network.vpc_id
  })
  depends_on = [
    module.network
  ]
}


resource "local_file" "argo_application_yaml" {
  content  = local.argo_app_yaml
  filename = "../../argocd-helm/applications/aws-load-balancer-controller.yaml"
}


