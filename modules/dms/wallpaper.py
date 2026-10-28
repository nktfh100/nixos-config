import fcntl
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys

catalog = json.loads(Path(os.environ["THEME_WALLPAPERS"]).read_text())
artworks = {item["id"]: item for item in catalog}
runtime = Path(os.environ["XDG_RUNTIME_DIR"])
state_dir = (
    Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")))
    / "desktop-theme"
    / os.environ["DESKTOP_THEME"]
)
state_dir.mkdir(parents=True, exist_ok=True)
state_file = state_dir / "wallpaper.json"
control_socket = runtime / "theme-wallpaper-control.sock"


def send(path, value):
    with socket.socket(socket.AF_UNIX) as client:
        client.settimeout(12)
        client.connect(str(path))
        client.sendall(json.dumps(value).encode() + b"\n")
        return client.recv(8192)


def initial_state():
    default_id = catalog[0]["id"]
    value = {"id": default_id}
    try:
        saved = json.loads(state_file.read_text())
        if isinstance(saved, dict) and isinstance(saved.get("id"), str):
            value["id"] = saved["id"]
    except (OSError, ValueError):
        pass
    if value["id"] not in artworks:
        value["id"] = default_id
    return value


def serve():
    lock = (runtime / "theme-wallpaper.lock").open("w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return
    state = initial_state()
    child = None
    settings_file = (
        Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
        / "DankMaterialShell/settings.json"
    )

    def read_motion():
        try:
            battery_state = runtime / "battery-desktop.json"
            if battery_state.exists():
                return bool(json.loads(battery_state.read_text())["reduceMotion"])
            return bool(
                json.loads(settings_file.read_text()).get("reduceMotion", False)
            )
        except (OSError, ValueError):
            return False

    def stop_child():
        if child and child.poll() is None:
            child.terminate()
            try:
                child.wait(timeout=3)
            except subprocess.TimeoutExpired:
                child.kill()
                child.wait()

    def save():
        state["path"] = artworks[state["id"]]["path"]
        state["backend"] = "hyprpaper"
        temp = state_file.with_suffix(".tmp")
        temp.write_text(json.dumps(state) + "\n")
        temp.replace(state_file)

    def apply():
        nonlocal child
        stop_child()
        config = runtime / "theme-hyprpaper.conf"
        config.write_text(
            f'splash = false\nwallpaper {{\n monitor =\n path = {artworks[state["id"]]["path"]}\n fit_mode = cover\n}}\n'
        )
        child = subprocess.Popen(["hyprpaper", "-c", str(config)])
        save()

    def finish(*_):
        raise SystemExit

    signal.signal(signal.SIGTERM, finish)
    signal.signal(signal.SIGINT, finish)
    control_socket.unlink(missing_ok=True)
    try:
        with socket.socket(socket.AF_UNIX) as server:
            server.bind(str(control_socket))
            control_socket.chmod(0o600)
            server.listen(4)
            server.settimeout(1)
            apply()
            last_reduced = read_motion()
            if last_reduced:
                subprocess.run(
                    ["hyprctl", "keyword", "animations:enabled", "false"],
                    check=False,
                    stdout=subprocess.DEVNULL,
                )
            while True:
                server.settimeout(10 if (runtime / "battery-desktop.json").exists() else 1)
                if child and child.poll() is not None:
                    apply()
                reduced = read_motion()
                if reduced != last_reduced:
                    last_reduced = reduced
                    subprocess.run(
                        [
                            "hyprctl",
                            "keyword",
                            "animations:enabled",
                            "false" if reduced else "true",
                        ],
                        check=False,
                        stdout=subprocess.DEVNULL,
                    )
                try:
                    client, _ = server.accept()
                except socket.timeout:
                    continue
                with client:
                    client.settimeout(3)
                    try:
                        request = json.loads(client.recv(8192))
                        action, value = request["action"], request.get("value")
                        if action == "select":
                            if value not in artworks:
                                raise ValueError("Unknown wallpaper")
                            state["id"] = value
                            apply()
                        elif action == "reduce":
                            on_battery = (runtime / "battery-desktop.json").exists()
                            last_reduced = read_motion() if on_battery else value == "on"
                            subprocess.run(
                                [
                                    "hyprctl",
                                    "keyword",
                                    "animations:enabled",
                                    "false" if on_battery or last_reduced else "true",
                                ],
                                check=False,
                                stdout=subprocess.DEVNULL,
                            )
                        elif action != "status":
                            raise ValueError("Unknown action")
                        client.sendall(json.dumps(state).encode())
                    except (OSError, ValueError, KeyError) as error:
                        try:
                            client.sendall(json.dumps({"error": str(error)}).encode())
                        except OSError:
                            pass
    finally:
        stop_child()
        control_socket.unlink(missing_ok=True)


if len(sys.argv) == 1 or sys.argv[1] == "start":
    serve()
else:
    try:
        result = json.loads(
            send(
                control_socket,
                {
                    "action": sys.argv[1],
                    "value": sys.argv[2] if len(sys.argv) > 2 else None,
                },
            )
        )
        print(json.dumps(result))
        sys.exit(1 if "error" in result else 0)
    except OSError as error:
        print(f"Wallpaper service unavailable: {error}", file=sys.stderr)
        sys.exit(1)
