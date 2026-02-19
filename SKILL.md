# Mission Control — Multi-Agent Visualization Skill

## Overview
Display and update a real-time progress dashboard in Telegram during spawn operations.
Visualize the entire mission lifecycle through single-message edit updates + reaction transitions + inline buttons.

## Design Principles (Telegram-safe formatting)
- ❌ Box-drawing characters (`┏━┓`) — never use
- ❌ Space alignment — never use
- ✅ Left-aligned only
- ✅ Emojis carry structural meaning
- ✅ `——————————————` em-dash separator (14 em-dashes)
- ✅ `↳` for hierarchy
- ✅ Unicode bold (`𝗯𝗼𝗹𝗱`) for section names
- ✅ `▓░` for progress bars (16 segments)

## Status Icon Definitions

| State | Icon | Label |
|-------|------|-------|
| Initializing | ⏳ | `𝗜𝗡𝗜𝗧` |
| Running | 🔥 | `𝗥𝗨𝗡𝗡𝗜𝗡𝗚` |
| Writing | ✏️ | `𝗪𝗥𝗜𝗧𝗜𝗡𝗚` |
| Waiting | ⏸️ | `𝗪𝗔𝗜𝗧𝗜𝗡𝗚` |
| Done | ✅ | `𝗗𝗢𝗡𝗘` |
| Error | ❌ | `𝗘𝗥𝗥𝗢𝗥` |
| Retry | 🔄 | `𝗥𝗘𝗧𝗥𝗬` |
| Awaiting Approval | ⏸️ | `𝗔𝗪𝗔𝗜𝗧𝗜𝗡𝗚 𝗔𝗣𝗽𝗥𝗢𝗩𝗔𝗟` |

## Reaction Integration

Message reactions identify phases at a glance. You can see mission state from the chat list without opening the message.

| Phase | Reaction | Meaning |
|-------|----------|---------|
| INIT / RUNNING | 🔥 | Agent(s) active |
| PARTIAL | 🔥 | Some agents still running |
| AWAITING APPROVAL | 👀 | Waiting for user confirmation |
| COMPLETE | 🎉 | Mission complete |
| ERROR | ❌ | Error occurred |

Implementation: `message(action=react, messageId, emoji)` on phase transition.
Telegram config: `channels.telegram.reactionLevel = "extensive"` required.

## Acknowledgment Reaction (ackReaction)

Instantly attach 👀 reaction when a user message is received — the fastest "message received" feedback.
Auto-removed after reply (removeAckAfterReply: true).

Config:
- messages.ackReaction: "👀"
- messages.ackReactionScope: "all" (all messages including DMs)
- messages.removeAckAfterReply: true

Functions as Layer 0.5 in the 4+1 Layer UX Model.
Sits between Pin (Layer 0) and Reaction (Layer 1) as instant feedback.

## Pin Integration

Pin the mission message to the top of DM while active. Unpin on completion.
When opening the chat, you instantly see "what's running right now."

| Timing | Action |
|--------|--------|
| Phase 1 INIT | `pinChatMessage` — pin (silent) |
| Phase 5 COMPLETE | `unpinChatMessage` — unpin |
| Phase ERROR (abort) | `unpinChatMessage` — unpin |

Implementation: Direct Telegram Bot API calls.
```python
# Pin
POST /bot{token}/pinChatMessage
{"chat_id": chat_id, "message_id": msg_id, "disable_notification": true}

# Unpin
POST /bot{token}/unpinChatMessage
{"chat_id": chat_id, "message_id": msg_id}
```
Note: The `message` tool doesn't support pin, so Bot API is called directly.

## Phase Overview (6 Phases)

```
Phase 1: INIT → Phase 2: RUNNING → Phase 3: PARTIAL
  → Phase 4: AWAITING APPROVAL → Phase 5: COMPLETE
  → Phase ERROR (can occur at any point)
```

## Templates

### Phase 1: INIT (Instant response — Agent initialization)

Reaction: 🔥

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ 0s ∣ 💰 $0.00

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 ({count} spawning)
——————————————

⏳ {agent_1_name} ∣ {agent_1_task}
↳ 𝗜𝗡𝗜𝗧

⏳ {agent_2_name} ∣ {agent_2_task}
↳ 𝗜𝗡𝗜𝗧

⏸️ {agent_3_name} ∣ {agent_3_task}
↳ 𝗪𝗔𝗜𝗧𝗜𝗡𝗚 (depends: agent_1, agent_2)

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase 2: RUNNING (Active — Progress bar + thinking display)

