# remove-resume-answers

[English](README.md) | [中文](README_zh.md)

Remove Claude Code session answers blocked or refused by the safety classifier.

## Features

- Scans Claude Code session JSONL files (`~/.claude/projects/<encoded-cwd>/<session>.jsonl`)
- Removes assistant answers containing safety-classifier refusals
- Removes related safety-system and user records
- Repairs dangling `parentUuid` references after removal
- Registers a `/remove-resume-answers` slash command in OpenCode

## Usage

### Claude Code

Run the plugin command:

```text
/remove-resume-answers
```

You can optionally pass a session file path or project directory:

```text
/remove-resume-answers /Users/orzcat/demo-project
```

With no argument, the command targets the session of the current project.

### OpenCode

OpenCode 2.3.2 or newer is required. Install the plugin with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash
```

Then run the command in OpenCode:

```text
/remove-resume-answers
```

You can optionally pass a session file path or project directory:

```text
/remove-resume-answers /Users/orzcat/demo-project
```

### Run the script directly

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/remove_resume_answers.sh" /Users/orzcat/demo-project
```

With no argument, it targets the session of the current project (working directory).

## Install as a Claude Code plugin

From the terminal:

```bash
claude plugin marketplace add OrzCat/remove-resume-answers
claude plugin install remove-resume-answers@orzcat
```

Or from inside a Claude Code session:

```text
/plugin marketplace add OrzCat/remove-resume-answers
/plugin install remove-resume-answers@orzcat
```

## Scope

- Can be run against sessions of any project, as long as the session JSONL follows the Claude Code format.
- Removal conditions: assistant answer text contains safety-classifier refusals, or system/user records contain safeguarding content such as `safeguards stopped the response above · continuing once with that noted`, or user records contain `Your response above was stopped by a safety classifier`.
- Related child records are reparented after removal so no references point to deleted entries.

## Notes

- This operation writes directly into session files under `~/.claude/projects/...`; it is recommended to back up first.
- Only answers and records related to safety-blocked or refused responses are cleaned.

## License

Released under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for details.
