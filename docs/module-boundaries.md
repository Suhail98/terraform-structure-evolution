# Where to put a module boundary

A module boundary is an architectural boundary. Folder categories are not.

## The questions

Ask these about a proposed module, in this order. A "no" is not a veto, but two
or three of them mean the boundary is in the wrong place.

| Question | What a "no" tells you |
| --- | --- |
| Do these resources share a lifecycle? | They will be versioned together for no reason, and one will hold the other back |
| Are they owned by the same team? | The boundary becomes a coordination cost paid on every change |
| Do they normally change together? | Every release touches resources nobody asked to touch |
| Are their dependencies tightly coupled? | The caller will have to reassemble what you split |
| Should they share a release cycle? | They need independent versions, so they need independent modules |
| Is the combined blast radius acceptable? | Split until it is |

## Too small

A module per cloud service is maximally reusable and pushes the entire
integration problem up into the root module:

```hcl
module "vpc" {}
module "subnets"          { vpc_id     = module.vpc.id }
module "security_groups"  { vpc_id     = module.vpc.id }
module "eks"              { subnet_ids = module.subnets.private_ids }
module "postgres"         { subnet_ids = module.subnets.database_ids }
module "observability"    { cluster_name = module.eks.cluster_name }
```

Every arrow in that graph is a fact about the platform that now lives in the root
module of every environment. Add a seventh module and you edit five root modules.

## Too large

```
modules/data/     PostgreSQL, Redis, Kafka, OpenSearch, DynamoDB, S3
```

They are all "data", and they share nothing else: not a lifecycle, not an owner,
not an upgrade cadence, not a failure mode. This is `main.tf` with a new address.

## About right

```
modules/
  networking/           VPC, subnets, NAT, routes
  kubernetes-platform/  cluster, IAM, node groups, security group, logging
  postgres-platform/    instance, parameter group, backups, network, alarms
  observability/
  security-baseline/
```

The test that actually settles it: *has anyone ever deployed one of these without
the others, on purpose?* Nobody creates an EKS cluster and decides three weeks
later whether it should have a node IAM role. Nobody provisions RDS and opens a
separate ticket for whether backups are on.

## A boundary is not free

Each module is an interface you now have to keep stable, a set of inputs to
document, a set of outputs somebody will depend on, and a version to manage. That
cost is worth paying where a real boundary exists and is pure overhead where one
does not.

Solve the problem you actually have.
