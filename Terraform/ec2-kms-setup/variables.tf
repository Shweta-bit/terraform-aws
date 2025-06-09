variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "availability_zone" {}
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
