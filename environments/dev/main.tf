module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
