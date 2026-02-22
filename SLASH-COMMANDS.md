# MISO Slash Commands

Issue-comment commands:

- `/agent analyze`
- `/agent execute`
- `/agent review`
- `/agent status`
- `/task-start`
- `/task-plan`
- `/task-close`

All status messages are plain text for mobile-friendly readability.

## Telegram menu commands (quick entry)

| Menu command | Effect |
|---|---|
| `/start` | Start mission output header (issue/goal/risk) |
| `/plan` | Expand standard execution plan block |
| `/close` | Expand standard closeout block |
| `/status` | Show mission status check template |
| `/task_start` | Alias to `/task-start` |
| `/task_plan` | Alias to `/task-plan` |
| `/task_close` | Alias to `/task-close` |

## One-line examples

```text
/task-start
- Owner: SHUNSUKE AI
- Issue/Context: #123
- Goal: Telegram mission visibility in one format
- Scope: skills/miso and workflow handoff
- Completion Criteria: every state visible and consistent
- Risk: low

/task-plan
- issue-analysis
- agent-execution
- git-workflow
- debugging-troubleshooting

/task-close
- Implemented: standardized MISO command mapping
- Validation: command list and status templates confirmed
- Changes: README / SLASH-COMMANDS / registration scripts
- Risks / next steps: bot command test on target chat
- Notify: pushcut / telegram-buttons
```