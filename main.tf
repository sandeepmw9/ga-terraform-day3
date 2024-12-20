module "vpc" {
  source     = "./modules/vpc"
  vpc_name   = "${var.vpc_name}-${terraform.workspace}"
  cidr_block = var.cidr_block
}

module "ec2" {
  source           = "./modules/ec2"
  instance_name    = "${var.instance_name}-${terraform.workspace}"
  instance_type    = var.instance_type
  public_subnet_id = module.vpc.public_subnet_id
  vpc_id           = module.vpc.vpc_id
}