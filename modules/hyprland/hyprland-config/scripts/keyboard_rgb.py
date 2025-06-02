import subprocess
import sys
import socket

PROFILES = ["off", "high"]
LAPTOP_HOSTNAME = "nktfh100-beta"


def is_laptop():
    return socket.gethostname() == LAPTOP_HOSTNAME


def set_profile(profile):
    subprocess.run(["asusctl", "-k", profile])


# Usage example: python keyboard_rgb.py off
if __name__ == "__main__":
    if not is_laptop():
        sys.exit(0)

    if len(sys.argv) > 1:
        profile = sys.argv[1]
        if profile in PROFILES:
            set_profile(profile)
        else:
            print(
                f"Invalid profile: {profile}. Valid profiles are: {', '.join(PROFILES)}"
            )
            sys.exit(1)
