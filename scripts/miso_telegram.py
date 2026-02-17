#!/usr/bin/env python3
"""Telegram Bot API pin/unpin ヘルパー"""

import json
import sys
from urllib.request import urlopen, Request

# 設定ファイルからbotToken読み込み
CONFIG_PATH = "/Users/shunsukehayashi/.openclaw/openclaw.json"


def _get_token() -> str:
    """Bot Tokenを取得"""
    with open(CONFIG_PATH) as f:
        return json.load(f)["channels"]["telegram"]["botToken"]


def _api_call(method: str, chat_id: int, message_id: int) -> dict:
    """Telegram API呼び出し"""
    token = _get_token()
    url = f"https://api.telegram.org/bot{token}/{method}"
    payload = json.dumps({"chat_id": chat_id, "message_id": message_id}).encode("utf-8")
    req = Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        with urlopen(req) as res:
            return json.loads(res.read())
    except Exception as e:
        return {"ok": False, "error": str(e)}


def pin_message(chat_id: int, message_id: int) -> dict:
    """メッセージをピン止め（通知なし）"""
    return _api_call("pinChatMessage", chat_id, message_id)


def unpin_message(chat_id: int, message_id: int) -> dict:
    """ピン解除"""
    return _api_call("unpinChatMessage", chat_id, message_id)


if __name__ == "__main__":
    # CLI使用: python3 miso_telegram.py pin|unpin chat_id message_id
    if len(sys.argv) != 4:
        print("Usage: python3 miso_telegram.py pin|unpin chat_id message_id")
        sys.exit(1)
    action, chat_id, message_id = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    if action == "pin":
        result = pin_message(chat_id, message_id)
    elif action == "unpin":
        result = unpin_message(chat_id, message_id)
    else:
        print("Error: action must be 'pin' or 'unpin'")
        sys.exit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
