"""
KSH 'Keresetek' gyorstajekoztato parser -> tidy long dataframe.

Output columns:
    date | measure | tax | scope | netto_koncepcio | value | period
    | incl_kozfoglalk

measure : atlag | median | rendsz | kvintilis_1..5
tax     : brutto | netto
scope   : nemzetgazdasag | vallalkozas | koltsegvetes | nonprofit
          | kozfoglalk | nem_kozfoglalk        (sector/aggregate blocks)
          | <nemzetgazdasagi ag slug>          (e.g. feldolgozoipar)
netto_koncepcio : kedvezmennyel | kedvezmeny_nelkul   (net rows, pre-revision)
                  empty                                (gross; net post-2025-03)
period  : monthly | cumulative
incl_kozfoglalk : True if public-work employees are inside the reported
                  universe, False otherwise (the nemzetgazdasagi-ag chart is
                  explicitly 'kozfoglalkoztatottak nelkul', as is the
                  'nem kozfoglalkoztatottak' row).

Rules
-----
* Everything is SINGLE-MONTH: the prose, and only the FIRST block of the
  bottom table.  The year-to-date cumulative table block is discarded.
* Quintiles are the sole exception: taken as published, so period='cumulative'
  for 2025-02..2025-12 and 'monthly' otherwise.  (No quintile chart before
  2025-01.)
* Nemzetgazdasagi ag (sector) chart: each file plots the current month AND the
  same month a year earlier.  To avoid the 2025 revision publishing a month
  twice with different values, the year-ago series is taken ONLY from the 2024
  files (which is how 2023 is recovered); every later file contributes only its
  own current month.  Result: 2023-01..2026-05, each month exactly once.
* Sector values are published in ezer forint with one decimal; they are scaled
  to full forint (x1000) so `value` has one unit throughout.  Precision is
  therefore 100 Ft for those rows.
* Only LEVELS are extracted; the yoy % columns are ignored by design.

Usage
-----
    python ksh_parse.py                 # reads ./ksh_html, writes the CSV
    from ksh_parse import parse_dir; df = parse_dir("ksh_html")
"""

import os
import re
import html
import unicodedata
import pandas as pd

HTML_DIR = "ksh_html"
OUT_CSV = "ksh_keresetek_long.csv"

NA = ""                       # empty -> blank cell in CSV / NA in readr


# ------------------------------------------------------------------ helpers --
def _read(path):
    """Raw bytes -> decoded text (KSH pages are iso-8859-2)."""
    return open(path, "rb").read().decode("iso-8859-2", errors="replace")


def _strip(s):
    """Drop tags, unescape entities, normalise nbsp -> space."""
    return html.unescape(re.sub(r"<[^>]+>", " ", s)).replace("\xa0", " ")


def _num(s):
    """'1 285 700' / '605 100' -> int."""
    return int(re.sub(r"\s", "", s))


def _slug(s):
    """'Vij- es hulladekgazdalkodas' -> 'viz_es_hulladekgazdalkodas'."""
    s = s.replace("ő", "o").replace("ű", "u").replace("õ", "o").replace("û", "u")
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()
    return s


def _lead(raw):
    m = re.search(r'<p class="lead">(.*?)</p>', raw, re.S)
    return _strip(m.group(1)) if m else ""


def _body(raw):
    """All the <p class="bp"> bullet paragraphs, tags stripped, joined."""
    return " ".join(_strip(p) for p in
                    re.findall(r'<p class="bp">(.*?)</p>', raw, re.S))


N = r"([\d ]{5,}?)"          # a spaced thousands number

HU_MONTHS = {
    "januar": 1, "februar": 2, "marcius": 3, "aprilis": 4, "majus": 5,
    "junius": 6, "julius": 7, "augusztus": 8, "szeptember": 9,
    "oktober": 10, "november": 11, "december": 12,
}


# -------------------------------------------------------------- lead/prose --
RX_ATLAG = re.compile(r"brutt. .tlagkeresete\s+" + N + r"\s*,", re.I)
RX_NETTO_ATL = re.compile(r"nett. .tlagkeresete?\s+" + N + r"\s*forint", re.I)
RX_BMED = re.compile(r"brutt. kereset medi.n.rt.ke\s+" + N + r"\s*,", re.I)
RX_NMED = re.compile(r"nett. kereset medi.n.rt.ke\s+" + N + r"\s*forint", re.I)

# rendszeres brutto atlagkereset (total).  The number may sit inside or outside
# the <b> tags; the sentence ends 'forint volt' or 'forintra becsulheto'.
RX_RENDSZ = re.compile(
    r"rendszeres.{0,90}?brutt. .tlagkereset\s+" + N + r"\s*forint", re.I | re.S)
