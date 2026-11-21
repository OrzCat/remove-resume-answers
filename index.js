// remove-resume-answers OpenCode plugin
// Removes Claude Code session answers blocked or refused by the safety classifier
import { tool } from "@opencode-ai/plugin";

export default async ({ directory, worktree }) => {
  return {
    tool: {
      "remove-resume-answers": tool({
        description: "Clean up Claude Code session answers blocked or refused by the safety mechanism",
        args: {
          project: tool.schema.string().optional().describe("Optional: session file path or project directory (default: current directory)"),
        },
        async execute({ project }, { directory: sessionDir }) {
          const { execSync } = await import("node:child_process");
          const { existsSync } = await import("node:fs");
          const { join } = await import("node:path");

          // 優先使用傳入的 project 參數，否則使用 session 目錄
          const targetDir = project || sessionDir || worktree || process.cwd();

          const possiblePaths = [
            join(targetDir, "scripts", "remove_resume_answers.sh"),
            join(process.cwd(), "scripts", "remove_resume_answers.sh"),
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
              `bash "${scriptPath}"`,
              { encoding: "utf8", maxBuffer: 10 * 1024 * 1024, cwd: targetDir }
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
