# customer-b - platform v5.1.0, behind
#
# This is the cost of independent versioning, made visible. Customer B is two
# releases behind because their upgrade window is quarterly, and somebody is
# still supporting v5.1.0 for them.
#
# Note the pin: this environment predates the `endpoint_public_access` input
# added in v5.2.0, so it cannot set it. That is exactly what a version boundary
# is for - the environment is not silently carried onto an interface it has not
# been tested against.

module "networking" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0"

  name               = "customer-b"
  cidr               = "10.50.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = false
}

module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.1.0"

  name       = "customer-b"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    workload = {
      instance_types = ["m7g.large"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }

  log_retention_days = 90
}

output "cluster_name" {
  description = "Name of the customer-b EKS cluster."
  value       = module.platform.cluster_name
}
