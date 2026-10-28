import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

OPTIONS = ("animations:enabled", "decoration:blur:enabled", "decoration:shadow:enabled")


def command(*args):
    result = subprocess.run(args, capture_output=True, text=True, timeout=15)
    if result.returncode:
        raise RuntimeError(
            f"{args[0]}: {result.stderr.strip() or result.stdout.strip()}"
        )
    if args[0] == "hyprctl" and args[1] == "keyword" and result.stdout.strip() != "ok":
        raise RuntimeError(result.stdout.strip())
    return result.stdout.strip()


def on_battery(root=Path("/sys/class/power_supply")):
    supplies = list(root.iterdir())
    online = [p for p in supplies if (p / "online").exists()]
    batteries = [p for p in supplies if (p / "type").read_text().strip() == "Battery"]
    return bool(batteries) and not any(
        (p / "online").read_text().strip() == "1" for p in online
    )


class DesktopPolicy:
    def __init__(self):
        self.signature = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
        self.path = Path(os.environ["XDG_RUNTIME_DIR"]) / "battery-desktop.json"
        state_home = Path(
            os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))
        )
        self.state_path = state_home / "battery-desktop.json"
        self.state_path.parent.mkdir(parents=True, exist_ok=True)
        self.dms = os.environ.get("BATTERY_DESKTOP_DMS", "dms")
        self.saved = None
        self.motion_to_restore = None
        saved_path = self.state_path if self.state_path.exists() else self.path
        if saved_path.exists():
            try:
                saved = json.loads(saved_path.read_text())
                if saved["signature"] == self.signature:
                    self.saved = saved
                    self.persist()
                else:
                    self.motion_to_restore = saved["reduceMotion"]
                    self.path.unlink(missing_ok=True)
            except (ValueError, KeyError):
                self.clear_saved()

    def clear_saved(self):
        self.path.unlink(missing_ok=True)
        self.state_path.unlink(missing_ok=True)
        self.saved = None

    def persist(self):
        for path in (self.state_path, self.path):
            temporary = path.with_suffix(".tmp")
            temporary.write_text(json.dumps(self.saved) + "\n")
            temporary.replace(path)

    def capture(self):
        led = command("asusctl", "leds", "get").split(":")[-1].strip().lower()
        self.saved = {
            "signature": self.signature,
            "options": {
                key: json.loads(command("hyprctl", "getoption", key, "-j"))["int"]
                for key in OPTIONS
            },
            "reduceMotion": json.loads(
                command(self.dms, "ipc", "call", "settings", "get", "reduceMotion")
            ),
            "shader": any(
                plugin["name"] == "HyprWindowShade"
                for plugin in json.loads(command("hyprctl", "plugin", "list", "-j"))
            ),
            "brightness": int(command("brightnessctl", "get")),
            "brightnessApplied": False,
            "led": {"medium": "med"}.get(led, led),
            "monitors": {
                monitor["name"]: monitor
                for monitor in json.loads(command("hyprctl", "monitors", "-j"))
                if monitor["name"].startswith("eDP-")
            },
        }
        self.persist()

    def apply_refresh(self, battery):
        for monitor in json.loads(command("hyprctl", "monitors", "-j")):
            if not monitor["name"].startswith("eDP-"):
                continue
            previous = self.saved.setdefault("monitors", {}).get(monitor["name"])
            if battery:
                resolution = f'{monitor["width"]}x{monitor["height"]}'
                if f"{resolution}@60.00Hz" not in monitor["availableModes"]:
                    continue
                if previous is None:
                    self.saved["monitors"][monitor["name"]] = monitor
                    self.persist()
                refresh = 60
            elif previous:
                refresh = previous["refreshRate"]
            else:
                continue
            if abs(monitor["refreshRate"] - refresh) < 0.1:
                continue
            selector = f'desc:{monitor["description"]}'
            mode = (
                f'{selector},{monitor["width"]}x{monitor["height"]}@{refresh},'
                f'{monitor["x"]}x{monitor["y"]},{monitor["scale"]}'
            )
            command("hyprctl", "keyword", "monitor", mode)

    def apply(self, battery):
        if self.motion_to_restore is not None:
            command(
                self.dms,
                "ipc",
                "call",
                "settings",
                "set",
                "reduceMotion",
                str(self.motion_to_restore).lower(),
            )
            self.clear_saved()
            self.motion_to_restore = None
        if battery:
            if self.saved is None:
                self.capture()
            if self.saved["shader"]:
                command("lucifer-smoke-mode", "off")
            command(self.dms, "ipc", "call", "settings", "set", "reduceMotion", "true")
            for key in OPTIONS:
                command("hyprctl", "keyword", key, "false")
            if not self.saved["brightnessApplied"]:
                cap = int(command("brightnessctl", "max")) // 5
                brightness = max(1, min(self.saved["brightness"], cap))
                command("brightnessctl", "set", str(brightness))
                self.saved["brightnessApplied"] = True
                self.persist()
            command("asusctl", "leds", "set", "off")
            self.apply_refresh(True)
        elif self.saved:
            if self.saved["shader"]:
                command("lucifer-smoke-mode", "on")
            command(
                self.dms,
                "ipc",
                "call",
                "settings",
                "set",
                "reduceMotion",
                str(self.saved["reduceMotion"]).lower(),
            )
            for key, value in self.saved["options"].items():
                command("hyprctl", "keyword", key, str(bool(value)).lower())
            command("brightnessctl", "set", str(self.saved["brightness"]))
            command("asusctl", "leds", "set", self.saved["led"])
            self.apply_refresh(False)
            self.clear_saved()


def main():
    lock = (Path(os.environ["XDG_RUNTIME_DIR"]) / "battery-desktop.lock").open("w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return
    policy = DesktopPolicy()
    previous = None
    while True:
        try:
            state = on_battery()
            if state != previous:
                policy.apply(state)
                previous = state
        except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
            print(f"Battery desktop: {error}", file=sys.stderr, flush=True)
        time.sleep(10)


if __name__ == "__main__":
    main()
