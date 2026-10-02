import { Readability } from '@mozilla/readability';
import { parseHTML } from 'linkedom';
import { chromium as patchrightChromium } from 'patchright';
import { chromium as baseChromium } from 'playwright-core';
import { addExtra } from 'playwright-extra';
import StealthPlugin from 'puppeteer-extra-plugin-stealth';
import TurndownService from 'turndown';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { parseArgs } from 'node:util';

const TIMEOUT_MS = 20_000;
const SETTLE_MS = 5_000;
const CHALLENGE_MS = 30_000;
const DEFAULT_MAX_BYTES = 50_000;
const MAX_REDDIT_COMMENTS = 40;
const CHROME_CANDIDATES = ['google-chrome-stable', 'google-chrome', 'chromium', 'chrome'];

const REDDIT_HOSTS = new Set([
  'reddit.com',
  'www.reddit.com',
  'old.reddit.com',
  'np.reddit.com',
  'new.reddit.com',
]);

const stealthChromium = addExtra(baseChromium);
stealthChromium.use(StealthPlugin());

const which = (bin) => {
  try {
    const opts = { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] };
    return execFileSync('which', [bin], opts).trim() || null;
  } catch {
    return null;
  }
};

const resolveChrome = () => {
  const found =
    process.env.SUPER_FETCH_CHROME ??
    CHROME_CANDIDATES.reduce((hit, bin) => hit ?? which(bin), null);
  if (!found) {
    throw new Error(
      `no Chrome found on PATH (looked for ${CHROME_CANDIDATES.join(', ')}); set SUPER_FETCH_CHROME to its path`,
    );
  }
  return found;
};

// Two engines, because neither wins everywhere. The stealth plugin spoofs the
// fingerprint details Reddit checks but leaves the CDP Runtime.enable leak that
// Cloudflare and PerimeterX read; patchright patches that leak but trips Reddit.
// The cheap one runs first and the heavy one only when the page comes back blocked.
const openStealth = async () => {
  const browser = await stealthChromium.launch({
    headless: true,
    executablePath: resolveChrome(),
  });
  return { page: await browser.newPage(), close: () => browser.close() };
};

const openPatchright = async () => {
  // patchright's patches only apply to a persistent context, and headed Chrome
  // clears challenges headless never does — run.sh points DISPLAY at an Xvfb so
  // the window stays off the real desktop. The profile is fresh per fetch: a
  // reused one caches a failed challenge and keeps the site blocked for good.
  const profile = mkdtempSync(join(tmpdir(), 'super-fetch-'));
  const context = await patchrightChromium.launchPersistentContext(profile, {
    headless: process.env.SUPER_FETCH_HEADLESS === '1',
    executablePath: resolveChrome(),
    viewport: { width: 1280, height: 800 },
  });
  return {
    page: context.pages()[0] ?? (await context.newPage()),
    close: async () => {
      await context.close();
      rmSync(profile, { recursive: true, force: true });
    },
  };
};

const ENGINES = [openStealth, openPatchright];

// Interstitials that clear themselves once the fingerprint holds up, plus the
// hard blocks that never will. Both mean "this is not the page", so both are
// worth escalating to the heavier engine for.
const BLOCK_MARKERS = [
  'just a moment',
  'checking your browser',
  'performing security verification',
  'enable javascript and cookies',
  'press & hold',
  'verify you are human',
  'prove your humanity',
  'attention required',
  'humans only',
  'access to this page has been denied',
  'blocked by network security',
  'sorry, you have been blocked',
];

const looksBlocked = (text) => {
  const haystack = text.toLowerCase();
  return BLOCK_MARKERS.some((marker) => haystack.includes(marker));
};

const readVisibleText = async (page) => {
  const [title, body] = await Promise.all([
    page.title().catch(() => ''),
    page.evaluate(() => document.body?.innerText?.slice(0, 3000) ?? '').catch(() => ''),
  ]);
  return `${title}\n${body}`;
};

const waitOutChallenge = async (page) => {
  const deadline = Date.now() + CHALLENGE_MS;
  while (Date.now() < deadline && looksBlocked(await readVisibleText(page))) {
    await page.waitForTimeout(1500);
  }
};

const withPage = async (open, url, fn, waitFor) => {
  const { page, close } = await open();
  try {
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: TIMEOUT_MS });
    // The challenge has to clear first: until it does the DOM belongs to the
    // interstitial, so anything waited for or read before this is the wrong page.
    await waitOutChallenge(page);
    // Ad-heavy and streaming pages (Reddit among them) never reach network idle,
    // so idle is a bonus, not a requirement: read whatever rendered instead of
    // failing. A caller that knows the element it needs waits for that instead.
    await (waitFor
      ? page.locator(waitFor).first().waitFor({ timeout: TIMEOUT_MS })
      : page.waitForLoadState('networkidle', { timeout: SETTLE_MS })
    ).catch(() => {});
    return await fn(page);
  } finally {
    await close();
  }
};

// Readability throws on non-article documents (JSON, bare text, malformed
// markup); fall back to converting the raw body rather than failing the fetch.
const parseArticle = (html) => {
  try {
    const { document } = parseHTML(html);
    return new Readability(document).parse();
  } catch {
    return null;
  }
};

const htmlToMarkdown = (html) => {
  const article = parseArticle(html);
  const body = article?.content ?? html;
  const service = new TurndownService({ headingStyle: 'atx' });
  service.remove(['script', 'style', 'noscript']);
  service.addRule('dropDataImages', {
    filter: (node) =>
      node.nodeName === 'IMG' && (node.getAttribute('src') ?? '').startsWith('data:'),
    replacement: (_content, node) => node.getAttribute('alt') ?? '',
  });
  const markdown = service.turndown(body);
  return article?.title ? `# ${article.title}\n\n${markdown}` : markdown;
};

