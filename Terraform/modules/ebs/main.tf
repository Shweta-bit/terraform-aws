data "aws_kms_key" "ebs" {
  key_id = var.kms_key_id
}



resource "aws_ebs_volume" "secure_volume" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  encrypted         = true
  kms_key_id        = data.aws_kms_key.ebs.arn

  tags = {
    Name = "kms-encrypted-ebs"
  }
}
