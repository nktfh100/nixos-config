import argparse
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


SYSFS = Path("/sys")
PROFILES = {"quiet": "Quiet", "balanced": "Balanced", "performance": "Performance"}


def read(path):
    try:
        return path.read_text().strip()
    except OSError:
        return ""


def status():
    platform = read(SYSFS / "firmware/acpi/platform_profile")
    battery = next(iter(sorted((SYSFS / "class/power_supply").glob("BAT*"))), None)
    capacity = read(battery / "capacity") if battery else ""
    battery_status = read(battery / "status") if battery else ""
    devices = sorted((SYSFS / "bus/pci/devices").glob("*"))
    gpu = next(
        (
            device
            for device in devices
            if read(device / "vendor") == "0x10de"
            and read(device / "class").startswith("0x03")
        ),
        None,
    )
    power = read(gpu / "power_state") if gpu else ""
    runtime = read(gpu / "power/runtime_status") if gpu else ""
    state = "Unavailable" if gpu is None else "Unknown"
    if power in ("D3cold", "D3hot") or runtime == "suspended":
        state = "Off"
    elif power == "D0" or runtime == "active":
        state = "On"
    return {
        "profile": PROFILES.get(platform, "Unknown"),
        "profileAvailable": platform in PROFILES,
        "batteryAvailable": battery is not None,
        "batteryLevel": int(capacity) if capacity.isdigit() else None,
        "batteryCharging": battery_status == "Charging",
        "onBattery": battery is not None and not any(
            read(path) == "1" for path in (SYSFS / "class/power_supply").glob("*/online")
        ),
        "gpuState": state,
        "gpuPowerState": power,
        "gpuRuntimeState": runtime,
        "error": "",
    }


def set_profile(profile):
    if os.environ.get("DMS_LUCIFER_PREVIEW") == "1":
        return "PC mode changes are disabled in preview."
    if not status()["profileAvailable"]:
        return "ASUS platform profiles are unavailable on this computer."
    try:
        result = subprocess.run(
            ["asusctl", "profile", "set", profile],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode:
            return (
                result.stderr.strip()
                or result.stdout.strip()
                or "ASUS profile change failed."
            )
        for _ in range(10):
            if status()["profile"] == profile:
                return ""
            time.sleep(0.1)
        return f"ASUS did not confirm the requested {profile} profile."
    except (OSError, subprocess.TimeoutExpired) as error:
        return str(error)


def inhibit_lid():
    if os.environ.get("DMS_LUCIFER_PREVIEW") == "1":
        return 0
    child = subprocess.Popen(
        [
            "systemd-inhibit",
            "--no-ask-password",
            "--what=handle-lid-switch",
            "--mode=block",
            "--who=Infernal Stay Awake",
            "--why=Stay Awake is enabled",
            "cat",
        ],
        stdin=sys.stdin,
        stdout=subprocess.DEVNULL,
        start_new_session=True,
    )

    def stop(signum, frame):
        try:
            os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    return child.wait()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", choices=["Quiet", "Performance"])
    parser.add_argument("--inhibit-lid", action="store_true")
    args = parser.parse_args()
    if args.inhibit_lid:
        return inhibit_lid()
    error = set_profile(args.profile) if args.profile else ""
    result = status()
    result["error"] = error
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
