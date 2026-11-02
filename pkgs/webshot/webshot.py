import argparse
import os
import runpy
import sys
import tempfile
import time
import urllib.error
import urllib.request
from collections import Counter

from playwright.sync_api import Error as PlaywrightError
from playwright.sync_api import sync_playwright

CHROME = os.environ.get("WEBSHOT_CHROME", "@chrome@")
MAX_LINE = 300

SIZES = {
    "desktop": (1440, 900),
    "laptop": (1280, 800),
    "tablet": (768, 1024),
    "mobile": (390, 844),
}

SCROLL_THROUGH_PAGE = """async () => {
    for (let step = 0; step < 50 && scrollY + innerHeight < document.body.scrollHeight; step++) {
        scrollBy(0, innerHeight);
        await new Promise(resolve => setTimeout(resolve, 150));
    }
    scrollTo(0, 0);
}"""


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
        epilog="Exits 1 if any page had errors, failed requests, or a step that could not run.",
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
    parser.add_argument(
        "--before", metavar="FILE",
        help="python file defining before(page); runs after load, before --wait-for/--click (login flows)",
    )
    parser.add_argument("--session", metavar="FILE", help="start with cookies/localStorage saved by --save-session")
    parser.add_argument("--save-session", metavar="FILE", help="save cookies/localStorage here after capturing")
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


def shorten(text):
    text = " ".join(text.split())
    return text if len(text) <= MAX_LINE else text[:MAX_LINE] + "…"


def is_favicon(url):
    return url.split("?")[0].endswith("/favicon.ico")


def click(page, selector):
    page.click(selector, timeout=10000)
    page.wait_for_timeout(300)


def capture(browser, args, label, size):
    width, height = size
    context = browser.new_context(
        viewport={"width": width, "height": height},
        device_scale_factor=1,
        has_touch=width < 600,
        color_scheme="dark" if args.dark else "light",
        storage_state=args.session,
    )
    page = context.new_page()
    problems = Counter()
    notes = []

    def report(line):
        problems[shorten(line)] += 1

    def attempt(step, action):
        try:
            action()
            return True
        except Exception as error:
            report(f"{step} failed: {type(error).__name__}: {(str(error) or '-').splitlines()[0]}")
            return False

    def on_console(msg):
        source = msg.location.get("url", "")
        if msg.type not in ("error", "warning") or is_favicon(source):
            return
        if msg.text.startswith("Failed to load resource"):
            return
        report(f"console.{msg.type}: {msg.text}" + (f"  [{source}]" if source else ""))

    def on_response(res):
        if res.status >= 400 and not is_favicon(res.url):
            report(f"HTTP {res.status}: {res.url}")

    def on_request_failed(req):
        if not is_favicon(req.url):
            report(f"request failed: {req.url} ({req.failure})")

    page.on("console", on_console)
    page.on("response", on_response)
    page.on("pageerror", lambda error: report(f"uncaught error: {error}"))
    page.on("requestfailed", on_request_failed)

    def settle():
        try:
            page.wait_for_load_state("load", timeout=15000)
            page.wait_for_load_state("networkidle", timeout=10000)
        except PlaywrightError:
            notes[:] = ["network never went idle (polling/websocket?), captured anyway"]

    responses = []
    loaded = attempt("loading page", lambda: responses.append(page.goto(args.url, wait_until="load", timeout=45000)))
    if loaded:
        settle()
        if args.before:
            problems.clear()
            if attempt("--before", lambda: args.before_fn(page)):
                settle()
        if args.wait_for:
            attempt(f"--wait-for {args.wait_for}", lambda: page.wait_for_selector(args.wait_for, state="visible", timeout=15000))
        all(attempt(f"--click {selector}", lambda selector=selector: click(page, selector)) for selector in args.click)
        if args.full:
            page.evaluate(SCROLL_THROUGH_PAGE)
        page.wait_for_timeout(args.delay)

    path = os.path.join(args.out, f"{args.name}-{label}.png")
    if args.selector:
        shot = attempt(f"--selector {args.selector}", lambda: page.locator(args.selector).first.screenshot(path=path, animations="disabled", timeout=10000))
    else:
        shot = attempt("screenshot", lambda: page.screenshot(path=path, full_page=args.full, animations="disabled"))

    response = responses[0] if responses else None
    print(f"== {label} ({width}x{height}) -> {path if shot else 'no screenshot'}")
    print(f"   status: {response.status if response else '?'}  title: {page.title()!r}  url: {page.url}")
    for line, count in problems.items():
        print(f"   {line}" + (f"  (x{count})" if count > 1 else ""))
    for line in notes:
        print(f"   note: {line}")
    if not problems:
        print("   no console errors or failed requests")
    if args.save_session:
        context.storage_state(path=args.save_session)
        print(f"   session saved -> {args.save_session}")
    context.close()
    return bool(problems)


def main():
    args = parse_args()
    args.out = args.out or tempfile.mkdtemp(prefix="webshot-")
    os.makedirs(args.out, exist_ok=True)
    if args.session and not os.path.exists(args.session):
        sys.exit(f"webshot: session file {args.session} does not exist (create it with --save-session)")
    if args.before:
        args.before_fn = runpy.run_path(args.before).get("before")
        if not callable(args.before_fn):
            sys.exit(f"webshot: {args.before} must define a function before(page)")
    if args.url.startswith("http"):
        wait_for_server(args.url, args.server_timeout)
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path=CHROME, headless=True)
        failed = [capture(browser, args, label, size) for label, size in args.size or [parse_size("desktop")]]
        browser.close()
    sys.exit(1 if any(failed) else 0)


if __name__ == "__main__":
    main()
