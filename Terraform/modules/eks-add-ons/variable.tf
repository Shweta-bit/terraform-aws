variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "coredns_version" {
  description = "Version of CoreDNS add-on"
  type        = string
  default     = "v1.11.4-eksbuild.14"
}

variable "vpc_cni_version" {
  description = "Version of VPC CNI add-on"
  type        = string
  default     = "v1.19.6-eksbuild.1"
}

variable "kube_proxy_version" {
  description = "Version of kube-proxy add-on"
  type        = string
  default     = "v1.31.9-eksbuild.2"
}

variable "ebs_csi_version" {
  description = "Version of EBS CSI driver add-on"
  type        = string
  default     = "v1.45.0-eksbuild.2"
}

variable "ebs_csi_driver_role_arn" {}
