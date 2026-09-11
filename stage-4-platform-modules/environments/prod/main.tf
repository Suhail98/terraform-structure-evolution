# Identical shape to dev; different answers.
#
# This is the property worth protecting: the difference between environments is
# a set of inputs you can read in one screen, not a set of conditionals buried
# inside the modules.

module "networking" {
  source = "../../modules/networking"

  name               = "prod"
  cidr               = "10.30.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = false
}

module "platform" {
  source = "../../modules/kubernetes-platform"

  name       = "prod"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    system = {
      instance_types = ["m7g.large"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      labels         = { pool = "system" }
    }
    workload = {
      instance_types = ["m7g.2xlarge"]
      min_size       = 3
      max_size       = 20
      desired_size   = 6
      labels         = { pool = "workload" }
    }
  }

  log_retention_days = 90
}

module "database" {
  source = "../../modules/postgres-platform"

  name                       = "prod"
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.database_subnet_ids
  allowed_security_group_ids = [module.platform.cluster_security_group_id]

  instance_class        = "db.m7g.large"
  allocated_storage     = 200
  multi_az              = true
  backup_retention_days = 30
}

output "cluster_name" {
  description = "Name of the production EKS cluster."
  value       = module.platform.cluster_name
}
