import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawn } from "node:child_process";
import { existsSync, mkdirSync, openSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event) => ({
    systemPrompt: event.systemPrompt + `\n\nFAKA Overnight is attached to this project. Work normally for ordinary interactive coding tasks. If the user explicitly asks to finish the whole project, work unattended/autonomously for hours, continue while they sleep, or otherwise requests a long-running project-completion campaign, use the faka_overnight tool. Do not require a duplicate SPEC when README/AGENTS/CLAUDE/docs/tests already define the project. Treat repository docs, tests, code, Git, and the user's current goal as source of truth.`,
  }));

  pi.registerTool({
    name: "faka_overnight",
    label: "FAKA Overnight",
    description: "Start a detached autonomous project-completion campaign using fresh Pi/Ralph contexts.",
    promptSnippet: "Start an unattended fresh-context FAKA/Ralph campaign for a project-level goal.",
    promptGuidelines: [
      "Use faka_overnight only when the user explicitly asks for long-running/unattended whole-project work.",
      "Pass the user's actual goal; do not invent extra product requirements.",
    ],
    parameters: Type.Object({
      goal: Type.String({ description: "The user's project-level end goal." }),
      hours: Type.Optional(Type.Number({ minimum: 0.1, maximum: 72 })),
    }),
    async execute(_id, params, _signal, _onUpdate, ctx) {
      const cwd = ctx.cwd;
      const faka = join(cwd, ".faka");
      const runner = join(faka, "overnight.sh");
      if (!existsSync(runner)) {
        return { content: [{ type: "text", text: "FAKA is not installed in this project." }], details: { started: false } };
      }

      mkdirSync(join(faka, "task"), { recursive: true });
      mkdirSync(join(faka, "logs"), { recursive: true });
      writeFileSync(join(faka, "task", "GOAL.md"), `# Current FAKA Goal\n\n${params.goal.trim()}\n`, "utf8");

      const out = join(faka, "logs", "overnight.stdout.log");
      const err = join(faka, "logs", "overnight.stderr.log");
      const child = spawn(runner, [], {
        cwd,
        detached: true,
        stdio: ["ignore", openSync(out, "a"), openSync(err, "a")],
        env: { ...process.env, FAKA_HOURS: String(params.hours ?? 8) },
      });
      child.unref();

      return {
        content: [{ type: "text", text: `Started FAKA Overnight in background (PID ${child.pid ?? "unknown"}) for up to ${params.hours ?? 8}h. Logs: .faka/logs/overnight.stdout.log` }],
        details: { started: true, pid: child.pid, hours: params.hours ?? 8 },
      };
    },
  });
}
