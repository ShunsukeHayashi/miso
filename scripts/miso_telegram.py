#!/usr/bin/env python3
"""Telegram Bot API pin/unpin ヘルパー"""

import json
import os
import sys
from pathlib import Path
from urllib.request import urlopen, Request


def _get_config_path() -> Path:
    """設定ファイルパスを解決（環境変数またはデフォルト）"""
    env_path = os.environ.get("OPENCLAW_CONFIG")
    if env_path:
        return Path(env_path)
    return Path.home() / ".openclaw" / "openclaw.json"


def _get_token() -> str:
    """Bot Tokenを取得"""
    config_path = _get_config_path()
    try:
        with open(config_path) as f:
            return json.load(f)["channels"]["telegram"]["botToken"]
    except FileNotFoundError:
        raise FileNotFoundError(f"設定ファイルが見つかりません: {config_path}")
    except KeyError:
        raise KeyError("設定ファイルに botToken が見つかりません: channels.telegram.botToken")


def _api_call(method: str, payload: dict) -> dict:
    """Telegram API呼び出し"""
    token = _get_token()
    url = f"https://api.telegram.org/bot{token}/{method}"
    req = Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"})
    try:
        with urlopen(req) as res:
            return json.loads(res.read())
    except Exception as e:
        return {"ok": False, "error": str(e)}


def pin_message(chat_id: int, message_id: int) -> dict:
    """メッセージをピン止め（通知なし）"""
    payload = {"chat_id": chat_id, "message_id": message_id, "disable_notification": True}
    return _api_call("pinChatMessage", payload)


def unpin_message(chat_id: int, message_id: int) -> dict:
    """ピン解除"""
    payload = {"chat_id": chat_id, "message_id": message_id}
    return _api_call("unpinChatMessage", payload)


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