# ... and its three sectors, always in one sentence
RX_RENDSZ_SEKT = re.compile(
    r"v.llalkoz.sokn.l\s+" + N + r"\s*,\s*a\s+k.lts.gvet.sben\s+" + N +
    r"\s*,\s*a\s+nonprofit\s+szektorban\s+" + N + r"\s*forintot", re.I | re.S)
# pre-revision only: 'netto atlagkereset kedvezmenyek nelkul X, a
# kedvezmenyeket figyelembe veve Y forintot ert el'
RX_NETTO_SPLIT = re.compile(
    r"nett. .tlagkereset\s+kedvezm.nyek n.lk.l\s+" + N +
    r"\s*,\s*a\s+kedvezm.nyeket figyelembe v.ve\s+" + N + r"\s*forintot",
    re.I | re.S)

# quintile chart: the 5-int data array, plus the title's reference period
RX_QUINT = re.compile(
    r"kvintilis.*?data:\s*\[\s*(\d+(?:\s*,\s*\d+){4})\s*\]", re.I | re.S)
RX_QPERIOD = re.compile(r"kvintilisenk[^,]*,\s*(.*?)'", re.I)

SCOPES = [
    ("nem k.zfoglalkoztatottak", "nem_kozfoglalk"),   # test before the next one
    ("k.zfoglalkoztatottak", "kozfoglalk"),
    ("v.llalkoz.s", "vallalkozas"),
    ("k.lts.gvet.s", "koltsegvetes"),
    ("nonprofit", "nonprofit"),
    ("nemzetgazdas.g .sszesen", "nemzetgazdasag"),
]


def _scope_of(label):
    for pat, name in SCOPES:
        if re.search(pat, label, re.I):
            return name
    return None


