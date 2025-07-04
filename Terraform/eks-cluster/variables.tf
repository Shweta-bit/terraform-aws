# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "eksdemo"
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type = string
  default     = null
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_node_group_public_capacity_type" {}
variable "node_instance_type" {}

variable "vpc_cidr" {}
variable "instance_type" {}
variable "key_name" {}

variable "profile_name" {
  description = "AWS profile name for authentication"
  type = string
}
variable "name" {
  description = "Prefix for tagging resources"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
}

variable "private_subnet_cidr_1" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
}


#### later you can do this only for your wifi to check the connectivity of k8s cluster

# EKS Node Group Variables
## Placeholder space you can create if required

variable "coredns_version" {
  description = "Version of CoreDNS add-on"
  type        = string
}

variable "vpc_cni_version" {
  description = "Version of VPC CNI add-on"
  type        = string
}

variable "kube_proxy_version" {
  description = "Version of kube-proxy add-on"
  type        = string
}

variable "ebs_csi_version" {
  description = "Version of EBS CSI add-on"
  type        = string
}
