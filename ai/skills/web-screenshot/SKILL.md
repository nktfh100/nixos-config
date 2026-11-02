---
name: web-screenshot
description: Take screenshots of a web page or local dev server to visually verify web/frontend work, and catch console errors and failed requests at the same time. Use whenever the user asks to screenshot, "check how it looks", verify UI changes visually, test responsive/mobile layouts, or confirm a page renders — and proactively after making visual changes to a web app.
---

Use `webshot`. It is already installed and drives the system Chrome headlessly.

```bash
webshot <url> [-s SIZE]... [--full] [--selector CSS] [--wait-for CSS] [--click CSS]... [--dark] [-o DIR] [--name PREFIX]
```

| Flag | What it does |
| --- | --- |
| `-s SIZE` | `desktop` (1440x900, default), `laptop`, `tablet`, `mobile`, or `WIDTHxHEIGHT`. Repeatable |
| `--full` | Whole scrollable page (scrolls first so lazy images load). Very tall shots get shrunk when viewed, so prefer `--selector` for one section |
| `--selector CSS` | Capture only one element |
| `--wait-for CSS` | Wait for an element to be visible first |
| `--click CSS` | Click first (menu, modal, tab). Repeatable, runs in order |
| `--before FILE` | Python file with `before(page)` for custom flows (login, forms). See below |
| `--save-session FILE` / `--session FILE` | Save cookies + localStorage after the run / start a later run with them |
| `--dark` | Emulate dark mode |
| `--delay MS` | Extra wait before capturing (default 300). CSS animations are already frozen at their end |
| `-o DIR` / `--name PREFIX` | Output dir (default: new temp dir) and file prefix, e.g. for before/after |
| `--server-timeout S` | How long to wait for the URL to answer (default 60) |

For each size it prints the PNG path, HTTP status, title, and every console error/warning, uncaught exception, failed request and 4xx/5xx response. If a `--click`/`--wait-for` fails, it is reported and the screenshot is still taken. Exit code 1 means something is in the report.

## Workflow

1. **Server running?** If not, start the dev server in the background (Bash `run_in_background: true`; never foreground). Read its output for the real port. `webshot` waits for the URL to answer, so call it right away.
2. **Shoot:** `webshot http://localhost:5173 -s desktop -s mobile`
3. **Look at every PNG** with the `Read` tool (Codex: `view_image`), and read the text report. A page that looks right but logs errors is not done.
4. Fix, re-shoot, look again. Tell the user what you saw.
5. Stop any server you started.

Static files: `webshot file:///absolute/path/index.html`.

## Don'ts

- Don't `npx playwright install` or download any browser — they don't run on NixOS.
- Don't open a visible browser or `xdg-open` to "check" a page.
- Don't write a one-off Playwright script. Use `--before` instead.

## Login and other custom flows

Each run starts logged out. Write a `before(page)` function (any [Playwright Python](https://playwright.dev/python/docs/api/class-page) code) that ends on the page you want shot. Keep it in `/tmp`, not the project:

```python
# /tmp/login.py, e.g. for a mock OAuth server
def before(page):
    page.get_by_placeholder("Enter any user/subject").fill("test-user")
    page.get_by_role("button", name="Sign-in").click()
    page.wait_for_url("http://localhost:3000/**")
```

```bash
webshot http://localhost:3000 --before /tmp/login.py --save-session /tmp/session.json   # log in once
webshot http://localhost:3000/settings --session /tmp/session.json -s mobile            # reuse after
```

`before` runs after the first page load; webshot waits for the page to settle again afterwards. Errors logged before it runs (e.g. 401s on the login redirect) are dropped. Don't use `wait_for_load_state("networkidle")` in it — apps with live connections never go idle. Use `wait_for_url` or wait for an element. If a reused session lands on the login page again, it expired: rerun with `--before`. No test account or mock login? Ask the user.
