# MISO × Claude Desktop 統合ガイド

## 概要

Claude Desktop (Artifact / Project) で MISO Mission Control フォーマットを活用する方法。

---

## 出力先の使い分け

| コンテンツ | 出力先 | 理由 |
|-----------|--------|------|
| 進捗報告（INIT/RUNNING/PARTIAL） | チャット | リアルタイム性重要 |
| 完了レポート（COMPLETE） | Artifact | 保存・共有に便利 |
| WBS マスターチケット | Artifact | 定期更新する長期ドキュメント |
| エラー報告（ERROR） | チャット | 即座の判断が必要 |
| 承認要求（AWAITING APPROVAL） | チャット | インタラクション必要 |

---

## チャット出力

Markdown レンダリングされるため、コードブロックに入れず**プレーンテキスト**として出力:

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 セキュリティ監査レポート作成
⏱ 2m ∣ 🧩 1/3 agents ∣ 🔥 RUNNING

🔥 scanner ∣ 脆弱性スキャン
▓▓▓▓▓▓▓▓▓▓░░░░░░ 62%
🧠 依存関係チェック中（npm audit + Snyk）

⏳ analyzer ∣ リスク分析
░░░░░░░░░░░░░░░░ 0%

⏳ reporter ∣ レポート生成
░░░░░░░░░░░░░░░░ 0%

- Next: スキャン完了後にリスク分析開始
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

---

## Artifact 出力

### 完了レポート Artifact

**タイトル**: `🤖 Mission Report: {ミッション名}`
**タイプ**: text

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟 — FINAL REPORT
——————————————
📋 {ミッション名}
⏱ {総時間} ∣ 🧩 {total}/{total} agents ∣ ✅ COMPLETE

✅ {agent-1} ∣ {結果}
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%
🧠 {詳細}

✅ {agent-2} ∣ {結果}
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%
🧠 {詳細}

↳ 💡 KEY INSIGHTS
1. {インサイト1}
2. {インサイト2}
3. {インサイト3}

↳ 📄 DELIVERABLES
↳ {ファイル1} (+n -m)
↳ {ファイル2} (+n -m)

↳ 🔗 REFERENCES
↳ PR #{number}: {タイトル}
↳ Issue #{number}: {状態}
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### WBS マスターチケット Artifact

**タイトル**: `🎯 WBS: {プロジェクト名}`
**タイプ**: text

```
🎯 GOAL: {プロジェクトゴール}
——————————————

📌 Milestone 1: {名前}
~✅ T1: {タスク}~
~✅ T2: {タスク}~

📌 Milestone 2: {名前}
👉 🔥 T3: {タスク} — IN PROGRESS
⬜ T4: {タスク}

📌 Milestone 3: {名前}
⬜ T5: {タスク}

——————————————
Updated: {タイムスタンプ}
Next: {次のマイルストーン}
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

---

## Project Knowledge 統合

Claude Desktop の Project に以下のファイルを配置:

### `MISO-STATUS.md`（プロジェクト状態ボード）

```markdown
# MISO Status Board

Last Updated: {timestamp}

## Active Missions

🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {アクティブミッション1}
⏱ {時間} ∣ 🧩 {done}/{total} ∣ {状態}
——————————————

## Recently Completed (Last 7 days)

✅ {ミッションA} — {日時} — {KEY INSIGHT 1つ}
✅ {ミッションB} — {日時} — {KEY INSIGHT 1つ}
✅ {ミッションC} — {日時} — {KEY INSIGHT 1つ}

## Project WBS

🎯 GOAL: {プロジェクトゴール}
...（WBSマスターチケット形式）
```

### `MISO-RULES.md`（出力ルール）

```markdown
# MISO Output Rules for This Project

## Required Format
- Use MISO Mission Control format for all task reports
- Header: 🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟 + ——————————————
- Footer: 🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
- Progress: 16-segment bar (▓░)
- Hierarchy: ↳

## When to Use Artifacts
- COMPLETE reports → Artifact (text)
- WBS updates → Artifact (text)
- Everything else → Chat

## Agent Naming
- research / scanner / analyzer / reporter
- Use descriptive 1-word names
```

---

## Claude Desktop MCP Server 連携

Claude Desktop の MCP サーバーが MISO 形式で状態を返すことも可能:

```json
{
  "content": [{
    "type": "text",
    "text": "🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟\n——————————————\n📋 画像生成完了\n⏱ 8s ∣ ✅ COMPLETE\n\n✅ gemini ∣ onboarding_step1.png 生成\n▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100%\n🧠 1040x1040, 245KB\n\n↳ 📄 DELIVERABLES\n↳ assets/generated-images/onboarding_step1.png\n——————————————\n🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ"
  }]
}
```
