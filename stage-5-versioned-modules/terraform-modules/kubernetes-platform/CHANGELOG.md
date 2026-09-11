# Changelog — `kubernetes-platform`

Releases are tagged `kubernetes-platform/vX.Y.Z`. A live environment adopts a
release by changing one `?ref=` and planning; nothing arrives on its own.

## v5.2.0

- Added `endpoint_public_access`, defaulting to `false`.
- **Action required on upgrade** for any cluster that was relying on the previous
  public endpoint: set `endpoint_public_access = true` explicitly, or the plan will
  propose closing it.

## v5.1.0

- Node groups moved from a list to a map keyed by name, so adding or removing a
  pool no longer renumbers the others.
- **Breaking for state:** upgrading requires `moved` blocks from
  `aws_eks_node_group.this[0]` to `aws_eks_node_group.this["<name>"]`. Without
  them the plan proposes destroying and recreating every node group.

## v5.0.0

- **Breaking:** IAM roles moved into this module from the caller's root
  configuration. Import the existing roles or let the module recreate them during
  a maintenance window.
