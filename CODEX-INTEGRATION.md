# MISO × Codex CLI 統合ガイド

## 概要

Codex CLI (OpenAI) のタスク実行出力を MISO Mission Control フォーマットに統一する。

---

## AGENTS.md への追記テンプレート

以下を既存の AGENTS.md に追記する:

```markdown
## 出力形式 — MISO Mission Control

タスク実行時は以下の MISO フォーマットで進捗を報告すること。
全フェーズで同じヘッダー/フッターを使う。

### 基本ルール

- ヘッダー: `🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟` + `——————————————`
- フッター: `🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ`
- プログレス: 16セグメント `▓░` (filled = round(% / 100 * 16))
- 階層: `↳` を使用
- 状態: ⏳ INIT → 🔥 RUNNING → ✅ COMPLETE (❌ ERROR)

### タスク開始時

🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {タスク名}
⏱ 0s ∣ ⏳ INIT
- Goal: {ゴール}
- Scope: {対象ファイル}
- Risk: {none|low|medium|high}
- Next: 実装開始
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ

### タスク完了時

🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {タスク名}
⏱ {時間} ∣ ✅ COMPLETE

✅ codex ∣ {結果}
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%
🧠 {何をやったか}

↳ 📄 DELIVERABLES
↳ {file1} (+n -m)
↳ {file2} (+n -m)

↳ 💡 KEY INSIGHTS
1. {発見}
2. {判断}
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ

### エラー時

🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {タスク名}
⏱ {時間} ∣ ❌ ERROR

❌ codex ∣ {エラー内容}
🧠 {詳細}
🧠 Retry: {n}/3
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

---

## ディスパッチ方法

### tmux 経由（推奨）

```bash
# Claude Code → tmux → Codex
tmux send-keys -t Tmax "cd ~/dev/{project} && codex 'MISO形式で報告すること。タスク: {description}'" Enter
```

### 直接実行

```bash
codex --prompt "以下のルールに従って実行・報告せよ:
1. MISO Mission Control フォーマットで進捗を出力
2. ヘッダー: 🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟 + ——————————————
3. フッター: 🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
4. 完了時は KEY INSIGHTS と DELIVERABLES を含む

タスク: {description}"
```

---

## Codex の役割（AI Triad）

| エージェント | 担当 | MISO での表示名 |
|-------------|------|----------------|
| **Codex** | コーディング | `codex` |
| **Claude** | 文章・オーケストレーション | `claude` |
| **Gemini** | UI/UX・画像 | `gemini` |

Codex はコーディング専任。文章作成やオーケストレーションは Claude が担当する。
