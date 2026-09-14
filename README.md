# FAKA Overnight

Max-SNR unattended coding supervisor for Pi + Ralph + local LLMs.

## Install once in a project

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/faka-overnight/main/install.sh | bash
```

Then simply:

```bash
pi
```

Use Pi normally. For ordinary tasks FAKA stays out of the way.

For a long-running autonomous campaign, say naturally:

```text
finish this project while I sleep
```

The attached Pi extension starts the Ralph supervisor in the background. No duplicate manual SPEC is required when the repository already has README/AGENTS/CLAUDE/docs/tests that define the target.

FAKA persists the current user goal, uses fresh Pi/Ralph worker contexts, keeps durable state in the repo/filesystem, and treats `.faka/verify.sh` as the external acceptance gate.

You can still launch directly:

```bash
.faka/overnight.sh "finish this project according to existing requirements"
```

On first `pi` launch, Pi may ask you to trust the project because `.pi/extensions/faka.ts` is project-local. After trust, it loads automatically.
