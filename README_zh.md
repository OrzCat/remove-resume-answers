# remove-resume-answers

移除被安全機制擋下或拒絕的 Claude Code session 回答。

## 功能

- 掃描 Claude Code session JSONL（`~/.claude/projects/<encoded-cwd>/<session>.jsonl`）
- 移除其中內容含安全機制相關拒絕措辭的 assistant 回答
- 移除後自動修復因刪除而斷掉的 `parentUuid` 參考（stop-hook bookkeeping）

## 使用

### 透過 slash command

- `/remove-resume-answers`（plugin command）
- 或直接跑 script

### 直接執行 script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/remove_resume_answers.sh" /Users/orzcat/demo-project
```

未傳參數時預設處理目前目錄（working directory）的專案 session。

### 安裝成 plugin（marketplace）

從終端機執行：

```bash
claude plugin marketplace add OrzCat/remove-resume-answers
claude plugin install remove-resume-answers@orzcat
```

或在 Claude Code 內使用 slash command：

```
/plugin marketplace add OrzCat/remove-resume-answers
/plugin install remove-resume-answers@orzcat
```

## 適用範圍

- 可針對任何專案的 session 執行（只要 session JSONL 符合 Claude Code 格式）。
- 移除的條件：assistant 回答文字含安全機制拒絕措辭，或 system / user 紀錄含 safeguarding 內容（如 `safeguards stopped the response above · continuing once with that noted`），或 user 紀錄含 `Your response above was stopped by a safety classifier`。移除後會修復相關子節點（stop-hook 等）的父連結。

## 作為 OpenCode plugin

直接從 GitHub 安裝：

```bash
opencode plugin add OrzCat/remove-resume-answers
opencode reload
```

## 注意

- 此操作直接寫入 `~/.claude/projects/...` 下的 session 檔；建議先備份。
- 移除後會修復相關子節點（stop-hook 等）的父連結；只清理與安全機制擋答／拒絕相關的回答與紀錄。

## License

Released under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for details.
