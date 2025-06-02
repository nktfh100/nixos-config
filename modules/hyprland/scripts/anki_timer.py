import subprocess
import time


def anki_is_running():
    return subprocess.run(["pgrep", "anki"]).returncode == 0


def launch_anki():
    if not anki_is_running():
        subprocess.Popen(["anki"])


def main():
    while True:
        # Wait 1 hour
        time.sleep(60 * 60)
        launch_anki()


if __name__ == "__main__":
    main()
