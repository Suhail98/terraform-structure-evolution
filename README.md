# Terraform structure evolution

Working examples for every stage in
**[How Terraform structure evolves: from main.tf to versioned modules at scale](https://suhailfawzy.com/#/writing/terraform-structure-evolution)**.

The article argues that Terraform architecture should evolve with the
infrastructure it manages, and that **every improvement introduces the next
problem**. This repository is that argument in code: five structures, each one
valid at its own scale, each one carrying the limitation that motivates the next.

> The goal is not the cleanest folder structure or eliminating every duplicated
> line. At scale, what matters is predictability, blast radius, independent
> environment evolution and controlled infrastructure promotion.

---

## The progression

| Stage | Structure | What it buys | What it costs |
| --- | --- | --- | --- |
| **[1](stage-1-single-root-module)** | One `main.tf` | You can read the whole thing | Stops being navigable |
| **[2](stage-2-organised-files)** | Organised `.tf` files | You know where to look | Still one module; no reuse |
| **[3](stage-3-reusable-modules)** | `modules/` + `environments/` | Reuse without duplication | Root module becomes the integration layer |
| **[4](stage-4-platform-modules)** | Cohesive capability modules | Boundaries match lifecycles | Environments still evolve together |
| **[5](stage-5-versioned-modules)** | Versioned modules + live environments | Independent evolution, controlled promotion | A support matrix |

Each directory has its own README explaining what changed, what it solved, and
what it broke.

## The line the whole article is about

```hcl
module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.3.0"
}
```

`?ref=` is a release boundary. It turns "which generation of the platform runs
here?" from archaeology into a line in a pull request, and it is the difference
between a module you share and a module you ship.

**The tags in this repository are real.** `kubernetes-platform/v5.1.0`, `v5.2.0`
and `v5.3.0` are distinct commits with genuinely different module content, and
the live environments below are pinned to different ones on purpose:

| Environment | Pinned to | Why |
| --- | --- | --- |
| [`dev`](stage-5-versioned-modules/terraform-live/dev) | `v5.3.0` | First adopter |
| [`staging`](stage-5-versioned-modules/terraform-live/staging) | `v5.2.0` | Proving the previous release |
| [`prod`](stage-5-versioned-modules/terraform-live/prod) | `v5.2.0` | Internal production |
| [`customer-a`](stage-5-versioned-modules/terraform-live/customer-a) | `v5.2.0` | Canary customer |
| [`customer-b`](stage-5-versioned-modules/terraform-live/customer-b) | `v5.1.0` | Quarterly upgrade window |

```sh
git log --oneline --decorate
git diff kubernetes-platform/v5.2.0 kubernetes-platform/v5.3.0 -- stage-5-versioned-modules/terraform-modules/kubernetes-platform
```

## Running it

Everything here validates. Nothing here needs an AWS account.

```sh
# Any stage
terraform -chdir=stage-4-platform-modules/environments/prod init -backend=false
terraform -chdir=stage-4-platform-modules/environments/prod validate

# The module test suite runs against mocked providers - no credentials, no resources
terraform -chdir=stage-5-versioned-modules/terraform-modules/kubernetes-platform init -backend=false
terraform -chdir=stage-5-versioned-modules/terraform-modules/kubernetes-platform test

# A live environment fetches its pinned release over HTTPS
terraform -chdir=stage-5-versioned-modules/terraform-live/dev init -backend=false
```

`terraform apply` would create real, billable infrastructure and is not the point
of any of this. The `backend "s3" {}` blocks are partial on purpose — a real
estate supplies the bucket and key at `init` time, which is what keeps one
configuration per environment honest. See
[docs/state-boundaries.md](docs/state-boundaries.md).

Requires Terraform 1.11+ (write-only arguments and `mock_provider`). Everything
structural here applies to OpenTofu; check feature parity before relying on the
newer sensitive-value primitives.

## What structure does not solve

Two decisions survive any repository layout, and both are covered in
[`docs/`](docs):

- **[State boundaries](docs/state-boundaries.md)** — repository structure and
  state structure are different decisions. State is an operational boundary, not
  a folder convention.
- **[Secrets and reproducibility](docs/secrets.md)** — `sensitive = true` is
  redaction, not protection. Write-only arguments, ephemeral values, and why
  `.terraform.lock.hcl` belongs in the repository.

Plus the two that decide whether the structure holds up:

- **[Module boundaries](docs/module-boundaries.md)** — the questions that tell
  you whether a proposed module is too small, too large, or right.
- **[Upgrade policy](docs/upgrade-policy.md)** — versioning moves complexity into
  a support matrix. Controlled divergence, not permanent divergence.

## The point

```
ONE ROOT MODULE            simple, eventually unnavigable
        ↓
ORGANISED .TF FILES        readable, still not reusable
        ↓
REUSABLE MODULES           reusable, easily over-fragmented
        ↓
PLATFORM MODULES           right boundaries, environments still coupled
        ↓
VERSIONED + LIVE           independent evolution, controlled promotion
        ↓
RELEASE MANAGEMENT         tests, upgrades, support windows, deprecation
```

A structure that looks absurd for twenty resources can be exactly right for a
platform running many environments, and one that worked beautifully for a single
application becomes a liability across several products, teams, regions and
customer deployments.

Good Terraform architecture is not a structure that eliminates complexity. It is
one that puts complexity where it can be controlled.

---

**Full write-up:** [How Terraform structure evolves: from main.tf to versioned modules at scale](https://suhailfawzy.com/#/writing/terraform-structure-evolution)
· [suhailfawzy.com](https://suhailfawzy.com)

Licensed under the [MIT License](LICENSE).
