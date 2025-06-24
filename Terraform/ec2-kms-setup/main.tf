module "network" {
  source              = "../modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  availability_zone   = var.availability_zone
  name                = var.name   
  private_subnet_cidr = var.private_subnet_cidr  
}

module "ec2" {
  source         = "../modules/ec2"
  instance_type  = var.instance_type
  key_name       = module.key_pair.key_name
  subnet_id      = module.network.subnet_id
  sg_id          = module.network.sg_id
  name           = var.name
}

module "ebs" {
  source = "../modules/ebs"
  availability_zone = var.availability_zone
  volume_size       = 8
}


module "key_pair" {
  source    = "../modules/key_pair"
  key_name  = "sc-key"
}