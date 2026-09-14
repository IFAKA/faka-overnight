# FAKA Overnight

Max-SNR unattended coding supervisor for **Pi + Ralph + local LLMs**.

The goal is not one giant context. The goal is repeated fresh coding contexts with durable state in the repository:

```text
SPEC → fresh Pi worker → code/test → checkpoint → fresh worker → ... → acceptance PASS
```

## One-line install into the current project

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/faka-overnight/main/install.sh | bash
```

The installer:

1. validates Node.js >= 22.22.1,
2. installs/updates `@earendil-works/pi-coding-agent@0.85.1`,
3. installs `@lnilluv/pi-ralph-loop`,
4. initializes local Git if needed,
5. installs `.faka/` into the current directory,
6. preserves an existing `SPEC.md` / plan / open-questions state on reinstall,
7. does **not** overwrite your existing Pi provider credentials or model configuration.

Then:

```bash
$EDITOR .faka/task/SPEC.md
.faka/overnight.sh
```

## Existing local OpenAI-compatible backend

Default health endpoint:

```text
http://127.0.0.1:8000/v1/models
```

Override:

```bash
FAKA_BACKEND_URL=http://127.0.0.1:8080/v1 .faka/overnight.sh
```

For automatic backend recovery:

```bash
export FAKA_BACKEND_START='your model server start command'
.faka/overnight.sh
```

## What persists between fresh contexts?

- source code and tests
- Git history
- `.faka/task/SPEC.md`
- `.faka/task/IMPLEMENTATION_PLAN.md`
- `.faka/task/OPEN_QUESTIONS.md`
- Ralph's rolling progress/run state

Full historical chat context is deliberately **not** carried forever.

## Completion

The model's claim that it is done is insufficient. The Ralph completion gate reruns `.faka/verify.sh`.

Edit that verifier to encode the actual project acceptance boundary, including E2E tests when appropriate.

## Safety

Pi packages/extensions execute with system access. Review code before using an unattended package. For high-autonomy overnight runs, prefer a disposable worktree/container/VM and keep secrets outside writable project state.
