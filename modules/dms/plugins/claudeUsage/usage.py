from datetime import date
import json
from pathlib import Path
import time
import urllib.error
import urllib.request


CREDENTIALS = Path.home() / ".claude" / ".credentials.json"
ENDPOINT = "https://api.anthropic.com/api/oauth/usage"
TODAY = Path.home() / ".cache" / "claude-usage" / "today.json"


def window(data):
    return {
        "percent": data.get("utilization") or 0,
        "resetsAt": data.get("resets_at"),
    } if data else None


def load_today():
    try:
        return json.loads(TODAY.read_text())
    except (OSError, ValueError):
        return None


def spent_today(weekly):
    saved = load_today()
    reset = saved and weekly < saved["last"]
    if not saved:
        state = {"start": weekly, "carried": 0}
    elif saved["date"] != date.today().isoformat():
        state = {"start": 0 if reset else saved["last"], "carried": 0}
    elif reset:
        state = {"start": 0, "carried": saved["carried"] + saved["last"] - saved["start"]}
    else:
        state = saved
    state = {**state, "date": date.today().isoformat(), "last": weekly}
    TODAY.parent.mkdir(parents=True, exist_ok=True)
    TODAY.write_text(json.dumps(state))
    return state["carried"] + weekly - state["start"]


def usage():
    try:
        login = json.loads(CREDENTIALS.read_text())["claudeAiOauth"]
        token = login["accessToken"]
        expires = login.get("expiresAt", 0) / 1000
    except (OSError, ValueError, KeyError, TypeError, AttributeError):
        return {"error": "Not logged in to Claude Code"}
    if expires < time.time():
        return {"error": "Login expired, open Claude Code to renew it"}
    request = urllib.request.Request(
        ENDPOINT,
        headers={
            "Authorization": f"Bearer {token}",
            "anthropic-beta": "oauth-2025-04-20",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            data = json.load(response)
        weekly = window(data.get("seven_day"))
        return {
            "plan": login.get("subscriptionType") or "",
            "session": window(data.get("five_hour")),
            "weekly": weekly,
            "today": spent_today(weekly["percent"]) if weekly else None,
        }
    except urllib.error.HTTPError as error:
        return {"error": f"Usage check failed ({error.code})"}
    except (OSError, ValueError, AttributeError):
        return {"error": "Usage check failed, offline?"}


print(json.dumps(usage()))