def _table_rows(raw):
    """
    Rows of the FIRST (single-month) block of the bottom table.

    Block boundaries are period-label rows, e.g. '2026. majus' then
    '2026. januar-majus*'.  We stop at the first label containing a dash,
    i.e. a month RANGE = the cumulative block.  January releases have no
    label row at all (a single block), which this handles naturally.
    """
    m = re.search(r"<tbody>(.*?)</tbody>", raw, re.S)
    if not m:
        return []
    out = []
    for tr in re.findall(r"<tr>(.*?)</tr>", m.group(1), re.S):
        cells = [_strip(c).strip() for c in
                 re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", tr, re.S)]
        if not any(cells):
            continue
        joined = " ".join(cells).strip()
        # a period-label row? (year-month caption, no data cells)
        if re.match(r"^\d{4}\.\s", joined) and not re.search(r"\d{3}\s\d{3}",
                                                             joined):
            if re.search(r"[-\u2013\u2014]", joined):
                break            # cumulative block starts here -> stop
            continue             # single-month caption -> skip, keep reading
        out.append(cells)
    return out


def _sector_chart(raw):
    """
    The 'brutto atlagkereset nemzetgazdasagi aganként' chart.

    Returns (categories, [(series_name, [values...]), ...]).  Category order
    changes month to month (bars are value-sorted), so callers must zip
    categories with data positionally within a single file only.
    """
    t = html.unescape(raw)
    i = t.find("gank")                     # '...nemzetgazdasagi aganként'
    if i < 0:
        return [], []
    j = t.find("chart: {", i)              # next chart object (quintiles) or EOF
    blk = t[i: j if j > 0 else len(t)]
    mc = re.search(r"categories:\s*\[(.*?)\]", blk, re.S)
    cats = re.findall(r"'([^']*)'", mc.group(1)) if mc else []
    ser = re.findall(r"name:\s*'([^']*)'\s*,\s*data:\s*\[([^\]]*)\]", blk, re.S)
    return cats, ser


def _series_date(name):
    """'2024. februar' -> '2024-02' (None if unparseable)."""
    m = re.match(r"\s*(\d{4})\.\s*(\S+)", name)
    if not m:
        return None
    mon = HU_MONTHS.get(_slug(m.group(2)))
    return f"{m.group(1)}-{mon:02d}" if mon else None


# -------------------------------------------------------------------- core --
def parse_file(path):
    ym = re.search(r"ker(\d{4})\.html$", path).group(1)
    date = f"20{ym[:2]}-{ym[2:]}"
    file_year = int(f"20{ym[:2]}")
    raw = _read(path)
    lead, body = _lead(raw), _body(raw)

    # Which net-concept regime?  Pre-revision the table's net column is headed
    # '(kedvezmenyek nelkul)'.  Detect from the file itself, not a date cutoff.
    thead = re.search(r"<thead>(.*?)</thead>", raw, re.S)
    pre_rev = bool(thead and re.search(r"kedvezm.nyek n.lk.l",
                                       _strip(thead.group(1)), re.I))
    net_lead = "kedvezmennyel" if pre_rev else NA      # lead  = with credits
    net_tab = "kedvezmeny_nelkul" if pre_rev else NA   # table = without

    rows = []

    def add(measure, tax, scope, value, dt=None, period="monthly",
            konc=NA, incl=True):
        rows.append(dict(date=dt or date, measure=measure, tax=tax, scope=scope,
                         netto_koncepcio=konc, value=value, period=period,
                         incl_kozfoglalk=incl))

    # ---- lead: headline mean & median -------------------------------------
    for rx, meas, tax, konc in [
        (RX_ATLAG, "atlag", "brutto", NA),
        (RX_NETTO_ATL, "atlag", "netto", net_lead),
        (RX_BMED, "median", "brutto", NA),
        (RX_NMED, "median", "netto", net_lead),
    ]:
        m = rx.search(lead)
        if m:
            add(meas, tax, "nemzetgazdasag", _num(m.group(1)), konc=konc)

    # ---- prose: rendszeres brutto (total + 3 sectors) ---------------------
    m = RX_RENDSZ.search(body)
    if m:
        add("rendsz", "brutto", "nemzetgazdasag", _num(m.group(1)))
    m = RX_RENDSZ_SEKT.search(body)
    if m:
        for i, sc in enumerate(("vallalkozas", "koltsegvetes", "nonprofit"), 1):
            add("rendsz", "brutto", sc, _num(m.group(i)))

    # ---- prose: pre-revision net split (without / with credits) -----------
    m = RX_NETTO_SPLIT.search(body)
    if m:
        add("atlag", "netto", "nemzetgazdasag", _num(m.group(1)),
            konc="kedvezmeny_nelkul")
        add("atlag", "netto", "nemzetgazdasag", _num(m.group(2)),
            konc="kedvezmennyel")

    # ---- bottom table, single-month block only ----------------------------
    for cells in _table_rows(raw):
        scope = _scope_of(cells[0])
        if scope is None or len(cells) < 4:
            continue
        incl = scope != "nem_kozfoglalk"
        if re.fullmatch(r"[\d ]+", cells[1] or ""):
            add("atlag", "brutto", scope, _num(cells[1]), incl=incl)
        if re.fullmatch(r"[\d ]+", cells[3] or ""):
            add("atlag", "netto", scope, _num(cells[3]), konc=net_tab, incl=incl)

    # ---- nemzetgazdasagi ag (sector) chart --------------------------------
    # Take the current month always; take the year-ago series ONLY from the
    # 2024 files, which is how 2023 is recovered without duplicating any month.
    cats, ser = _sector_chart(raw)
    for name, data in ser:
        sdate = _series_date(name)
        if sdate is None:
            continue
        syear = int(sdate[:4])
        if syear != file_year and file_year != 2024:
            continue                       # skip year-ago series after 2024
        vals = [v.strip() for v in data.split(",")]
        if len(vals) != len(cats):
            continue                       # shape mismatch -> skip, don't guess
        for cat, v in zip(cats, vals):
            if not v:
                continue
            # published in ezer forint, 1 decimal -> scale to full forint
            add("atlag", "brutto", _slug(cat), round(float(v) * 1000),
                dt=sdate, incl=False)      # chart excludes kozfoglalkoztatottak

    # ---- quintiles (as published: may be cumulative) ----------------------
    m = RX_QUINT.search(raw)
    if m:
        pm = RX_QPERIOD.search(html.unescape(raw))
        ptxt = pm.group(1).strip() if pm else ""
        per = "cumulative" if re.search(r"[-\u2013\u2014]", ptxt) else "monthly"
        for i, v in enumerate(re.split(r"\s*,\s*", m.group(1)), 1):
            add(f"kvintilis_{i}", "brutto", "nemzetgazdasag", int(v), period=per)

    return rows


def parse_dir(html_dir=HTML_DIR):
    rows = []
    for fn in sorted(os.listdir(html_dir)):
        if re.match(r"ker\d{4}\.html$", fn):
            rows += parse_file(os.path.join(html_dir, fn))
    df = pd.DataFrame(rows, columns=["date", "measure", "tax", "scope",
                                     "netto_koncepcio", "value", "period",
                                     "incl_kozfoglalk"])
    # the lead and the table both report the national figures; identical keys
    # are true duplicates, so keep the first occurrence.
    df = df.drop_duplicates(subset=["date", "measure", "tax", "scope",
                                    "netto_koncepcio"], keep="first")
    return (df.sort_values(["date", "measure", "tax", "scope"])
              .reset_index(drop=True))


if __name__ == "__main__":
    df = parse_dir()
    df.to_csv(OUT_CSV, index=False)
    print(f"{OUT_CSV}: {len(df)} rows, {df['date'].nunique()} months "
          f"({df['date'].min()} .. {df['date'].max()})")
