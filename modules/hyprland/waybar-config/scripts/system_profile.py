import subprocess
import json
import sys
import socket

PROFILES = ["Quiet", "Performance"]
ICONS = {"Quiet": "󰾪", "Performance": "󰓅"}

LAPTOP_HOSTNAME = "nktfh100-beta"


def is_laptop():
    return socket.gethostname() == LAPTOP_HOSTNAME


def get_current_profile():
    try:
        output = subprocess.check_output(["asusctl", "profile", "-p"], text=True)
        for line in output.splitlines():
            if line.startswith("Active profile"):
                return line.split("is ")[1].strip()
    except Exception:
        return "Unknown"


def toggle_profile():
    current = get_current_profile()
    next_profile = "Performance" if current == "Quiet" else "Quiet"
    subprocess.run(["asusctl", "profile", "-P", next_profile])


def output_json(profile):
    icon = ICONS.get(profile, "󰈸")
    print(json.dumps({"text": f"{icon}", "class": profile.lower()}))


if __name__ == "__main__":
    if not is_laptop():
        print(json.dumps({"text": "", "tooltip": False, "class": "hidden"}))
        sys.exit(0)

    if len(sys.argv) > 1 and sys.argv[1] == "--toggle":
        toggle_profile()
    output_json(get_current_profile())
