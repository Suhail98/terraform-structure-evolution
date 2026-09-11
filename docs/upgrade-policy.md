# Upgrade policy

Versioning does not remove complexity. It moves it out of the module and into a
support matrix, where at least you can see it.

## The matrix is the cost

```
customer-a  v5.3.0
customer-b  v5.2.0
customer-c  v4.9.0
customer-d  v4.4.0
```

Every customer can evolve independently, and now somebody supports four
generations of infrastructure: four sets of behaviour to reason about during an
incident, four targets for a security fix, four answers to "does this
environment have that input?"

If environments can stay on old versions forever, versioning becomes technical
debt with better labels.

## A policy makes the divergence bounded

| Release | Status | What it means |
| --- | --- | --- |
| `v5.3.0` | Current | New environments start here; fixes land here first |
| `v5.2.0` | Supported | Security fixes backported; no new inputs |
| `v5.1.0` | Upgrade needed | Named upgrade window agreed with the owner |
| `< v5.1.0` | Unsupported | Breakage is a migration project, not an incident |

Two supported releases behind current is a defensible default. The exact numbers
matter far less than having them written down, because an unwritten policy always
resolves to "forever".

**Controlled divergence, not permanent divergence.**

## What a release needs

A module you are asking five environments to adopt is a product, and needs
product machinery:

- **Semantic versions that mean something.** Major when a plan can destroy
  something; minor when the interface grows; patch when behaviour is unchanged.
- **A changelog written for the consumer,** saying what breaks and what to do —
  see [the kubernetes-platform changelog](../stage-5-versioned-modules/terraform-modules/kubernetes-platform/CHANGELOG.md).
- **Tests that run without an AWS account,** so they run on every pull request —
  see [the test suite](../stage-5-versioned-modules/terraform-modules/kubernetes-platform/tests/defaults.tftest.hcl).
- **A `moved` block or a documented migration** for anything that changes a
  resource address. "Re-plan and see" is not an upgrade procedure.
- **Visibility into who runs what** — [VERSIONS.md](../stage-5-versioned-modules/terraform-live/VERSIONS.md),
  generated rather than maintained by hand.

## Deprecation that actually completes

1. Release the replacement alongside the old input.
2. Mark the old one deprecated in the changelog, with the release that removes it.
3. Fail CI on any live configuration still setting it.
4. Remove it in the next major.

Step 3 is the one that gets skipped, and it is the only one that makes step 4
possible. If you cannot list every environment still using an input, you cannot
remove it — which is the same problem the environment conditionals had, one level
up.
