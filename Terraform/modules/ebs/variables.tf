variable "availability_zone" {
  description = "The AZ in which to create the volume"
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume in GiB"
  type        = number
  default     = 8
}

variable "kms_key_id" {
  description = "KMS Key ARN to use for EBS encryption"
  type        = string
  default     = "alias/aws/ebs"  # Uses AWS-managed key
}

