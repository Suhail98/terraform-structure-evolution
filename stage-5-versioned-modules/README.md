# Stage 5 — versioned modules and live environments

```
terraform-modules/    how we build a capability      →  released, tagged, tested
  networking/
  kubernetes-platform/
terraform-live/       which version runs here        →  consumes a pinned release
  dev/                v5.3.0
  staging/            v5.2.0
  prod/               v5.2.0
  customer-a/         v5.2.0   canary
  customer-b/         v5.1.0   behind, deliberately
```

Two repositories is not the idea. **Live environments consuming explicit versions
of infrastructure modules** is the idea — and it works just as well in one
repository with per-module tags, which is what this directory does.

## The line that matters

```hcl
module "platform" {
  source = "git::https://github.com/Suhail98/terraform-structure-evolution.git//stage-5-versioned-modules/terraform-modules/kubernetes-platform?ref=kubernetes-platform/v5.3.0"
}
```

`?ref=` is the release boundary. It puts the platform generation into a pull
request diff, gives `git log` on a `main.tf` the meaning of "this environment's
upgrade history", and makes the rollback question answerable: not "what did the
module look like in March?" but "v5.2.0".

## The tags are real

This is not a diagram. The tags exist in this repository, the module content
genuinely differs between them, and each release commit is a real change:

```sh
git log --oneline --decorate
git diff kubernetes-platform/v5.2.0 kubernetes-platform/v5.3.0 -- stage-5-versioned-modules/terraform-modules/kubernetes-platform
```

`terraform init` in any directory under `terraform-live/` fetches the pinned tag
over HTTPS and will show you the difference between environments for itself.

## What this replaces

The alternative is a conditional, and conditionals accumulate:

```hcl
enable_new_autoscaler = var.environment == "dev"
enable_new_networking = var.environment != "prod"
enable_feature_x      = var.customer == "customer-a"
```

One or two are harmless. Enough of them and the module stops describing what the
platform *is* and starts describing every transitional state it has ever been in
— with no way to remove one, because nobody can prove which environment still
depends on it.

## What it costs

Four live generations is a support matrix. See
[terraform-live/VERSIONS.md](terraform-live/VERSIONS.md) and
[docs/upgrade-policy.md](../docs/upgrade-policy.md). Versioning moved the
complexity; it did not delete it.

```sh
# A module is a product, so it has tests.
terraform -chdir=stage-5-versioned-modules/terraform-modules/kubernetes-platform init -backend=false
terraform -chdir=stage-5-versioned-modules/terraform-modules/kubernetes-platform test

# A live environment fetches its pinned release.
terraform -chdir=stage-5-versioned-modules/terraform-live/dev init -backend=false
```