Reaction: 🔥

**GIF Integration**: Use `miso-running.gif` for animated progress visualization.
See "GIF Integration" section below for implementation details.

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ {elapsed} ∣ 💰 ${cost}

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 (0/{count} complete)
——————————————

🔥 {agent_1_name} ∣ {agent_1_task}
▓▓▓▓▓▓▓▓░░░░░░░ 56%
🧠 {agent_1_thinking}
⏱ {time} ∣ 💰 ${cost}

🔥 {agent_2_name} ∣ {agent_2_task}
▓▓▓▓▓░░░░░░░░░░ 38%
🧠 {agent_2_thinking}
⏱ {time} ∣ 💰 ${cost}

⏸️ {agent_3_name} ∣ {agent_3_task}
░░░░░░░░░░░░░░░░ 0%
↳ 𝗪𝗔𝗜𝗧𝗜𝗡𝗚 (depends: agent_1, agent_2)

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase 3: PARTIAL (Partial completion — Some done, others running)

Reaction: 🔥

**GIF Integration**: Use `miso-partial.gif` for animated progress visualization.
Active agents (🔥) display GIF; completed agents (✅) show static progress.
See "GIF Integration" section below for implementation details.

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ {elapsed} ∣ 💰 ${cost}

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 ({done}/{count} complete)
——————————————

✅ {agent_1_name} ∣ {agent_1_task}
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%
🧠 {agent_1_result_summary}
📄 Output: {filename} ({size})
⏱ {time} ∣ 💰 ${cost}

✅ {agent_2_name} ∣ {agent_2_task}
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%
🧠 {agent_2_result_summary}
📄 Output: {filename} ({size})
⏱ {time} ∣ 💰 ${cost}

🔥 {agent_3_name} ∣ {agent_3_task}
▓▓▓▓▓▓▓▓▓░░░░░░ 56%
🧠 {agent_3_thinking}
⏱ {time} ∣ 💰 ${cost}

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase 4: AWAITING APPROVAL (Approval gate — Human-in-the-Loop)

Reaction: 👀
Inline buttons: 2 rows × 2 columns

Auto-triggered before irreversible operations (publish, send, delete, billing).
Completed agent details are collapsed (1-line summary only).

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ {elapsed} ∣ 💰 ${cost}

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 ({count}/{count} complete)
——————————————

✅ {agent_1_name} ∣ {agent_1_task}
📄 {filename} ∣ ⏱ {time} ∣ 💰 ${cost}

✅ {agent_2_name} ∣ {agent_2_task}
📄 {filename} ∣ ⏱ {time} ∣ 💰 ${cost}

✅ {agent_3_name} ∣ {agent_3_task}
📄 {filename} ({size}) ∣ ⏱ {time} ∣ 💰 ${cost}
🧠 {key_insight}

——————————————
⏸️ 𝗔𝗪𝗔𝗜𝗧𝗜𝗡𝗚 𝗔𝗣𝗣𝗥𝗢𝗩𝗔𝗟
{approval_question}
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

Button definitions:
```json
[
  [
    {"text": "✅ Approve", "callback_data": "mc:approve"},
    {"text": "👁 Preview", "callback_data": "mc:preview"}
  ],
  [
    {"text": "✏️ Revise", "callback_data": "mc:revise"},
    {"text": "❌ Abort", "callback_data": "mc:abort"}
  ]
]
```

Button behavior:
- `mc:approve` → Proceed to Phase 5, execute irreversible operation
- `mc:preview` → Send detailed preview as a separate message
- `mc:revise` → Ask user for revision instructions, re-spawn agent
- `mc:abort` → Abort mission, save partial deliverables

### Phase 5: COMPLETE (Mission complete)

Reaction: 🎉

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗠𝗣𝗟𝗘𝗧𝗘 ✅
——————————————
📋 {mission_description}
⏱ {total_time} ∣ 💰 ${total_cost} ∣ 🧩 {count}/{count} agents

↳ 📄 𝗗𝗘𝗟𝗜𝗩𝗘𝗥𝗔𝗕𝗟𝗘𝗦
——————————————
📄 {file_1} — {description_1}
📄 {file_2} — {description_2}
📄 {file_3} — {description_3}

↳ 💡 𝗞𝗘𝗬 𝗜𝗡𝗦𝗜𝗚𝗛𝗧𝗦
——————————————
1. {insight_1}
2. {insight_2}
3. {insight_3}

