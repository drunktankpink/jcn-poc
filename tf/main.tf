# vpc
module "vpc" {
  source = "./modules/vpc"

  vpc_name          = "jcn-test"
  resource_location = "eu-west-2"
  vpc_cidr_block    = "172.16.0.0/16"
}
