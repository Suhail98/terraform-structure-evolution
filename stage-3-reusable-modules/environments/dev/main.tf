# Dev consumes the shared modules by relative path.
#
# Note what is NOT expressed here: which *version* of the vpc or postgres module
# this environment runs. Both dev and prod point at ../../modules, so they are
# pinned to whatever is on the current commit. Editing a module does not change
# prod until prod is applied - but there is no contract saying dev is allowed to
# be a generation ahead. That gap is what stage 5 closes.

module "network" {
  source = "../../modules/vpc"

  name               = "dev"
  cidr               = "10.10.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b"]
}

module "postgres" {
  source = "../../modules/postgres"

  name           = "dev"
  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.database_subnet_ids
  instance_class = "db.t4g.micro"
  multi_az       = false
}

output "database_endpoint" {
  description = "Connection endpoint for the development database."
  value       = module.postgres.endpoint
}
