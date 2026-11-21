# remove-resume-answers

**English** | [中文](README_zh.md)

Remove Claude Code session answers blocked or refused by the safety classifier.

## Features

- Scans Claude Code session JSONL files (`~/.claude/projects/<encoded-cwd>/<session>.jsonl`)
- Removes assistant answers containing safety-classifier refusals
- Automatically repairs dangling `parentUuid` references (stop-hook bookkeeping) after removal

## Usage

### Via slash command

- `/remove-resume-answers` (plugin command)
- Or run the script directly

### Run the script directly

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/remove_resume_answers.sh" /Users/orzcat/demo-project
```

With no argument, it targets the session of the current project (working directory).

### Install as a plugin (marketplace)

From the terminal:

```bash
claude plugin marketplace add OrzCat/remove-resume-answers
claude plugin install remove-resume-answers@orzcat
```

Or from inside a Claude Code session:

```
/plugin marketplace add OrzCat/remove-resume-answers
/plugin install remove-resume-answers@orzcat
```

## Scope

- Can be run against sessions of any project (as long as the session JSONL follows the Claude Code format).
- Removal conditions: assistant answer text contains safety-classifier refusals, or system/user records contain safeguarding content (e.g. `safeguards stopped the response above · continuing once with that noted`), or user records contain `Your response above was stopped by a safety classifier`. Related child nodes (stop-hook, etc.) are repaired after removal.

## As an OpenCode skill

This repo includes a `skill.yaml` so it can be used as an OpenCode skill. OpenCode does not auto-download skill files from GitHub, so install with the one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash
```

Or manually:

```bash
# 1. Register the plugin (optional, for tracking)
opencode plugin add OrzCat/remove-resume-answers

# 2. Copy the skill file to OpenCode skills directory
mkdir -p ~/.config/opencode/skills
curl -o ~/.config/opencode/skills/remove-resume-answers.yaml https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/skill.yaml

# 3. Reload OpenCode configuration
opencode reload
```

## Notes

- This operation writes directly into session files under `~/.claude/projects/...`; it is recommended to back up first.
- After removal, related child nodes (stop-hook, etc.) are repaired; only answers and records related to safety-blocked/refused responses are cleaned.

## License

Released under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for details.