↳ ✅ 𝗔𝗣𝗣𝗥𝗢𝗩𝗘𝗗
——————————————
Approved by: {approver} ∣ {timestamp}
Action: {action_taken}

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase ERROR (Error occurred)

Reaction: ❌

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ {elapsed} ∣ 💰 ${cost}

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 ({done} ✅ · {error} ❌ · {retry} 🔄)
——————————————

✅ {agent_1_name} ∣ {agent_1_task}
📄 {filename} ∣ ⏱ {time} ∣ 💰 ${cost}

❌ {agent_2_name} ∣ {agent_2_task}
⚠️ {error_message}
🔄 Retrying... ({retry_n}/{max_retry})

⏸️ {agent_3_name} ∣ {agent_3_task}
↳ Waiting for error resolution

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

Error buttons:
```json
[
  [
    {"text": "🔄 Retry", "callback_data": "mc:retry"},
    {"text": "⏭ Skip", "callback_data": "mc:skip"}
  ],
  [
    {"text": "📄 Complete with partial results", "callback_data": "mc:partial_complete"},
    {"text": "❌ Abort", "callback_data": "mc:abort"}
  ]
]
```

## Progress Bar Rules

16 fixed segments:
```
filled = round(percent / 100 * 16)
bar = "▓" × filled + "░" × (16 - filled)
```

Examples:
- 0%: `░░░░░░░░░░░░░░░░`
- 25%: `▓▓▓▓░░░░░░░░░░░░`
- 50%: `▓▓▓▓▓▓▓▓░░░░░░░░`
- 75%: `▓▓▓▓▓▓▓▓▓▓▓▓░░░░`
- 100%: `▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓`

## GIF Integration

MISO supports animated progress visualization using GIF files.
Use `scripts/miso_telegram.py` for sending and updating animations.

### Available GIFs

| Phase | GIF File | Description |
|-------|----------|-------------|
| init | `miso-init.gif` | Mission initialization |
| running | `miso-running.gif` | Active progress animation |
| partial | `miso-partial.gif` | Partial completion |
| approval | `miso-approval.gif` | Awaiting approval |
| complete | `miso-complete.gif` | Mission complete |
| error | `miso-error.gif` | Error occurred |

### Agent-Specific GIFs

For agents with custom visualization:
- `agent-{name}-init.gif` — Agent initialization
- `agent-{name}-running.gif` — Agent active
- `agent-{name}-complete.gif` — Agent complete

Example: `agent-researcher-running.gif`

### Implementation Steps

**Phase 1: Send initial animation**
```bash
python3 scripts/miso_telegram.py send <chat_id> init "<caption>"
```

**Phase 2-3: Update animation**
```bash
python3 scripts/miso_telegram.py edit <chat_id> <message_id> running "<caption>"
```

**Phase 4-5: Update to completion/approval**
```bash
python3 scripts/miso_telegram.py edit <chat_id> <message_id> complete "<caption>"
```

### GIF Usage Rules

- **Phase 1-2**: Always use GIF for visual feedback
- **Phase 3**: Show GIF only for active agents; completed agents show static progress
- **Phase 4-5**: GIF + approval buttons / completion message
- **ERROR**: GIF + error message + recovery buttons

### Caption Updates

GIF captions use `editMessageMedia` to update without re-sending the entire message.
This provides smooth transitions between phases.

### Asset Location

GIF files are stored in:
```
skills/miso/assets/           # Phase GIFs (init, running, complete, etc.)
skills/miso/assets/progress/  # Progress bar GIF (Issue #2)
```

### Progress Bar GIF (Issue #2)

An animated progress bar GIF is available for inline progress visualization.

| File | Path | Spec |
|------|------|------|
| `progress.gif` | `assets/progress/progress.gif` | 21フレーム, 400×40px |

**仕様:**
- フレーム数: 21 (0%〜100%, 5%刻み)
- サイズ: 400×40px
- 配色: オレンジ→イエロー グラデーション (`#FF8C42` → `#FFD700`)
- 背景: ダークグレー (`#1A1A1A`)
- フレーム間隔: 120ms / frame
- 生成スクリプト: `scripts/generate_progress_gif.py`

**再生成コマンド:**
```bash
cd skills/miso
python3 scripts/generate_progress_gif.py
```

## Implementation Flow

