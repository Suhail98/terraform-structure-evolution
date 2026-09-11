# Secrets, state and reproducibility

Structure does not solve this. A perfectly organised repository can still write a
database password into a state file.

## `sensitive = true` is redaction, not protection

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

This stops the value appearing in CLI output and plan summaries. It does **not**
stop the value being persisted: pass it to a normal resource argument and it is
in the state file, in plaintext, forever — and in the plan file too, which is
often the artifact a CI system stores.

Treat `sensitive` as a defence against shoulder-surfing and log scraping. It is
not a defence against anyone who can read your state bucket.

## Values that should never enter the artifacts

**Write-only arguments** (Terraform 1.11+, provider support required) send a value
to the API without storing it. The paired `_wo_version` is what tells Terraform to
send it again:

```hcl
resource "aws_db_instance" "this" {
  password_wo         = ephemeral.aws_secretsmanager_secret_version.db.secret_string
  password_wo_version = 1
}
```

**Ephemeral values and resources** exist only during a run — never in state, never
in the plan:

```hcl
ephemeral "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
}
```

**Better still, do not handle it at all.** Let the provider generate and manage it:

```hcl
resource "aws_db_instance" "this" {
  manage_master_user_password = true   # AWS creates and rotates it in Secrets Manager
}
```

The [`postgres-platform` module](../stage-4-platform-modules/modules/postgres-platform/main.tf)
takes this route. The password never exists in Terraform, so there is nothing to
leak, rotate or redact.

## None of which replaces the boring controls

- Remote state in a private bucket, encrypted, versioned, with access logged.
- State locking, so two pipelines cannot apply at once.
- Least-privilege pipeline identity — OIDC and a short-lived role, not a static
  access key in a CI secret.
- A secret manager for application secrets, read at runtime, not at plan time.

## Reproducibility is the other half

Commit `.terraform.lock.hcl` for every root configuration. It pins the exact
provider versions and checksums that configuration was initialised with, so a
pipeline run in six months resolves the same providers a developer resolved
today.

Module versions and provider versions are different dependencies, and both need
deliberate control:

| Dependency | Pinned by | Lives in |
| --- | --- | --- |
| Module release | `?ref=kubernetes-platform/v5.3.0` | The `source` line, reviewed in a pull request |
| Provider version | `version = "~> 6.0"` plus `.terraform.lock.hcl` | `versions.tf` and the committed lock file |

A configuration that pins its module release and floats its provider version is
only half reproducible, and the half that floats is the one that changes while
nobody is looking.
