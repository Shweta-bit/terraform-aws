output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_nodegroup_role_arn" {
  description = "ARN of the EKS Nodes IAM role"
  value = aws_iam_role.eks_nodegroup_role.arn
}

output "amazon_eks_cluster_policy_attachment" {
  description = "Arn of eks cluster policy"
  value = aws_iam_role_policy_attachment.cluster_policy_attachment
}

output "service_policy_attachment" {
  value = aws_iam_role_policy_attachment.service_policy_attachment
}

output "amazon_eks_vpc_resource_controller_policy_attachment" {
  value = aws_iam_role_policy_attachment.amazon_eks_vpc_resource_controller_policy_attachment
}

