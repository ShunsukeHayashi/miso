# SPAWN-INTEGRATION.md

## 概要

OpenClawの`sessions_spawn`で起動したサブエージェントの完了通知をトリガーに、Mission Controlボードを自動更新する設計。

---

## 1. ミッション開始フロー

### 1.1 前提
- タスク分解済み
- エージェント一覧決定済み
- 不可逆操作の有無判定済み

### 1.2 実行手順

```python
# 1. Phase 1 INITメッセージ送信
init_msg = await message_send(
    channel=MISSION_CONTROL_CHANNEL,
    message=mission_board_template(
        mission_name="...",
        agents=[...],
        phase=1,
        irreversible=False
    )
)
message_id = init_msg.messageId

# 2. ピン止め
await miso_telegram_pin(message_id)

# 3. リアクション🔥
await message_react(channel=MISSION_CONTROL_CHANNEL, messageId=message_id, emoji="🔥")

# 4. 各エージェントをspawn
agent_states = {}
for agent_name, agent_task in agents.items():
    result = await sessions_spawn(
        prompt=agent_task,
        label=agent_name,  # 完了通知の識別に使用
        ...
    )
    agent_states[agent_name] = {
        "status": "INIT",
        "subagent_session": result.session,
        "messageId": message_id,
        "findings": None
    }

# 5. 全エージェントの状態をRUNNINGに遷移
for agent_name in agent_states:
    agent_states[agent_name]["status"] = "RUNNING"

# 6. ミッションボード更新（Phase 2）
await message_edit(
    channel=MISSION_CONTROL_CHANNEL,
    messageId=message_id,
    message=update_board(
        phase=2,
        agent_states=agent_states,
        progress=0
    )
)
```

---

## 2. エージェント完了時のフロー

### 2.1 完了通知の検知

```
"A subagent task X just completed/failed"
```

このパターンをログまたはイベントストリームで検知。

```python
# 正規表現で抽出
pattern = r'A subagent task (.*?) just (completed|failed)'
match = re.search(pattern, notification)

agent_name = match.group(1)
status = "DONE" if match.group(2) == "completed" else "ERROR"
```

### 2.2 状態更新

```python
# 該当エージェントの状態を更新
agent_states[agent_name]["status"] = status

# 完了時はFindingsを要約
if status == "DONE":
    findings = await summarize_findings(agent_name)
    agent_states[agent_name]["findings"] = findings
```

### 2.3 ミッションボード更新

```python
# Phase判定・遷移
done_count = sum(1 for s in agent_states.values() if s["status"] == "DONE")
error_count = sum(1 for s in agent_states.values() if s["status"] == "ERROR")
total = len(agent_states)

if error_count > 0:
    phase = "ERROR"
elif done_count == total:
    # 全員完了
    if has_irreversible_operations:
        phase = 4
    else:
        phase = 5
else:
    phase = 3  # 実行中

# 進捗計算
progress = int(done_count / total * 100)

# ボード更新
await message_edit(
    channel=MISSION_CONTROL_CHANNEL,
    messageId=message_id,
    message=update_board(
        phase=phase,
        agent_states=agent_states,
        progress=progress
    )
)
```

### 2.4 全員完了時の処理

#### Phase 4（承認ゲートあり）
```python
await message_react(channel=MISSION_CONTROL_CHANNEL, messageId=message_id, emoji="👀")
# 承認ボタンを含める
```

#### Phase 5（完了）
```python
await message_react(channel=MISSION_CONTROL_CHANNEL, messageId=message_id, emoji="🎉")
await miso_telegram_unpin(message_id)
```

---

## 3. エラー時のフロー

```python
# Phase ERROR
agent_states[agent_name]["status"] = "ERROR"

await message_edit(
    channel=MISSION_CONTROL_CHANNEL,
    messageId=message_id,
    message=update_board(
        phase="ERROR",
        agent_states=agent_states,
        error_message=f"{agent_name}でエラー発生",
        retry_button=True
    )
)

await message_react(channel=MISSION_CONTROL_CHANNEL, messageId=message_id, emoji="❌")
```

---

## 4. ステータス判定ロジック

### 4.1 エージェント状態遷移

```
INIT → RUNNING → DONE
            ↘ ERROR
```

### 4.2 プログレスバー計算

```python
progress = (done_count / total_agents) * 100

# 表示例: ████████░░░░░░░░ 40%
```

### 4.3 Phase判定ルール

| 条件 | Phase | 説明 |
|------|-------|------|
| 初期化中 | 1 | INITメッセージ送信直後 |
| 実行中 | 2 | 全エージェントRUNNING |
| 部分完了 | 3 | 1以上がDONE、未完了あり |
| 承認待ち | 4 | 全員完了 + 不可逆操作あり |
| 完了 | 5 | 全員完了 + 不可逆操作なし |
| エラー | ERROR | いずれかがERROR |

---

## 5. データ構造

### 5.1 agent_states

```python
{
    "agent_name": {
        "status": "INIT | RUNNING | DONE | ERROR",
        "subagent_session": "session-id",
        "messageId": "telegram-message-id",
        "findings": "要約された結果"
    },
    ...
}
```

### 5.2 ミッションボードテンプレート

```
🔥 ミッション: {mission_name}

📊 進捗: [████░░░░] 40%

🧠 エージェント:
✅ agent1 - DONE
   Findings: 要約...
🔄 agent2 - RUNNING
⏳ agent3 - INIT

Phase: {phase}
{buttons}
```

---

## 6. 実装上の注意点

1. **messageIdの管理**: 初期化メッセージのIDを保持し、全更新で使用
2. **labelの重要性**: spawn時のlabelで完了通知のエージェントを識別
3. **並列性**: 各エージェントの完了順序に依存しない設計
4. **不可逆操作判定**: ミッション開始時に判定し、Phase 4/5を決定
5. **エラーハンドリング**: 単一エージェントのエラーで全体を止めない

---

## 7. 次ステップ

- `sessions_spawn`の完了通知フォーマット確認
- `miso_telegram.py`のpin/unpin実装
- Phaseテンプレートの作成
