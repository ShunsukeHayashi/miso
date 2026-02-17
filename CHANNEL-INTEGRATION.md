# CHANNEL-INTEGRATION.md
# MIYABI Channel 自動投稿仕様

## 概要

@MIYABI_CHANNEL (chatId: -1003700344593) へのミッション開始/完了通知の自動投稿設計。

- **DM内のMission Controlとは独立**：チャンネル向けに別途投稿ロジック
- **ノイズ抑制**：開始と完了のみ投稿

---

## 1. 投稿タイミング

| イベント | 投稿 | 内容 |
|---------|------|------|
| ミッション開始時 | ✅ | 🚀 開始通知 |
| ミッション完了時 | ✅ | ✅ 完了レポート（Key Insightsのみ） |
| エラー発生時 | ❌ | 投稿しない |
| 進捗中 | ❌ | 投稿しない |

---

## 2. 投稿テンプレート（確定版）

### ミッション開始通知

```
🚀 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗦𝗧𝗔𝗥𝗧𝗘𝗗
——————————————————
📋 {mission_description}
🧩 {agent_count} agents deployed
——————————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

### ミッション完了レポート

```
✅ 𝗠𝗜𝗦𝗦𝗜𝗢𝗡 𝗖𝗢𝗠𝗣𝗟𝗘𝗧𝗘
——————————————————
📋 {mission_description}
⏱ {total_time} ∣ 🧩 {agent_count} agents

↳ 💡 𝗞𝗘𝗬 𝗜𝗡𝗦𝗜𝗚𝗛𝗧𝗦
——————————————————
1. {insight_1}
2. {insight_2}
3. {insight_3}
——————————————————
🌸 ᴘᴏᴡᴇʀᴇᴅ ʙʏ ᴍɪʏᴀʙɪ
```

**変数定義:**

| 変数 | 説明 | 例 |
|------|------|-----|
| `{mission_description}` | ミッションの簡潔な説明 | "週次レポート作成" |
| `{agent_count}` | デプロイされたエージェント数 | "3" |
| `{total_time}` | 総所要時間 | "2m 34s" |
| `{insight_1..3}` | Key Insights（最大3件） | "コスト削減20%達成" |

---

## 3. プライバシールール

| 項目 | チャンネル出力可否 |
|------|------------------|
| 💰 コスト情報 | ❌ 出さない |
| エージェント名 | ✅ 出してOK |
| エラー詳細 | ❌ 出さない |
| 承認ゲート | DMのみ（チャンネルには出さない） |

---

## 4. 実装方法

### 投稿関数呼び出し

```typescript
// 開始通知
await message({
  action: "send",
  channel: "telegram",
  target: "-1003700344593",
  message: formatMissionStart({
    description: mission.description,
    agentCount: agents.length,
  }),
});

// 完了レポート
await message({
  action: "send",
  channel: "telegram",
  target: "-1003700344593",
  message: formatMissionComplete({
    description: mission.description,
    agentCount: agents.length,
    totalTime: formatDuration(mission.endTime - mission.startTime),
    insights: extractKeyInsights(mission.result).slice(0, 3),
  }),
});
```

### Key Insights 抽出ロジック（補助）

```typescript
function extractKeyInsights(result: MissionResult): string[] {
  // 成果物から重要なポイントを抽出
  // - 成果物の主要な成果
  // - 削減/改善の定量的な指標
  // - 技術的な新規性
  // 最大3件に制限
}
```

---

## 5. 実装チェックリスト

- [ ] ミッション開始フックにチャンネル投稿を追加
- [ ] ミッション完了フックにチャンネル投稿を追加
- [ ] Key Insights抽出関数の実装
- [ ] プライバシールール（コスト非表示）の適用
- [ ] エラーハンドリング（チャンネル投稿失敗時はDMへ通知）
- [ ] テスト: 実際に @MIYABI_CHANNEL に投稿確認

---

## 6. 付録: ターゲットチャンネル情報

- **チャンネル名:** @MIYABI_CHANNEL
- **chatId:** -1003700344593
- **目的:** チーム共有用の通知チャンネル
- **特性:** ノイズ抑制重視

---

*Document Version: 1.0*
*Created: 2026-02-17*
*MISO Project - Task T4*
