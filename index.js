// remove-resume-answers OpenCode plugin
// Removes Claude Code session answers blocked or refused by the safety classifier

export default {
  id: "remove-resume-answers",
  name: "Remove Resume Answers",
  description: "Remove Claude Code session answers blocked or refused by the safety classifier",
  version: "1.0.0",

  setup({ registerCommand, ctx }) {
    registerCommand({
      name: "remove-resume-answers",
      description: "Clean up Claude Code session answers blocked or refused by the safety mechanism",
      handler: async ({ args }) => {
        const { execSync } = await import("node:child_process");
        const { existsSync, readFileSync } = await import("node:fs");
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
          return {
            text: "❌ 無法找到 remove_resume_answers.sh 腳本。請確認 repo 已正確克隆。",
          };
        }

        const projectArg = args && args.length > 0 ? args[0] : null;

        try {
          const result = execSync(
            `bash "${scriptPath}" ${projectArg ? `"${projectArg}"` : ""}`,
            { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 }
          );
          return {
            text: `✅ 清理完成\n\n${result}`,
          };
        } catch (err) {
          return {
            text: `❌ 清理失敗：${err.message}`,
          };
        }
      },
    });
  },
};
