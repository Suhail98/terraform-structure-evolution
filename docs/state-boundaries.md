# State boundaries

Repository structure and state structure are different decisions, and getting one
right does not give you the other.

## One state per environment, at minimum

```
dev  staging  prod  customer-a  customer-b
```

These should not share a state file. Shared state means a plan for one
environment locks the others, a mistake in one can propose changes in all of
them, and access control becomes all-or-nothing.

That is why every environment in [stage 3](../stage-3-reusable-modules) onwards
is its own root configuration with its own `backend "s3" {}` block, configured at
`init` time:

```sh
terraform init \
  -backend-config="bucket=acme-tfstate" \
  -backend-config="key=live/prod/terraform.tfstate" \
  -backend-config="region=eu-west-1" \
  -backend-config="use_lockfile=true"
```

## Further splitting, when it earns itself

At enough scale one environment becomes several states:

```
customer-a/
  networking/
  platform/
  data/
```

This is worth doing when networking changes monthly and the platform changes
weekly, when different teams own them, or when a platform plan should not be able
to propose deleting a VPC.

## The cost is a dependency graph

```
network state ──▶ platform state ──▶ data state ──▶ application state
```

Every arrow is a `terraform_remote_state` read or a data source lookup, an
ordering constraint on your pipeline, and a thing that breaks when the upstream
state moves. Four states that must be applied in order are, operationally, one
big state with extra steps.

Prefer passing values explicitly over reading another environment's state where
you can:

```hcl
# Coupled to the producer's state layout and its output names.
data "terraform_remote_state" "network" {
  backend = "s3"
  config  = { bucket = "acme-tfstate", key = "live/prod/networking.tfstate" }
}

# Coupled only to the tag, which is a contract the producer controls on purpose.
data "aws_vpc" "main" {
  tags = { Name = "prod" }
}
```

## What to decide on

Not folder convention. Lifecycle, ownership, access boundaries, operational
independence, and blast radius.

**State is an operational boundary.**
