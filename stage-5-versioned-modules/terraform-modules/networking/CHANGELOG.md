# Changelog — `networking`

## v3.2.0

- Added `single_nat_gateway` so non-production environments can run one NAT
  gateway instead of one per availability zone.
- **No action required.** Defaults to `false`, which preserves v3.1 behaviour.

## v3.1.0

- Added the `database` subnet tier and the `database_subnet_ids` output.
- **Action required on upgrade:** the new tier consumes `cidrsubnet(cidr, 8, 20+)`.
  Environments that had allocated those ranges by hand must re-plan before applying.

## v3.0.0

- **Breaking:** `azs` renamed to `availability_zones`.
- **Breaking:** subnets moved from `count` over a flat list to per-tier resources.
  Upgrading requires `moved` blocks or state surgery; see the upgrade note in the
  release.
