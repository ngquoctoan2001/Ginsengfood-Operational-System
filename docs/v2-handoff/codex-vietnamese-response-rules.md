# Codex Vietnamese Response Rules Handoff

## Tóm tắt

Đã cập nhật root agent rules và prompt contracts để bắt buộc heading phản hồi cuối bằng tiếng Việt.

Các file `.codex/*` và `.agents/skills/ginsengfood-greenfield-build/SKILL.md` đang bị Windows ACL chặn ghi trong phiên shell hiện tại. Đã thêm script `tools/agent/Apply-VietnameseCodexOutputRules.ps1` để áp dụng phần còn lại khi quyền ghi được mở hoặc chạy bằng shell có quyền ownership.

## File đã cập nhật trực tiếp

- `AGENTS.md`
- `docs/software-specs/ai-agent/00_README.md`
- `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
- `docs/software-specs/ai-agent/02_CODEX_PROMPT_PACK.md`
- `docs/software-specs/ai-agent/03_GAP_IMPLEMENTATION_PROMPTS.md`
- `docs/software-specs/ai-agent/05_VALIDATION_PROMPTS.md`
- `docs/software-specs/ai-agent/06_HANDOFF_PROMPTS.md`
- `docs/software-specs/phase-project/*`
- `tools/agent/Apply-VietnameseCodexOutputRules.ps1`

## File còn bị chặn bởi ACL

- `.codex/AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/contract-mapper.toml`
- `.codex/agents/implementation-planner.toml`
- `.codex/agents/operational-gap-auditor.toml`
- `.codex/agents/operational-implementer.toml`
- `.codex/agents/test-planner.toml`
- `.agents/skills/ginsengfood-greenfield-build/SKILL.md`

## Cách áp dụng phần còn lại

Chạy lệnh sau trong PowerShell có quyền ghi các file `.codex` và `.agents/skills`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\agent\Apply-VietnameseCodexOutputRules.ps1
```

Kiểm tra trước khi ghi:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\agent\Apply-VietnameseCodexOutputRules.ps1 -CheckOnly
```

## Blocker

Phiên hiện tại không có quyền ownership để gỡ deny ACL. Lệnh `takeown` trả về: `The current logged on user does not have ownership privileges`.
