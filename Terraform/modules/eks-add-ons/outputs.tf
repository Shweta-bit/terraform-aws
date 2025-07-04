output "installed_addons" {
  value = [
    aws_eks_addon.coredns_addon,
    aws_eks_addon.vpc_cni_addon,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.ebs_csi_driver
  ]
}
