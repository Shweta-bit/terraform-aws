output "volume_id" {
  description = "The ID of the created EBS volume"
  value       = aws_ebs_volume.secure_volume.id
}
