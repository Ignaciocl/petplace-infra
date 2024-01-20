module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = "all_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = var.vpc_cidr
  private_subnets = ["10.0.105.0/24"]

  create_igw = true

  enable_dynamodb_endpoint = true
  enable_nat_gateway = var.use_nat
  single_nat_gateway = var.use_nat

  tags = {
    Terraform = "true"
  }
}
