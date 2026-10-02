#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/super-fetch"
mkdir -p "$cache"

# The skill lives in the read-only nix store, so deps and the entrypoint are
# mirrored into the cache dir where node can resolve node_modules by walking up.
# Held under a lock: concurrent fetches would otherwise run npm install over each
# other on the same tree.
(
  flock 9
  needs_install=0
  [ -d "$cache/node_modules" ] || needs_install=1
  if ! cmp -s "$here/package.json" "$cache/package.json"; then
    cp -f "$here/package.json" "$cache/package.json"
    needs_install=1
  fi
  cmp -s "$here/super-fetch.mjs" "$cache/super-fetch.mjs" ||
    cp -f "$here/super-fetch.mjs" "$cache/super-fetch.mjs"

  if [ "$needs_install" -eq 1 ]; then
    echo "super-fetch: installing dependencies (first run, ~30s)…" >&2
    npm install --prefix "$cache" --silent --no-audit --no-fund >&2
  fi
) 9>"$cache/.install.lock"

# Headed Chrome clears anti-bot challenges that headless never does, so a virtual
# display keeps the window off the real desktop. The display number is claimed
# with mkdir, which is atomic: a plain "is it free?" test lets two fetches pick
# the same number and then kill each other's server on exit. Letting Xvfb pick for
# itself is not an option either -- it starts from :0 and would collide with the
# real session. Without Xvfb the fetch still runs, just headless and more likely
# to be blocked.
if [ -z "${SUPER_FETCH_HEADLESS:-}" ] && command -v Xvfb >/dev/null; then
  # Markers this old outlived any possible fetch, so they were leaked by a killed
  # one. Age is the only safe test: a marker claimed seconds ago has no X lock
  # behind it yet, and reclaiming it would hand two fetches the same display.
  find /tmp -maxdepth 1 -type d -name '.super-fetch-x*' -mmin +10 \
    -exec rmdir {} + 2>/dev/null || true
  for n in $(seq 90 119); do
    [ -e "/tmp/.X${n}-lock" ] && continue
    mkdir "/tmp/.super-fetch-x${n}" 2>/dev/null || continue
    Xvfb ":$n" -screen 0 1280x800x24 >/dev/null 2>&1 &
    xvfb_pid=$!
    sleep 1
    if kill -0 "$xvfb_pid" 2>/dev/null; then
      trap 'kill "$xvfb_pid" 2>/dev/null || true; rmdir "/tmp/.super-fetch-x'"$n"'" 2>/dev/null || true' EXIT
      export DISPLAY=":$n"
      break
    fi
    rmdir "/tmp/.super-fetch-x${n}" 2>/dev/null || true
  done
fi
[ -n "${DISPLAY:-}" ] || export SUPER_FETCH_HEADLESS=1

node "$cache/super-fetch.mjs" "$@"
