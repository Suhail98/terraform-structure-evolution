# Stage 2 — organised `.tf` files

The same configuration as [stage 1](../stage-1-single-root-module), split by
concern: `networking.tf`, `compute.tf`, `database.tf`, `security.tf`.

**What it buys you:** navigability. Reviewing a subnet change means opening
`networking.tf`.

**What it does not change:** Terraform loads every `.tf` file in a directory as
a single module. Nine files here and one large `main.tf` are the same root
module from Terraform's point of view. No boundary has been created — only a
filing system.

**The next problem:** reuse. Add `dev`, `staging` and `prod` and you either copy
this directory three times and watch it drift, or you need modules. That is
[stage 3](../stage-3-reusable-modules).

```sh
terraform -chdir=stage-2-organised-files init -backend=false
terraform -chdir=stage-2-organised-files validate
```
