#!/usr/bin/env bash

# Shows whether the laptop's NVIDIA dGPU is awake (D0) or asleep (D3cold)

[ "$(cat /proc/sys/kernel/hostname)" = "nktfh100-beta" ] || { echo '{}'; exit 0; }

state=""
for dev in /sys/bus/pci/devices/*; do
  [ "$(cat "$dev/vendor" 2>/dev/null)" = "0x10de" ] || continue
  case "$(cat "$dev/class" 2>/dev/null)" in
    0x03*) state=$(cat "$dev/power_state" 2>/dev/null); break ;;
  esac
done

[ -z "$state" ] && { echo '{}'; exit 0; }

if [ "$state" = "D0" ]; then
  echo "{\"text\":\"󰢮 on\",\"class\":\"gpu-on\",\"tooltip\":\"dGPU active ($state) — drawing power\"}"
else
  echo "{\"text\":\"󰢮 off\",\"class\":\"gpu-off\",\"tooltip\":\"dGPU asleep ($state)\"}"
fi
