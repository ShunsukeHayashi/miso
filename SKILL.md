# Mission Control — マルチエージェント可視化スキル

## 概要
spawn時にTelegramへリアルタイム進捗ダッシュボードを表示・更新する。
1メッセージをedit更新 + リアクション切替 + インラインボタンで、ミッション全体のライフサイクルを可視化。

## 設計原則（Telegram崩れ防止）
- ❌ 罫線ボックス（`┏━┓`）→ 使わない
- ❌ スペース揃え → 使わない
- ✅ 左揃え徹底
- ✅ 絵文字が構造を担う
- ✅ `——————————————` ダッシュ区切り（emダッシュ14個）
- ✅ `↳` で階層表現
- ✅ Unicode太字（`𝗯𝗼𝗹𝗱`）でセクション名
- ✅ `▓░` でプログレスバー（16セグメント）

## ステータスアイコン定義

| 状態 | アイコン | ラベル |
|------|---------|--------|
| 初期化中 | ⏳ | `𝗜𝗡𝗜𝗧` |
| 実行中 | 🔥 | `𝗥𝗨𝗡𝗡𝗜𝗡𝗚` |
| 書込中 | ✏️ | `𝗪𝗥𝗜𝗧𝗜𝗡𝗚` |
| 待機中 | ⏸️ | `𝗪𝗔𝗜𝗧𝗜𝗡𝗚` |
| 完了 | ✅ | `𝗗𝗢𝗡𝗘` |
| エラー | ❌ | `𝗘𝗥𝗥𝗢𝗥` |
| リトライ | 🔄 | `𝗥𝗘𝗧𝗥𝗬` |
| 承認待ち | ⏸️ | `𝗔𝗪𝗔𝗜𝗧𝗜𝗡𝗚 𝗔𝗣𝗣𝗥𝗢𝗩𝗔𝗟` |

## リアクション連動

メッセージのリアクションでフェーズを一目で識別。チャット一覧でメッセージを開かなくても状態が分かる。

| フェーズ | リアクション | 意味 |
|---------|-------------|------|
| INIT / RUNNING | 🔥 | エージェント稼働中 |
| PARTIAL | 🔥 | まだ稼働中のエージェントあり |
| AWAITING APPROVAL | 👀 | ユーザーの確認待ち |
| COMPLETE | 🎉 | ミッション完了 |
| ERROR | ❌ | エラー発生 |

実装: `message(action=react, messageId, emoji)` でフェーズ遷移時に切り替え。
Telegram設定: `channels.telegram.reactionLevel = "extensive"` が必要。

## 受信確認リアクション（ackReaction）

ユーザーのメッセージ受信時に👀リアクションを即座に付与。「メッセージを受け取った」の最速フィードバック。
返信後に自動削除（removeAckAfterReply: true）。

設定:
- messages.ackReaction: "👀"
- messages.ackReactionScope: "all"（DM含む全メッセージ）
- messages.removeAckAfterReply: true

4+1層UXモデルにおけるLayer 0.5として機能。
ピン(Layer 0)とリアクション(Layer 1)の間に位置する即時フィードバック。

## ピン止め連動

ミッション稼働中はメッセージをDMトップにピン止め。完了後に解除。
チャットを開いた瞬間に「今何が動いてるか」が分かる。

| タイミング | アクション |
|-----------|-----------|
| Phase 1 INIT | `pinChatMessage` — ピン止め（通知なし） |
| Phase 5 COMPLETE | `unpinChatMessage` — ピン解除 |
| Phase ERROR（中止時） | `unpinChatMessage` — ピン解除 |

実装: Telegram Bot API直接呼び出し。
```python
# ピン止め
POST /bot{token}/pinChatMessage
{"chat_id": chat_id, "message_id": msg_id, "disable_notification": true}

# ピン解除
POST /bot{token}/unpinChatMessage
{"chat_id": chat_id, "message_id": msg_id}
```
※ `message` ツールにpin機能がないため、Bot APIを直接利用する。

## フェーズ一覧（全6フェーズ）

