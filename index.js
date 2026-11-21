import { execFile } from "node:child_process"
import { existsSync } from "node:fs"
import { resolve } from "node:path"
import { fileURLToPath } from "node:url"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)
const SCRIPT_PATH = fileURLToPath(new URL("./scripts/remove_resume_answers.sh", import.meta.url))

function resolveTarget(target, cwd) {
  const value = typeof target === "string" ? target.trim() : ""
  return value ? resolve(cwd, value) : cwd
}

function errorMessage(error) {
  if (error && typeof error.stderr === "string" && error.stderr.trim()) {
    return error.stderr.trim()
  }
  return error instanceof Error ? error.message : String(error)
}

async function runCleanup(target, cwd) {
  if (!existsSync(SCRIPT_PATH)) {
    throw new Error(`Cleanup script not found: ${SCRIPT_PATH}`)
  }

  const resolvedTarget = resolveTarget(target, cwd)

  try {
    const { stdout, stderr } = await execFileAsync("bash", [SCRIPT_PATH, resolvedTarget], {
      cwd,
      encoding: "utf8",
      maxBuffer: 10 * 1024 * 1024,
    })

    return [stdout.trim(), stderr.trim()].filter(Boolean).join("\n")
  } catch (error) {
    throw new Error(errorMessage(error))
  }
}

export default {
  id: "remove-resume-answers",

  async setup(ctx) {
    await ctx.command.transform((editor) => {
      editor.add({
        name: "remove-resume-answers",
        description: "Remove blocked or refused answers from Claude Code sessions",
        async execute({ sessionID, prompt }) {
          const target = prompt.text.trim() || ctx.location.directory

          try {
            const result = await runCleanup(target, ctx.location.directory)
            await ctx.session.synthetic({
              sessionID,
              text: result || "Cleanup completed. No matching answers were found.",
              description: "remove-resume-answers cleanup result",
              resume: false,
            })
          } catch (error) {
            const message = `Cleanup failed: ${errorMessage(error)}`
            await ctx.session
              .synthetic({
                sessionID,
                text: message,
                description: "remove-resume-answers cleanup error",
                resume: false,
              })
              .catch(() => {})
            throw new Error(message)
          }
        },
      })
    })

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "remove-resume-answers",
        description: "Remove blocked or refused answers from a Claude Code session",
        input: {
          type: "object",
          properties: {
            project: {
              type: "string",
              description: "Optional session file path or project directory",
            },
          },
          additionalProperties: false,
        },
        async execute(input) {
          const result = await runCleanup(input.project, ctx.location.directory)
          return { content: result || "Cleanup completed. No matching answers were found." }
        },
      })
    })
  },
}
