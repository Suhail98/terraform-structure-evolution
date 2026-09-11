# Stage 1 — one root module

Everything in `main.tf`. Terraform, provider, variables, resources and outputs.

**What it buys you:** simplicity. One file to read, no indirection, no module
interface to design before you have learned what the infrastructure needs to be.

**Where it breaks:** not at a line count, but when the file stops being
navigable — networking, compute, IAM, databases, storage, DNS, monitoring and
security all interleaved, and no obvious place to look for any of them.

**The next problem:** legibility. That is what [stage 2](../stage-2-organised-files)
addresses.

```sh
terraform -chdir=stage-1-single-root-module init -backend=false
terraform -chdir=stage-1-single-root-module validate
```