```
Phase 1: INIT → Phase 2: RUNNING → Phase 3: PARTIAL
  → Phase 4: AWAITING APPROVAL → Phase 5: COMPLETE
  → Phase ERROR (任意のタイミングで発生)
```

## テンプレート

### Phase 1: INIT（即レス — エージェント初期化）

リアクション: 🔥

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

### Phase 2: RUNNING（稼働中 — プログレスバー + 思考表示）

リアクション: 🔥

```
🤖 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗡𝗧𝗥𝗢𝗟
——————————————
📋 {mission_description}
⏱ {elapsed} ∣ 💰 ${cost}

↳ 🧩 𝗔𝗚𝗘𝗡𝗧𝗦 (0/{count} complete)
——————————————

🔥 {agent_1_name} ∣ {agent_1_task}
▓▓▓▓▓▓▓▓▓░░░░░░░ 56%
🧠 {agent_1_thinking}
⏱ {time} ∣ 💰 ${cost}

🔥 {agent_2_name} ∣ {agent_2_task}
▓▓▓▓▓▓░░░░░░░░░░ 38%
🧠 {agent_2_thinking}
⏱ {time} ∣ 💰 ${cost}

⏸️ {agent_3_name} ∣ {agent_3_task}
░░░░░░░░░░░░░░░░ 0%
↳ 𝗪𝗔𝗜𝗧𝗜𝗡𝗚 (depends: agent_1, agent_2)

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase 3: PARTIAL（部分完了 — 一部完了、残り稼働中）

リアクション: 🔥

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
▓▓▓▓▓▓▓▓▓▓░░░░░░ 56%
🧠 {agent_3_thinking}
⏱ {time} ∣ 💰 ${cost}

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase 4: AWAITING APPROVAL（承認ゲート — Human-in-the-Loop）

リアクション: 👀
インラインボタン: 2行×2列

不可逆操作（公開・送信・削除・課金）の前に自動発動。
完了したエージェントの詳細は折り畳み（1行要約のみ）。

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

ボタン定義:
```json
[
  [
    {"text": "✅ 承認", "callback_data": "mc:approve"},
    {"text": "👁 プレビュー", "callback_data": "mc:preview"}
  ],
  [
    {"text": "✏️ 修正指示", "callback_data": "mc:revise"},
    {"text": "❌ 中止", "callback_data": "mc:abort"}
  ]
]
```

ボタン動作:
- `mc:approve` → Phase 5に進行、不可逆操作を実行
- `mc:preview` → 成果物の詳細プレビューを別メッセージで送信
- `mc:revise` → ユーザーに修正指示を求め、該当エージェントを再spawn
- `mc:abort` → ミッション中止、部分成果物を保存

### Phase 5: COMPLETE（ミッション完了）

リアクション: 🎉

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
承認者: {approver} ∣ {timestamp}
アクション: {action_taken}

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### Phase ERROR（エラー発生）

リアクション: ❌

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
🔄 リトライ中... ({retry_n}/{max_retry})

⏸️ {agent_3_name} ∣ {agent_3_task}
↳ エラー解消待ち

——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

ボタン（エラー時）:
```json
[
  [
    {"text": "🔄 リトライ", "callback_data": "mc:retry"},
    {"text": "⏭ スキップ", "callback_data": "mc:skip"}
  ],
  [
    {"text": "📄 部分結果で完了", "callback_data": "mc:partial_complete"},
    {"text": "❌ 中止", "callback_data": "mc:abort"}
  ]
]
```

## プログレスバー生成ルール

16セグメント固定:
```
filled = round(percent / 100 * 16)
bar = "▓" × filled + "░" × (16 - filled)
```

例:
- 0%: `░░░░░░░░░░░░░░░░`
- 25%: `▓▓▓▓░░░░░░░░░░░░`
- 50%: `▓▓▓▓▓▓▓▓░░░░░░░░`
- 75%: `▓▓▓▓▓▓▓▓▓▓▓▓░░░░`
- 100%: `▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓`

## 実装フロー

### 1. ミッション開始時
```
1. タスクを分解し、エージェント一覧を決定
2. Phase 1 テンプレートで即レスを送信 → messageId を保持
3. リアクション 🔥 を付与
4. 📌 メッセージをピン止め（disable_notification: true）
5. 各エージェントをspawn
```

### 2. エージェント稼働中
```
1. エージェントのステータスを更新
2. Phase 2 テンプレートで message edit
3. 🧠 thinking行にエージェントの中間出力を表示
```

### 3. 部分完了時
```
1. 完了エージェントを ✅ に更新、残りはプログレス表示
2. Phase 3 テンプレートで message edit
3. リアクション 🔥 のまま
```

### 4. 全エージェント完了 + 不可逆操作あり
```
1. Phase 4 テンプレートで message edit + インラインボタン付与
2. リアクション → 👀 に切替
3. ユーザーのボタン押下を待つ
4. mc:approve → Phase 5 へ
5. mc:preview → 詳細を別メッセージで送信
6. mc:revise → ユーザーから修正指示を受け、再spawn
7. mc:abort → 中止、部分成果物を保存
```

### 5. 完了時
```
1. Phase 5 テンプレートで message edit（ボタン除去）
2. リアクション → 🎉 に切替
3. 📌 ピン解除
4. 成果物を docs/outputs/ に保存
```

### 6. エラー時
```
1. Phase ERROR テンプレートで message edit + エラーボタン付与
2. リアクション → ❌ に切替
3. mc:retry → 失敗エージェントを再spawn
4. mc:skip → 失敗エージェントをスキップ、残りを続行
5. mc:partial_complete → 成功分のみで完了
6. mc:abort → 全中止
```

## 投稿先（DM + チャンネル連動）

### DM（オペレーター向け — フル機能）
4+1層UXモデルの全機能。ピン止め、リアクション、プログレスバー、インラインボタン。

### チャンネル（@MIYABI_CHANNEL — ミッションログ）
ミッションの開始と完了を自動投稿。進捗の詳細はDMのみ。

| タイミング | DM | チャンネル |
|-----------|-----|-----------|
| ミッション開始 | Phase 1 INIT + 📌ピン | 🚀 ミッション開始通知 |
| 稼働中 | Phase 2-3 edit更新 | — （投稿しない） |
| 承認待ち | Phase 4 + ボタン | — （投稿しない） |
| 完了 | Phase 5 + 🎉 + アンピン | ✅ 完了レポート（成果物+Key Insights） |
| エラー | Phase ERROR + ボタン | — （投稿しない） |

### チャンネル投稿テンプレート

**ミッション開始:**
```
🚀 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗦𝗧𝗔𝗥𝗧𝗘𝗗
——————————————
📋 {mission_description}
🧩 {agent_count} agents deployed
——————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

