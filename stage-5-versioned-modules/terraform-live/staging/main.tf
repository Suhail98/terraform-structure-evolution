# staging - platform v5.2.0
#
# One release behind dev, deliberately. Staging is where v5.3.0 goes after dev
# has held it, and the gap between these two files is the only record of what is
# still unproven.

module "networking" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0"

  name               = "staging"
  cidr               = "10.20.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = true
}

module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.2.0"

  name       = "staging"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    default = {
      instance_types = ["m7g.large"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }

  log_retention_days = 30
}

output "cluster_name" {
  description = "Name of the staging EKS cluster."
  value       = module.platform.cluster_name
}
