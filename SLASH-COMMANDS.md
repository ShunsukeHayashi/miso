# MISO Slash Commands

This repository supports quick workflow helpers in issue comments.

## New commands

- `/agent analyze` — trigger issue analysis
- `/agent execute` — start autonomous execution flow
- `/agent review` — request code-review pass
- `/agent status` — check current status
- `/task-start` — post a task-start template to the issue
- `/task-plan` — post an execution-plan template to the issue
- `/task-close` — post a completion template to the issue

## Templates

### /task-start

- Owner: `@your-name`
- Issue/Context: `#<issue-number>`
- Goal / Scope / Completion Criteria / Risk

### /task-plan

- issue-analysis
- githubops-workflow
- agent-execution
- (optional) agent-teams / ai-triad
- git-workflow
- debugging-troubleshooting

### /task-close

- Implemented summary
- Validation evidence
- Changed files
- Risks and next steps
- Notification target

## Example usage

Post comments in GitHub issues:

```text
/task-start
/task-plan
/task-close
```