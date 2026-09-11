# dev - platform v5.2.0
#
# Every live environment is the same shape: a pinned module version and the
# answers that belong to this environment. The `?ref=` is the whole point. It is
# the only line that says which generation of the platform runs here, it shows up
# in a pull request diff, and `git log` on this file is the environment's
# upgrade history.
#
# Dev adopts first. If v5.3.0 is wrong, it is wrong here, a week before it is
# anywhere near a customer.

module "networking" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0"

  name               = "dev"
  cidr               = "10.10.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = true
}

module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.2.0"

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

output "cluster_name" {
  description = "Name of the development EKS cluster."
  value       = module.platform.cluster_name
}
