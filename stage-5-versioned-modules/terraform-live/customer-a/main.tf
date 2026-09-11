# customer-a - platform v5.2.0, canary
#
# The first customer to take a new platform release. A canary is only meaningful
# if it is named somewhere: see ../VERSIONS.md.

module "networking" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/networking?ref=networking/v3.2.0"

  name               = "customer-a"
  cidr               = "10.40.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = false
}

module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.2.0"

  name       = "customer-a"
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  node_groups = {
    workload = {
      instance_types = ["m7g.xlarge"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      labels         = { tenant = "customer-a" }
    }
  }

  log_retention_days = 90
}

output "cluster_name" {
  description = "Name of the customer-a EKS cluster."
  value       = module.platform.cluster_name
}