### 1. Mission Start
```
1. Decompose task and determine agent list
2. Send instant response using Phase 1 template → retain messageId
3. Attach 🔥 reaction
4. 📌 Pin message (disable_notification: true)
5. Spawn each agent
```

### 2. Agents Running
```
1. Update agent status
2. Send animation with `miso-running.gif` (use `miso_telegram.py send_animation`)
3. Update message caption with Phase 2 template (use `editMessageMedia`)
4. Show agent intermediate output in 🧠 thinking line
```

### 3. Partial Completion
```
1. Update completed agents to ✅, show progress for remaining
2. Update message caption with Phase 3 template (use `editMessageMedia`)
3. Keep 🔥 reaction
```

### 4. All Agents Complete + Irreversible Operation Pending
```
1. Edit message with Phase 4 template + attach inline buttons
2. Switch reaction → 👀
3. Wait for user button press
4. mc:approve → Proceed to Phase 5
5. mc:preview → Send details as separate message
6. mc:revise → Get revision instructions from user, re-spawn agent
7. mc:abort → Abort, save partial deliverables
```

### 5. Completion
```
1. Edit message with Phase 5 template (remove buttons)
2. Switch reaction → 🎉
3. 📌 Unpin message
4. Save deliverables to docs/outputs/
```

### 6. Error Handling
```
1. Edit message with Phase ERROR template + attach error buttons
2. Switch reaction → ❌
3. mc:retry → Re-spawn failed agent
4. mc:skip → Skip failed agent, continue with remaining
5. mc:partial_complete → Complete with successful results only
6. mc:abort → Full abort
```

## Posting Destinations (DM + Channel)

### DM (Operator — Full features)
All features of the 4+1 Layer UX Model. Pins, reactions, progress bars, inline buttons.

### Channel (@MIYABI_CHANNEL — Mission log)
Auto-post mission start and completion. Progress details are DM-only.

| Timing | DM | Channel |
|--------|-----|---------|
| Mission start | Phase 1 INIT + 📌 Pin | 🚀 Mission started notification |
| Running | Phase 2-3 edit updates | — (no post) |
| Awaiting approval | Phase 4 + buttons | — (no post) |
| Complete | Phase 5 + 🎉 + unpin | ✅ Completion report (deliverables + Key Insights) |
| Error | Phase ERROR + buttons | — (no post) |

### Channel Post Templates

**Mission Start:**
```
🚀 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗦𝗧𝗔𝗥𝗧𝗘𝗗
——————————————
📋 {mission_description}
🧩 {agent_count} agents deployed
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

**Mission Complete:**
```
✅ 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗠𝗣𝗟𝗘𝗧𝗘
——————————————
📋 {mission_description}
⏱ {total_time} ∣ 🧩 {agent_count} agents

↳ 💡 𝗞𝗘𝗬 𝗜𝗡𝗦𝗜𝗚𝗛𝗧𝗦
——————————————
1. {insight_1}
2. {insight_2}
3. {insight_3}
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

Channel ID: `-1003700344593` (@MIYABI_CHANNEL)

### Master Ticket (Permanent pin — in DM)

Maintain one persistent message in DM. Shows all mission overview.
Individual mission messages use temporary pins (unpin on complete).

```
📌 𝗠𝗜𝗦𝗢 𝗗𝗔𝗦𝗛𝗕𝗢𝗔𝗥𝗗
——————————————
1️⃣ 🔥 #1 PPAL analysis (3/5 agents)
2️⃣ 👀 #2 note記事 — 承認待ち
3️⃣ ✅ #3 KAEDE調査 — 完了済み
——————————————
今日: 3ミッション ∣ 💰 $0.45
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

Master ticket stays permanently pinned. Individual missions unpin on completion.
Numbered emojis (1️⃣ 2️⃣ 3️⃣) allow quick visual identification from chat list.

## Unicode Bold Conversion Table

Normal → Bold:
- A-Z: 𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭
- a-z: 𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇
- 0-9: 𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵

Small caps:
- ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ

## Prerequisites
- Telegram `reactionLevel`: `extensive` (config: `channels.telegram.reactionLevel`)
- `message` tool: `react`, `edit`, `send` actions
- `sessions_spawn` + spawn completion notifications for state transitions

## Related Skills
- `miyabi-channel` — Channel posting skill
- `telegram-style` — Telegram formatting rules
- `main-context-handoff` — Sub-agent handoff
- `DESIGN-SYSTEM.md` — Design system details
