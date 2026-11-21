# remove-resume-answers

[English](README.md) | [中文](README_zh.md)

移除被安全機制擋下或拒絕的 Claude Code session 回答。

## 功能

- 掃描 Claude Code session JSONL（`~/.claude/projects/<encoded-cwd>/<session>.jsonl`）
- 移除內容含安全機制相關拒絕措辭的 assistant 回答
- 移除相關的 safety system 與 user 紀錄
- 移除後自動修復斷掉的 `parentUuid` 參考
- 在 OpenCode 註冊 `/remove-resume-answers` slash command

## 使用

### Claude Code

執行 plugin command：

```text
/remove-resume-answers
```

也可以選擇性傳入 session 檔案路徑或專案目錄：

```text
/remove-resume-answers /Users/orzcat/demo-project
```

未傳參數時，command 會處理目前專案的 session。

### OpenCode

需要 OpenCode 2.3.2 或更新版本。可用一行指令自動安裝：

```bash
curl -fsSL https://raw.githubusercontent.com/OrzCat/remove-resume-answers/main/install.sh | bash
```

安裝後在 OpenCode 執行：

```text
/remove-resume-answers
```

也可以選擇性傳入 session 檔案路徑或專案目錄：

```text
/remove-resume-answers /Users/orzcat/demo-project
```

### 直接執行 script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/remove_resume_answers.sh" /Users/orzcat/demo-project
```

未傳參數時預設處理目前目錄（working directory）的專案 session。

## 安裝成 Claude Code plugin

從終端機執行：

```bash
claude plugin marketplace add OrzCat/remove-resume-answers
claude plugin install remove-resume-answers@orzcat
```

或在 Claude Code 內使用 slash command：

```text
/plugin marketplace add OrzCat/remove-resume-answers
/plugin install remove-resume-answers@orzcat
```

## 適用範圍

- 可針對任何專案的 session 執行，只要 session JSONL 符合 Claude Code 格式。
- 移除條件：assistant 回答文字含安全機制拒絕措辭，或 system／user 紀錄含 safeguarding 內容（如 `safeguards stopped the response above · continuing once with that noted`），或 user 紀錄含 `Your response above was stopped by a safety classifier`。
- 移除後會重新指定相關子紀錄的父節點，避免留下指向已刪除項目的參考。

## 注意

- 此操作直接寫入 `~/.claude/projects/...` 下的 session 檔；建議先備份。
- 只清理與安全機制擋答／拒絕相關的回答與紀錄。

## License

Released under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for details.
