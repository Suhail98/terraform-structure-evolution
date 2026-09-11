# The root configuration now reads as a description of the platform rather than
# an inventory of cloud primitives. Four module calls, three edges between them.
#
# Compare this with the stage 3 root module, which had to know that subnets come
# from the VPC module, that EKS needs the private ones, that RDS needs the
# database ones, and that observability needs a cluster name.

module "networking" {
  source = "../../modules/networking"

  name               = "dev"
  cidr               = "10.10.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = true
}

module "platform" {
  source = "../../modules/kubernetes-platform"

  name       = "dev"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    default = {
      instance_types = ["m7g.large"]
      min_size       = 1
      max_size       = 4
      desired_size   = 2
    }
  }

  log_retention_days = 7
}

module "database" {
  source = "../../modules/postgres-platform"

  name                       = "dev"
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.database_subnet_ids
  allowed_security_group_ids = [module.platform.cluster_security_group_id]

  instance_class        = "db.t4g.micro"
  backup_retention_days = 1
}

output "cluster_name" {
  description = "Name of the development EKS cluster."
  value       = module.platform.cluster_name
}
