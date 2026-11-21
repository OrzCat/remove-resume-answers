---
description: Remove Claude Code session answers blocked or refused by the safety classifier
allowed-tools: Bash
---

Clean up assistant answers that were blocked or refused by the safety mechanism (e.g. after `claude resume`).

Run:

```bash
bash /Users/orzcat/plugin/resume-answer-remover/scripts/remove_resume_answers.sh "${ARGUMENTS:-}"
```

Notes:
- With no argument, targets the session of the current project (working directory).
- You may pass a session file path or project directory, e.g.:
  ```bash
  bash /Users/orzcat/plugin/resume-answer-remover/scripts/remove_resume_answers.sh /Users/orzcat/demo-project
  ```

After completion, report how many answers were removed and which session file was handled.
