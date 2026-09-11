# Stage 3 — reusable modules

```
modules/           how to build a thing
  vpc/
  postgres/
environments/      where it gets built, and with what inputs
  dev/
  prod/
```

Each environment is its own root configuration with its own state, consuming the
shared modules by relative path. `dev` runs a `db.t4g.micro` single-AZ instance,
`prod` runs a Multi-AZ `db.m7g.large` — same module, different inputs.

**What it buys you:** reuse without duplication, and a real state boundary per
environment.

**The trap:** if a module is worth making, make one per cloud service — VPC,
subnets, security groups, EKS, node groups, IAM, PostgreSQL, Redis, S3, SQS,
Route 53. Maximum reuse. And now the root module is the integration layer for
the whole platform, threading one module's output into the next module's input
four levels deep.

Reuse went up; complexity moved upward. Which is worth asking directly: should a
module really map one-to-one to a cloud service? [Stage 4](../stage-4-platform-modules)
argues it often should not.

```sh
terraform -chdir=stage-3-reusable-modules/environments/dev init -backend=false
terraform -chdir=stage-3-reusable-modules/environments/dev validate
```
