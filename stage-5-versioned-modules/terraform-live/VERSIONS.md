# Platform version matrix

The one page somebody has to be able to open during an incident to answer "which
generation of the platform is this environment running?"

| Environment | `kubernetes-platform` | `networking` | Role |
| --- | --- | --- | --- |
| `dev` | `v5.2.0` | `v3.2.0` | First adopter |
| `staging` | `v5.1.0` | `v3.2.0` | Pre-production validation |
| `prod` | `v5.1.0` | `v3.2.0` | Internal production |
| `customer-a` | `v5.1.0` | `v3.2.0` | Canary customer |
| `customer-b` | `v5.1.0` | `v3.2.0` | Quarterly upgrade window |

## Support policy

| Release | Status |
| --- | --- |
| `v5.2.0` | Current |
| `v5.1.0` | Supported |
| `< v5.1.0` | Unsupported |

2 live generations is already a support matrix. The goal is controlled
divergence, not permanent divergence — see [../../docs/upgrade-policy.md](../../docs/upgrade-policy.md).

## Promotion

```
build v5.2.0 ──▶ test ──▶ release
                            │
                            ▼
                           dev ──▶ validate ──▶ staging ──▶ validate
                                                               │
                                                               ▼
                                                      canary customer
                                                               │
                                                               ▼
                                                    remaining customers
```

Each arrow is a pull request changing one `?ref=`. Nothing moves on its own, and
`git log` on a `main.tf` in this directory is that environment's upgrade history.

## This table is generated, not maintained by hand

Keeping it accurate by discipline does not survive contact with a Friday. Derive
it:

```sh
grep -rho 'ref=[a-z-]*/v[0-9.]*' */main.tf | sort -u
```

The `versions` job in CI runs the same check and fails the build when this table
and the configurations disagree.
