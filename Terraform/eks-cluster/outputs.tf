output "public_ip" {
  value = module.ec2.public_ip
}
output "oidc_issuer_url" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "vpc_id" {
  value = module.network.vpc_id
}