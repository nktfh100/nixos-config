import argparse
import os
import sys
import tempfile
import time
import urllib.error
import urllib.request

from playwright.sync_api import sync_playwright

CHROME = os.environ.get("WEBSHOT_CHROME", "@chrome@")

SIZES = {
    "desktop": (1440, 900),
    "laptop": (1280, 800),
    "tablet": (768, 1024),
    "mobile": (390, 844),
}


def parse_size(value):
    if value in SIZES:
        return value, SIZES[value]
    try:
        width, height = (int(n) for n in value.lower().split("x"))
    except ValueError:
        raise argparse.ArgumentTypeError(
            f"'{value}' is not one of {', '.join(SIZES)} or WIDTHxHEIGHT"
        )
    return value, (width, height)


def parse_args():
    parser = argparse.ArgumentParser(
        prog="webshot",
        description="Screenshot a web page with headless Chrome and report console errors.",
    )
    parser.add_argument("url")
    parser.add_argument(
        "-s", "--size", type=parse_size, action="append",
        help="desktop | laptop | tablet | mobile | WIDTHxHEIGHT (repeatable, default: desktop)",
    )
    parser.add_argument("-o", "--out", help="output directory (default: a new temp dir)")
    parser.add_argument("--name", default="shot", help="file name prefix (default: shot)")
    parser.add_argument("--full", action="store_true", help="capture the whole scrollable page")
    parser.add_argument("--selector", help="capture only this element")
    parser.add_argument("--wait-for", help="wait until this selector is visible")
    parser.add_argument(
        "--click", action="append", default=[],
        help="click this selector before capturing (repeatable, runs in order)",
    )
    parser.add_argument("--delay", type=int, default=300, help="extra ms to wait before capturing")
    parser.add_argument("--dark", action="store_true", help="emulate prefers-color-scheme: dark")
    parser.add_argument(
        "--server-timeout", type=int, default=60,
        help="seconds to wait for the server to start answering (default: 60)",
    )
    return parser.parse_args()


def wait_for_server(url, timeout):
    deadline = time.monotonic() + timeout
    while True:
        try:
            urllib.request.urlopen(url, timeout=5)
            return
        except urllib.error.HTTPError:
            return
        except (urllib.error.URLError, ConnectionError, TimeoutError) as error:
            if time.monotonic() > deadline:
                sys.exit(f"webshot: {url} did not answer within {timeout}s ({error})")
            time.sleep(1)


def capture(browser, args, label, size):
    width, height = size
    context = browser.new_context(
        viewport={"width": width, "height": height},
        device_scale_factor=1,
        has_touch=width < 600,
        color_scheme="dark" if args.dark else "light",
    )
    page = context.new_page()
    problems = []

    def on_console(msg):
        source = msg.location.get("url", "")
        if msg.type in ("error", "warning") and not source.endswith("/favicon.ico"):
            problems.append(f"console.{msg.type}: {msg.text}" + (f"  [{source}]" if source else ""))

    def on_response(res):
        if res.status >= 400:
            problems.append(f"HTTP {res.status}: {res.url}")

    page.on("console", on_console)
    page.on("response", on_response)
    page.on("pageerror", lambda error: problems.append(f"uncaught error: {error}"))
    page.on("requestfailed", lambda req: problems.append(f"request failed: {req.url} ({req.failure})"))

    response = page.goto(args.url, wait_until="load", timeout=45000)
    try:
        page.wait_for_load_state("networkidle", timeout=10000)
    except Exception:
        problems.append("note: network never went idle (polling/websocket?), captured anyway")
    if args.wait_for:
        page.wait_for_selector(args.wait_for, state="visible", timeout=15000)
    for selector in args.click:
        page.click(selector, timeout=10000)
        page.wait_for_timeout(300)
    page.wait_for_timeout(args.delay)

    path = os.path.join(args.out, f"{args.name}-{label}.png")
    if args.selector:
        page.locator(args.selector).first.screenshot(path=path)
    else:
        page.screenshot(path=path, full_page=args.full)

    print(f"== {label} ({width}x{height}) -> {path}")
    print(f"   status: {response.status if response else '?'}  title: {page.title()!r}  url: {page.url}")
    for line in problems:
        print(f"   {line}")
    if not problems:
        print("   no console errors or failed requests")
    context.close()


def main():
    args = parse_args()
    args.out = args.out or tempfile.mkdtemp(prefix="webshot-")
    os.makedirs(args.out, exist_ok=True)
    if args.url.startswith("http"):
        wait_for_server(args.url, args.server_timeout)
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path=CHROME, headless=True)
        for label, size in args.size or [parse_size("desktop")]:
            capture(browser, args, label, size)
        browser.close()


if __name__ == "__main__":
    main()
