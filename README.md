# MISO — Mission Inline Skill Orchestration

## What is MISO?
MISO is a **Mission Control** style visibility system for OpenClaw.
It tracks autonomous and multi-agent work in Telegram with one unified progress format.

### Use when
- Multiple agents run in parallel
- You need approval gates (`AWAITING APPROVAL`)
- You want mission state visible from chat list with emoji reactions

### Core states
- `INIT` → `RUNNING` → `PARTIAL` → `AWAITING APPROVAL` → `COMPLETE` (`ERROR` if needed)
- Reactions: `🔥`, `👀`, `🎉`, `❌`

### Message format (Android-safe)
Plain text format:

🤖 MISSION CONTROL
——————————————
📋 {mission}
⏱ {elapsed} ∣ 🧩 {done}/{total} agents ∣ {state}
- Issue: #{issue-number}
- Owner: SHUNSUKE AI
- Goal: {goal}
- Next: {next action}
🌸 powered by miyabi

### Slash command flow
- `/task-start`
- `/task-plan`
- `/task-close`
- `/agent analyze`
- `/agent execute`
- `/agent review`
- `/agent status`

### Why this is stable
- Same format across all missions
- Easy to copy/paste from mobile
- Low friction visibility from chat list without opening full context

## Slash Commands

See `SLASH-COMMANDS.md` for concise command usage.