const isRedditThreadUrl = (url) => {
  const { hostname, pathname } = new URL(url);
  return REDDIT_HOSTS.has(hostname) && pathname.includes('/comments/');
};

const formatRedditThread = (thread) => {
  const header = `# ${thread.title}`;
  const body = thread.body.trim() ? `\n\n${thread.body.trim()}` : '';
  const comments = thread.comments
    .filter((comment) => comment.body)
    .map((comment) => `**u/${comment.author}** (${comment.score} points): ${comment.body}`);
  const section = comments.length > 0 ? `\n\n## Comments\n\n${comments.join('\n\n')}` : '';
  return `${header}${body}${section}`;
};

const extractRedditComment = async (page, index) => {
  const node = page.locator('shreddit-comment').nth(index);
  const [author, score, body] = await Promise.all([
    node.getAttribute('author'),
    node.getAttribute('score'),
    node
      .locator('[slot="comment"]')
      .first()
      .textContent()
      .catch(() => ''),
  ]);
  return { author: author ?? '[deleted]', score: Number(score ?? '0'), body: (body ?? '').trim() };
};

// Reddit's site is a web-component SPA (<shreddit-comment>) that Readability
// can't extract, so the thread is pulled straight from the rendered DOM. The
// .json endpoint and old.reddit are hard-blocked (403) at the network layer, so
// the only way in is the main page.
const extractRedditThread = async (page) => {
  const post = page.locator('shreddit-post').first();
  const title = (await post.getAttribute('post-title')) ?? (await page.title());
  const body =
    (await post
      .locator('[slot="text-body"]')
      .first()
      .textContent()
      .catch(() => '')) ?? '';
  const count = Math.min(await page.locator('shreddit-comment').count(), MAX_REDDIT_COMMENTS);
  const comments = await Promise.all(
    Array.from({ length: count }, (_, index) => extractRedditComment(page, index)),
  );
  return { title, body, comments };
};

const fetchWith = async (open, url) => {
  if (isRedditThreadUrl(url)) {
    const thread = await withPage(open, url, extractRedditThread, 'shreddit-comment').catch(
      () => null,
    );
    if (thread && (thread.comments.length > 0 || thread.body.trim())) {
      return { url, markdown: formatRedditThread(thread) };
    }
  }
  const rendered = await withPage(open, url, async (page) => ({
    url: page.url(),
    html: await page.content(),
  }));
  return { url: rendered.url, markdown: htmlToMarkdown(rendered.html) };
};

const fetchPage = async (url) => {
  let lastError;
  for (const [index, open] of ENGINES.entries()) {
    const isLast = index === ENGINES.length - 1;
    try {
      const page = await fetchWith(open, url);
      if (!looksBlocked(page.markdown)) {
        return page;
      }
      if (isLast) {
        throw new Error('blocked by the site after trying all browser engines');
      }
      console.error('super-fetch: blocked — retrying with the patched-browser engine…');
    } catch (error) {
      lastError = error;
      if (isLast) {
        throw error;
      }
      console.error(`super-fetch: ${error.message.split('\n')[0]} — retrying with next engine…`);
    }
  }
  throw lastError;
};

// A page can be a full movie transcript or a tiny snippet, so the markdown is
// windowed by byte to keep a normal read bounded while still allowing the whole
// thing (--full) or paging through it (--offset/--limit). The byte slice can land
// mid-character; toString('utf8') renders the partial sequence as a replacement
// char, an acceptable cost at the boundary of an explicit byte range.
const windowMarkdown = (markdown, { full = false, offset = 0, limit }) => {
  if (full) {
    return { text: markdown };
  }
  const buf = Buffer.from(markdown, 'utf8');
  const total = buf.length;
  const start = Math.min(Math.max(offset, 0), total);
  const end = Math.min(start + (limit ?? DEFAULT_MAX_BYTES), total);
  const text = buf.subarray(start, end).toString('utf8');
  if (start === 0 && end === total) {
    return { text };
  }
  const more =
    end < total
      ? 'Content truncated — pass --full for the whole page, or use --offset/--limit (bytes) to page through it.'
      : 'End of page.';
  return { text, notice: `[super-fetch: returned bytes ${start}-${end} of ${total}. ${more}]` };
};

const USAGE = `usage: super-fetch <url> [--full] [--offset BYTES] [--limit BYTES]`;

const parseCliArgs = () => {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      full: { type: 'boolean', default: false },
      offset: { type: 'string' },
      limit: { type: 'string' },
    },
  });
  const [url] = positionals;
  if (!url) {
    throw new Error(USAGE);
  }
  if (!/^https?:\/\//i.test(url)) {
    throw new Error(`url must be an absolute http(s) URL, got "${url}"`);
  }
  return {
    url,
    full: values.full,
    offset: values.offset ? Number(values.offset) : 0,
    limit: values.limit ? Number(values.limit) : undefined,
  };
};

const main = async () => {
  const { url, ...window } = parseCliArgs();
  const page = await fetchPage(url);
  const { text, notice } = windowMarkdown(page.markdown, window);
  process.stdout.write(`source: ${page.url}\n\n${text}\n`);
  if (notice) {
    process.stdout.write(`\n${notice}\n`);
  }
};

main().catch((error) => {
  console.error(`super-fetch: ${error.message}`);
  process.exit(1);
});
