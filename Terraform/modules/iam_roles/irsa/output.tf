output "ebs_csi_driver_role_arn" {
  value = aws_iam_role.ebs_csi_driver.arn
}
output "cluster_autoscaler_role_arn"{
  value=aws_iam_role.cluster_autoscaler.arn
}