import subprocess
import json
import sys

MIN_WS = 1
MAX_WS = 4

def get_active_workspace():
  result = subprocess.run(['hyprctl', 'activeworkspace', '-j'], capture_output=True, text=True)
  return json.loads(result.stdout)['id']

def cycle_workspace(direction):
  current_id = get_active_workspace()


  if direction == "next":
      target = MIN_WS if current_id >= MAX_WS else current_id + 1
  elif direction == "prev":
      target = MAX_WS if current_id <= MIN_WS else current_id - 1
  else:
      return

  subprocess.run(['hyprctl', 'dispatch', 'workspace', str(target)])

if __name__ == "__main__":
  if len(sys.argv) > 1:
    cycle_workspace(sys.argv[1])