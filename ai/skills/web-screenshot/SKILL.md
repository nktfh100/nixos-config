---
name: web-screenshot
description: Take screenshots of a web page or local dev server to visually verify web/frontend work, and catch console errors and failed requests at the same time. Use whenever the user asks to screenshot, "check how it looks", verify UI changes visually, test responsive/mobile layouts, or confirm a page renders — and proactively after making visual changes to a web app.
---

Use the `webshot` command. It is already installed, drives the system Chrome headlessly, and needs no setup.

```bash
webshot <url> [-s SIZE]... [--full] [--selector CSS] [--wait-for CSS] [--click CSS]... [--dark] [-o DIR] [--name PREFIX]
```

| Flag | What it does |
| --- | --- |
| `-s SIZE` | `desktop` (1440x900, default), `laptop`, `tablet`, `mobile`, or `WIDTHxHEIGHT`. Repeat for several sizes in one run |
| `--full` | Capture the whole scrollable page instead of just the first screen |
| `--selector CSS` | Capture only one element |
| `--wait-for CSS` | Wait until that element is visible before capturing |
| `--click CSS` | Click something first (open a menu, modal, tab). Repeatable, runs in order |
| `--dark` | Emulate dark mode |
| `--delay MS` | Extra wait before capturing (default 300) — raise for animations |
| `-o DIR` | Where to save (default: a new temp dir; the path is printed) |
| `--name PREFIX` | File name prefix, useful for before/after shots |

For each size it prints the saved file path, HTTP status, page title, and every console error/warning, uncaught exception, failed request and 4xx/5xx response.

## Workflow

1. **Make sure a server is running.** If the project's dev server isn't already up, start it **in the background** — never in the foreground, or you will hang forever:
   - Claude Code: Bash with `run_in_background: true`, e.g. `npm run dev`
   - Other agents: `nohup npm run dev > /tmp/dev-server.log 2>&1 &`

   Check the server's output for the real port rather than guessing. `webshot` waits up to 60s for the URL to start answering, so you can call it right after starting the server.
2. **Take the shot:** `webshot http://localhost:5173 -s desktop -s mobile`
3. **Look at the image.** Taking it is not verifying it. Open every PNG it printed:
   - Claude Code: the `Read` tool on the file path
   - Codex: the `view_image` tool on the file path
4. **Read the text report too.** A page that looks right but logs errors is not done.
5. Fix what's wrong, re-shoot, look again. Tell the user what you saw, not just that you took a screenshot.
6. Stop any dev server you started once you're finished.

Static HTML with no server: `webshot file:///absolute/path/index.html`.

## Don'ts

- Don't run `npx playwright install`, `playwright install-deps`, or pip/npm-install a browser. Downloaded browsers do not run on NixOS; `webshot` already works.
- Don't open a visible browser window or use `xdg-open` to "check" a page — you can't see it.
- Don't write your own one-off Playwright/Puppeteer screenshot script. If you truly need a custom flow (logging in, filling a form), use the project's own Playwright with `executablePath: "google-chrome-stable"` instead of a downloaded browser.
- Don't report success from the terminal output alone — always view the image.

## Pages behind a login

`webshot` starts with a fresh browser each time, so it sees the logged-out page. Ask the user for a test account or a dev-only auth bypass rather than guessing.
