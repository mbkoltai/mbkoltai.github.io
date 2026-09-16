"""
KSH 'Keresetek' gyorstajekoztato downloader.

Fetches the RAW server HTML for each monthly release into ./ksh_html/ as
ker<YYMM>.html, so the inline Highcharts <script> (the categories:/data:
arrays the parser needs) is preserved.

IMPORTANT: do NOT save these pages with the browser's Ctrl+S ("save page").
That stores the rendered DOM -- the chart already turned into static <svg>,
with the data arrays gone -- and ksh_parse.py then finds no sector/quintile
data. This script fetches the untouched server response instead. The quick
check is `renderChartsV6` in the file: present = raw (good), absent = a
rendered/Ctrl+S copy (re-fetch it).

Usage
-----
    python ksh_download.py                       # 2024-01 .. current month
    python ksh_download.py 2026-06               # one month
    python ksh_download.py 2026-06 2026-07       # inclusive range
    python ksh_download.py 2026-06 2026-07 --force   # re-fetch even if present

    from ksh_download import download
    download(start=(2026, 6), end=(2026, 7))
    download(start=(2026, 6), end=(2026, 7), force=True)
"""

import os
import re
import sys
import time
import datetime as dt
import requests

HTML_DIR = "ksh_html"
URL = "https://www.ksh.hu/gyorstajekoztatok/ker/ker{ym}.html"
HEADERS = {
    "User-Agent": ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                   "(KHTML, like Gecko) Chrome/125.0 Safari/537.36"),
    "Accept-Language": "hu,en;q=0.8",
}


def _months(start, end):
    """Yield 'YYMM' strings from start=(Y,M) to end=(Y,M) inclusive."""
    if end is None:
        t = dt.date.today()
        end = (t.year, t.month)
    y, m = start
    ey, em = end
    while (y, m) <= (ey, em):
        yield f"{y % 100:02d}{m:02d}"
        m += 1
        if m == 13:
            m, y = 1, y + 1


def download(start=(2024, 1), end=None, sleep=1.0, force=False,
             html_dir=HTML_DIR):
    """Download raw ker<YYMM>.html files. Skips existing unless force=True."""
    os.makedirs(html_dir, exist_ok=True)
    for ym in _months(start, end):
        path = os.path.join(html_dir, f"ker{ym}.html")
        if os.path.exists(path) and os.path.getsize(path) > 0 and not force:
            continue
        try:
            r = requests.get(URL.format(ym=ym), headers=HEADERS, timeout=30)
        except requests.RequestException as e:
            print(f"[{ym}] request error: {e}")
            continue
        if r.status_code == 200:
            has_js = b"renderChartsV6" in r.content
            with open(path, "wb") as f:      # raw bytes, iso-8859-2, JS intact
                f.write(r.content)
            print(f"[{ym}] saved {len(r.content):>7} bytes  "
                  f"{'OK-JS' if has_js else 'NO-JS (chart data missing!)'}")
        elif r.status_code == 404:
            print(f"[{ym}] not published yet (404)")
        else:
            print(f"[{ym}] HTTP {r.status_code} "
                  f"(if 403 persists, save via browser View-Source / Ctrl+U, "
                  f"not Ctrl+S, into {html_dir}/)")
        time.sleep(sleep)                    # be polite


def _parse_ym(s):
    """'2026-06' or '202606' or '2606' -> (Y, M)."""
    s = s.replace("-", "").replace("/", "")
    if len(s) == 4:                          # YYMM
        return 2000 + int(s[:2]), int(s[2:])
    if len(s) == 6:                          # YYYYMM
        return int(s[:4]), int(s[4:])
    raise ValueError(f"bad month spec: {s!r} (use YYYY-MM)")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--force"]
    force = "--force" in sys.argv
    if not args:
        download(force=force)                                  # full default range
    elif len(args) == 1:
        m = _parse_ym(args[0]); download(m, m, force=force)    # single month
    else:
        download(_parse_ym(args[0]), _parse_ym(args[1]), force=force)  # range
