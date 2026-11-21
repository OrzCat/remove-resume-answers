// remove-resume-answers OpenCode plugin
// Removes Claude Code session answers blocked or refused by the safety classifier
import { tool } from "@opencode-ai/plugin";

export default async (ctx) => {
  return {
    tool: {
      "remove-resume-answers": tool({
        description: "Clean up Claude Code session answers blocked or refused by the safety mechanism",
        args: {
          project: tool.schema.string().describe("Optional: session file path or project directory (default: current directory)"),
        },
        async execute({ project }) {
          const { execSync } = await import("node:child_process");
          const { existsSync } = await import("node:fs");
          const { join } = await import("node:path");

          // Find the script - check common locations
          const possiblePaths = [
            join(process.cwd(), "scripts", "remove_resume_answers.sh"),
            join(ctx?.root || process.cwd(), "scripts", "remove_resume_answers.sh"),
          ];

          let scriptPath = null;
          for (const p of possiblePaths) {
            if (existsSync(p)) {
              scriptPath = p;
              break;
            }
          }

          if (!scriptPath) {
            return "❌ 無法找到 remove_resume_answers.sh 腳本。請確認 repo 已正確克隆。";
          }

          try {
            const result = execSync(
              `bash "${scriptPath}" ${project ? `"${project}"` : ""}`,
              { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 }
            );
            return `✅ 清理完成\n\n${result}`;
          } catch (err) {
            return `❌ 清理失敗：${err.message}`;
          }
        },
      }),
    },
  };
};
