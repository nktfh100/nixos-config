# Stolen from:
# https://github.com/HellZEras/SpotifyWaybar

import subprocess
import json
import html
import datetime  # Added for time formatting


def get_formatted_time():
    now = datetime.datetime.now()
    return now.strftime("%H:%M - %a, %d %b %Y").lower()


def spotify_status():
    result = subprocess.run(
        ["playerctl", "--player=spotify", "status"], capture_output=True, text=True
    )
    result = result.stdout.strip()
    if result == "Paused":
        return "Paused"
    elif result == "No players found":
        return "Not Found"
    elif result == "Playing":
        return "Playing"
    else:
        return "Unknown"


def parse_spotify_data(data):
    parsed_data = {}
    artist, title = None, None

    lines = data.splitlines()
    for line in lines:
        if "artist" in line:
            index = line.find("artist") + len("artist")
            artist = html.escape(line[index:].strip())
        elif "title" in line:
            index = line.find("title") + len("title")
            title = html.escape(line[index:].strip())

    if artist and title:
        return f" {title} - {artist}"
    else:
        return "Unknown song"


def main():
    status = spotify_status()
    if status == "Playing":
        result = subprocess.run(
            ["playerctl", "--player=spotify", "metadata"],
            capture_output=True,
            text=True,
        )
        to_write = parse_spotify_data(result.stdout)
        data = {"text": to_write}
    else:
        # Show formatted time when nothing is playing
        data = {"text": get_formatted_time()}

    print(json.dumps(data))


if __name__ == "__main__":
    main()
