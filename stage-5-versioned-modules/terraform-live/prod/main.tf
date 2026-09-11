# prod - platform v5.1.0
#
# Note what is absent: no `var.environment == "prod"` conditionals anywhere in
# the module. Production differs from dev in its inputs and in its pinned
# version, both of which are readable here in twenty lines.

module "networking" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0"

  name               = "prod"
  cidr               = "10.30.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = false
}

module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.1.0"

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

output "cluster_name" {
  description = "Name of the production EKS cluster."
  value       = module.platform.cluster_name
}
