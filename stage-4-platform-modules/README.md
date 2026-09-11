# Stage 4 — cohesive platform modules

```
modules/
  networking/           VPC, subnet tiers, NAT egress, route tables
  kubernetes-platform/  cluster, IAM, node groups, security group, logging
  postgres-platform/    instance, parameter group, backups, network, alarms
environments/
  dev/                  4 module calls
  prod/                 the same 4, with production answers
```

A module per cloud service maximises reuse. A module per **capability** puts the
boundary where the lifecycle already is. `kubernetes-platform` owns the IAM roles
the cluster cannot exist without, because nobody has ever deployed an EKS cluster
and decided separately, three weeks later, whether it should have a node role.

**The test I apply to a proposed boundary:**

| Question | If the answer is no |
| --- | --- |
| Do these resources share a lifecycle? | They probably belong in different modules |
| Are they owned by one team? | The boundary will become a coordination cost |
| Do they normally change together? | You will version them for no reason |
| Should they be released together? | They need separate versions, so separate modules |
| Is the combined blast radius acceptable? | Split until it is |

And the counter-example: do **not** create a `data/` module holding PostgreSQL,
Redis, Kafka, OpenSearch, DynamoDB and S3 because they are all "data". That moves
the monolith from `main.tf` into `modules/data/`. See [docs/module-boundaries.md](../docs/module-boundaries.md).

**The next problem:** `dev` and `prod` both say `source = "../../modules/..."`.
They are pinned to the same commit, so nothing lets dev run a generation ahead of
production on purpose. [Stage 5](../stage-5-versioned-modules) fixes that.

```sh
terraform -chdir=stage-4-platform-modules/environments/prod init -backend=false
terraform -chdir=stage-4-platform-modules/environments/prod validate
```