**ミッション完了:**
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

チャンネルID: `-1003700344593` (@MIYABI_CHANNEL)

### マスターチケット（常駐ピン — DM内）

DM内に1つの常駐メッセージを維持。全ミッションの一覧を表示。
個別ミッションメッセージは一時ピン（完了でアンピン）。

```
📌 𝗠𝗜𝗦𝗢 𝗗𝗔𝗦𝗛𝗕𝗢𝗔𝗥𝗗
——————————————
🔥 #1 PPAL競合分析 (3/5 agents)
👀 #2 noteコンテンツ — 承認待ち
✅ #3 KAEDE論文調査 — 3m ago
——————————————
⏱ Today: 3 missions ∣ 💰 $0.45
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

マスターチケットは常時ピン。個別ミッションは完了時にアンピン。

## Unicode太字 変換表

通常 → 太字:
- A-Z: 𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭
- a-z: 𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇
- 0-9: 𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵

スモールキャップス:
- ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ

## 前提条件
- Telegram `reactionLevel`: `extensive` (config: `channels.telegram.reactionLevel`)
- `message` tool: `react`, `edit`, `send` アクション
- `sessions_spawn` + spawn完了通知で状態遷移をトリガー

## 関連スキル
- `miyabi-channel` — チャンネル投稿スキル
- `telegram-style` — Telegram書式ルール
- `main-context-handoff` — サブエージェント引き継ぎ
- `DESIGN-SYSTEM.md` — デザインシステム詳細
