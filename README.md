# MISO — Mission Inline Skill Orchestration

**"Simple ingredients. Rich flavor."** 🍜

[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue?style=flat-square)](https://github.com/openclaw)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-orange?style=flat-square)](https://github.com/openclaw/skills/mission-control)

---

## What is MISO?

MISO is the world's first **Telegram-native Agentic UI framework** that brings multi-agent orchestration into your DM — no web dashboards, no external apps, just seamless, inline visibility.

At its core, MISO orchestrates the entire mission lifecycle through a single, evolving message. It's not about displaying progress; it's about **living** progress — every phase, every state transition, every decision point flows through one artifact that you can glance at, interact with, and trust.

### Why "MISO"?

Just like the Japanese soup stock that delivers depth from simple ingredients, MISO orchestrates complex multi-agent workflows using only Telegram's native primitives: **reactions, edits, pins, and inline buttons**.

---

## 📐 4-Layer UX Model

MISO's magic lies in its layered approach — each layer adds a dimension of information while keeping the experience intuitive.

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 0: 📌 PIN                                              │
│  ─────────────────────────────────────────────────────────  │
│  Master ticket always pinned — presence at a glance           │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 🔥👀🎉❌ REACTIONS                                  │
│  ─────────────────────────────────────────────────────────  │
│  🔥 Running → 👀 Awaiting → 🎉 Complete → ❌ Error            │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: MESSAGE BODY                                        │
│  ─────────────────────────────────────────────────────────  │
│  • Progress bar                                               │
│  • Agent status matrix                                        │
│  • 🧠 Thought stream (optional)                               │
│  • WBS-style master ticket with strikethrough completion      │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: INLINE BUTTONS                                      │
│  ─────────────────────────────────────────────────────────  │
│  [✅ Approve] [🔄 Retry] [⏭ Skip] [⏹ Abort]                   │
└─────────────────────────────────────────────────────────────┘
```

### The Layers Explained

| Layer | Element | Purpose |
|-------|---------|---------|
| **0** | 📌 Pin | Permanent visibility — see status the moment you open the chat |
| **1** | 🔥👀🎉❌ | Reactive state — scroll-free awareness from any message list |
| **2** | Rich Body | Detailed context — progress, agents, thoughts, tasks |
| **3** | Inline Actions | Human-in-the-loop — control flow without leaving Telegram |

---

## ✨ Features

### Core Capabilities

- **📌 Hybrid Pinning Strategy**
  - Master ticket: Always pinned, persistent mission anchor
  - Individual missions: Temporary pins for active workflows
  - Auto-cleanup: Pins removed when missions complete

- **🎯 WBS-Driven Master Ticket**
  - Goal-oriented task breakdown
  - Strikethrough completion ~~like this~~ for visual clarity
  - Hierarchical task relationships

- **🔗 Channel Orchestration**
  - Auto-post mission start to `@MIYABI_CHANNEL` (or any configured channel)
  - Broadcast completion status on finish
  - Team-wide visibility without manual updates

- **🛑 Human-in-the-Loop Approval Gates**
  - Automatic pause before irreversible operations
  - Required confirmation for destructive actions
  - Timeout with fallback to safe default

- **🔧 Error Recovery Buttons**
  - **🔄 Retry** — Restart failed phase with same context
  - **⏭ Skip** — Continue without completing current task
  - **📝 Partial** — Mark as complete with warnings
  - **⏹ Abort** — Clean shutdown with state preservation

### UX Superpowers

- **Single-Message Lifecycle** — All progress tracked in one editable message
- **Reaction-First Design** — Know state without opening the message
- **Inline Control Flow** — No commands, no menus — just tap buttons
- **Optional Thought Display** — Show 🧠 agent reasoning for transparency

---

## 🚀 Quick Start

### Installation

```bash
# Clone or add to your OpenClaw skills directory
cd ~/.openclaw/workspace/skills/
git clone <mission-control-repo> mission-control
```

### Basic Setup

```yaml
# openclaw.json configuration snippet
skills:
  - name: mission-control
    path: skills/mission-control
    enabled: true
    config:
      telegram:
        channel: "@MIYABI_CHANNEL"  # Broadcast channel (optional)
        pin_master: true             # Always pin master ticket
        pin_individual: true         # Pin active missions temporarily
      approvals:
        timeout_seconds: 300         # 5 minutes to approve
        default_action: abort        # Fallback if timeout
      ui:
        show_thoughts: false          # 🧠 Show agent reasoning
        progress_style: bar           # bar | text
```

### First Mission

```python
from skills.mission_control import Mission

mission = Mission(
    name="Deploy Production",
    channel="@MIYABI_CHANNEL",
    wbs=[
        "Run tests",
        "Build artifact",
        "Deploy to staging",
        "Smoke test",
        "Promote to production",
        "Verify"
    ]
)

await mission.start()  # Creates pinned message with 🔥 reaction
```

---

## 📊 Phase Templates

MISO supports **6 mission phases** with pre-configured templates:

| Phase | Reaction | Description | Typical Actions |
|-------|----------|-------------|-----------------|
| **INIT** | 🔥 | Mission initialized, agents preparing | Load context, validate inputs |
| **RUNNING** | 🔥 | Active execution in progress | Run agents, update progress |
| **PARTIAL** | 👀 | Some tasks complete, ongoing | Continue remaining, report partial |
| **AWAITING APPROVAL** | 👀 | Waiting for human confirmation | Wait for button tap or timeout |
| **COMPLETE** | 🎉 | All tasks finished successfully | Cleanup, report results |
| **ERROR** | ❌ | Failure occurred | Show error, offer recovery options |

### Sample Message Evolution

#### 1. INIT Phase
```
🚀 Deploy Production

Tasks:
□ Run tests
□ Build artifact
□ Deploy to staging
□ Smoke test
□ Promote to production
□ Verify

[🔄 Starting agents...]
```

#### 2. RUNNING Phase
```
🚀 Deploy Production

Progress: ████████░░░░░░░░░░ 40%

Tasks:
✅ Run tests
✅ Build artifact
□ Deploy to staging [Running: deploy-agent]
□ Smoke test
□ Promote to production
□ Verify

Agents:
• test-agent: Complete ✅
• build-agent: Complete ✅
• deploy-agent: Running 🔥
```

#### 3. AWAITING APPROVAL Phase
```
🚀 Deploy Production

Progress: ██████████████░░░░ 80%

Tasks:
✅ Run tests
✅ Build artifact
✅ Deploy to staging
✅ Smoke test
⏸ Promote to production [Awaiting approval]
□ Verify

⚠️ IRREVERSIBLE ACTION: Promotion to production
Are you sure you want to proceed?

[✅ Approve] [⏹ Abort]
```

#### 4. COMPLETE Phase
```
🚀 Deploy Production

Progress: █████████████████ 100%

Tasks:
✅ Run tests
✅ Build artifact
✅ Deploy to staging
✅ Smoke test
✅ Promote to production
✅ Verify

✅ Mission completed successfully!
Posted to: @MIYABI_CHANNEL
Duration: 12m 34s
```

---

## ⚙️ Configuration

### Required Settings

```yaml
skills:
  - name: mission-control
    config:
      telegram:
        channel: string      # Channel ID for broadcasts
        pin_master: boolean  # Always pin master ticket
        pin_individual: boolean  # Pin active missions
      approvals:
        timeout_seconds: number  # Approval timeout
        default_action: string   # "approve" | "abort" | "skip"
```

### Optional Settings

```yaml
skills:
  - name: mission-control
    config:
      ui:
        show_thoughts: boolean      # Show 🧠 agent reasoning
        progress_style: string      # "bar" | "text" | "both"
        compact_mode: boolean       # Minimal verbosity
        max_progress_width: number # Characters for progress bar
      recovery:
        enable_retry: boolean       # Show retry button on errors
        enable_skip: boolean        # Show skip button
        enable_partial: boolean     # Show partial completion
        auto_retry: number          # Auto-retry count (0 = disabled)
      notifications:
        on_start: boolean           # Notify channel on start
        on_complete: boolean        # Notify on completion
        on_error: boolean           # Notify on errors
```

### Environment Variables

```bash
# Optional overrides
MISO_DEFAULT_CHANNEL="@my-team-channel"
MISO_APPROVAL_TIMEOUT=600  # seconds
MISO_AUTO_RETRY=2
MISO_SHOW_THOUGHTS=true
```

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👥 Credits

**Created by:**  
Shunsuke Hayashi & Miyabi 🍜

**Built with:**  
- OpenClaw Framework
- Telegram Bot API
- Inline Buttons (Telegram-native)
- Edit Message API
- Pin Messages API

**Inspiration:**  
Good ingredients, simple preparation, deep results — just like miso soup.

---

<div align="center">

**"Simple ingredients. Rich flavor."** 🍜

Made with ❤️ for OpenClaw & ClawHub

</div>
