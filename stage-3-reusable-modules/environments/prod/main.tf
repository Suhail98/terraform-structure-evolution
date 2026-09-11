# Production consumes the same modules, differing only in inputs.
#
# This is the payoff of stage 3: how PostgreSQL is built is defined once, and
# each environment decides how large, how available and on which network.

module "network" {
  source = "../../modules/vpc"

  name               = "prod"
  cidr               = "10.30.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
}

module "postgres" {
  source = "../../modules/postgres"

  name              = "prod"
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.database_subnet_ids
  instance_class    = "db.m7g.large"
  allocated_storage = 200
  multi_az          = true
}

output "database_endpoint" {
  description = "Connection endpoint for the production database."
  value       = module.postgres.endpoint
}
