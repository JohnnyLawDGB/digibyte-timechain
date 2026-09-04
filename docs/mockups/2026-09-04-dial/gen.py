#!/usr/bin/env python3
"""Generate DigiByte Timechain mockup artboards from real mainnet data."""
import math, json, datetime, os
here = os.path.dirname(os.path.abspath(__file__))

# ---- real data (Adam VPS mainnet node, 2026-09-04) ----
blocks = []  # newest first: height, algo, size, ntx, time
for line in open(os.path.join(here, "last240.txt")):
    h, a, s, n, t = line.split()
    blocks.append((int(h), a, int(s), int(n), int(t)))
assert len(blocks) == 240
TIP = 24151775
SUPPLY = 18457077640.50
CAP = 21_000_000_000
PRICE = 0.004692
MCAP = 86_638_859
ORIGIN, CYCLE = 1_430_000, 175_200   # Period VI: 2,628,000 s / 15 s
SUBSIDY = 253.55810338

ALGO = {  # label, color
    "sha256d": ("SHA256d", "#0066cc"),
    "scrypt":  ("Scrypt",  "#00d4aa"),
    "skein":   ("Skein",   "#f5a524"),
    "qubit":   ("Qubit",   "#b45cff"),
    "odo":     ("Odocrypt","#ff5c7a"),
}
share = {k: sum(1 for b in blocks if b[1] == k) for k in ALGO}

def reduction(h):
    n = h - ORIGIN
    step = n // CYCLE + 1
    nxt = ORIGIN + (n // CYCLE + 1) * CYCLE
    return step, nxt - h, (n % CYCLE) / CYCLE

def fmt(n): return f"{n:,}"

THEMES = {
    "dark": dict(bg="#06101f", card="#0b1a30", card2="#0f2340", text="#f2f6fb", muted="#8ea3bf",
                 line="rgba(255,255,255,0.08)", track="rgba(255,255,255,0.09)",
                 ring2="#e6edf7", pillbg="#0b1a30", pilltext="#f2f6fb", knob="#0066cc",
                 live="#00d4aa", shadow="0 8px 24px rgba(0,0,0,0.35)"),
    "light": dict(bg="#f4f7fb", card="#ffffff", card2="#eaf0f8", text="#002352", muted="#5a6f8c",
                  line="rgba(0,35,82,0.10)", track="rgba(0,35,82,0.10)",
                  ring2="#002352", pillbg="#ffffff", pilltext="#002352", knob="#0066cc",
                  live="#00a688", shadow="0 8px 24px rgba(0,35,82,0.10)"),
}

CX = CY = 170
def pt(r, deg, cx=CX, cy=CY):
    a = math.radians(deg)
    return cx + r * math.cos(a), cy + r * math.sin(a)

def arc(r, f, start=-90, sweep=1, cx=CX, cy=CY):
    """Arc from 12 o'clock clockwise covering fraction f of the circle."""
    f = min(max(f, 0.0001), 0.9999)
    x0, y0 = pt(r, start, cx, cy)
    end = start + 360 * f * sweep
    x1, y1 = pt(r, end, cx, cy)
    large = 1 if f > 0.5 else 0
    return f"M{x0:.2f},{y0:.2f} A{r},{r} 0 {large} {sweep if sweep==1 else 0} {x1:.2f},{y1:.2f}", end

def caption_path(r, a0, a1):
    x0, y0 = pt(r, a0); x1, y1 = pt(r, a1)
    return f"M{x0:.2f},{y0:.2f} A{r},{r} 0 0 1 {x1:.2f},{y1:.2f}"

SYMBOL = '''<svg viewBox="0 0 1280 1280" width="{s}" height="{s}" aria-label="DigiByte"><path fill="#0066CC" d="M640,120.1c-287.2,0-519.9,232.8-519.9,519.9s232.8,519.9,519.9,519.9s519.9-232.8,519.9-519.9S927.2,120.1,640,120.1z"></path><circle fill="#002352" cx="640" cy="640" r="422.4"></circle><path fill="#FFFFFF" d="M769.9,428l15-39.1c1.5-4-1.4-8.2-5.6-8.2h-55.7L706,426.5h-24.7l14.4-37.6c1.5-4-1.4-8.2-5.6-8.2h-55.7l-17.6,45.8H442.6c-7.9,0-15.3,4.3-19.2,11.2L380,514.3h60.7h264.8c10.8,0,21.5,2,31.5,6.1c19.2,7.9,41.9,25.8,36.2,66.1c-9.5,67.5-78.3,187.1-227.6,189l77.2-201c3.2-8.3-2.9-17.1-11.8-17.1H507.5l-125,307.2c0,0,25.2,3.1,64.7,3.1L434.8,900h56.9c4.5,0,8.6-2.8,10.3-7l10.7-27.8c8.4-0.7,16.9-1.6,25.7-2.6L524,900h56.9c4.5,0,8.6-2.8,10.3-7l16.2-42.3c93.5-21.3,194-67.7,253.7-165.6C981.6,487.7,856.4,436.7,769.9,428z"></path></svg>'''

GEAR = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"></path></svg>'
CHEV_L = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 6l-6 6 6 6"></path></svg>'
CHEV_R = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"></path></svg>'
EXT = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 4h6v6"></path><path d="M20 4l-9 9"></path><path d="M20 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h5"></path></svg>'

def dial_svg(t, sel_height, sel_index):
    """sel_index = position of the selected block in `blocks` (0 = tip)."""
    step, to_go, frac = reduction(sel_height)
    supply_frac = SUPPLY / CAP
    out = [f'<svg viewBox="0 0 340 340" width="340" height="340" style="display:block;overflow:visible">']
    out.append('<defs>')
    out.append(f'<path id="cap1" d="{caption_path(149, -84, -20)}"></path>')
    out.append(f'<path id="cap2" d="{caption_path(131, -84, -20)}"></path>')
    out.append(f'<path id="cap3" d="{caption_path(113, -84, -20)}"></path>')
    out.append('</defs>')
    # tracks
    for r, w in ((158, 6), (140, 5), (122, 8)):
        out.append(f'<circle cx="170" cy="170" r="{r}" fill="none" stroke="{t["track"]}" stroke-width="{w}"></circle>')
    # ring 1 supply
    d, end1 = arc(158, supply_frac)
    out.append(f'<path d="{d}" fill="none" stroke="#0066cc" stroke-width="6" stroke-linecap="round"></path>')
    # ring 2 reduction
    d, end2 = arc(140, frac)
    out.append(f'<path d="{d}" fill="none" stroke="{t["ring2"]}" stroke-width="5" stroke-linecap="round"></path>')
    # ring 3 algo shares
    a = -90
    for k, (label, col) in ALGO.items():
        f = share[k] / 240
        d, e = arc(122, f, start=a)
        out.append(f'<path d="{d}" fill="none" stroke="{col}" stroke-width="8"></path>')
        a = e
    # captions
    cap_fill = t["muted"]
    for pid, txt in (("cap1", "SUPPLY OF 21B"), ("cap2", "BLOCKS TO NEXT CUT"), ("cap3", "ALGO SHARE · LAST 240")):
        out.append(f'<text font-family="Space Grotesk, system-ui, sans-serif" font-size="8.5" font-weight="700" letter-spacing="1.2" fill="{cap_fill}"><textPath href="#{pid}">{txt}</textPath></text>')
    # ring 4 ticks: newest at 12 o'clock, clockwise = older
    for i, (h, algo, size, ntx, tm) in enumerate(blocks):
        deg = -90 + i * 1.5
        ln = 4 + 10 * min(1.0, math.sqrt(size / 8000))
        x0, y0 = pt(104, deg); x1, y1 = pt(104 - ln, deg)
        col = ALGO[algo][1]
        op = "1" if i <= sel_index or sel_index == 0 else "0.35"
        if sel_index and i > sel_index: op = "0.35"
        out.append(f'<line x1="{x0:.1f}" y1="{y0:.1f}" x2="{x1:.1f}" y2="{y1:.1f}" stroke="{col}" stroke-width="1.6" stroke-linecap="round" opacity="{op}"></line>')
    # selected-block marker on ring 4
    sx, sy = pt(109, -90 + sel_index * 1.5)
    out.append(f'<circle cx="{sx:.1f}" cy="{sy:.1f}" r="3.5" fill="{t["text"]}"></circle>')
    # marker dots at arc ends
    for r, e, col in ((158, end1, "#0066cc"), (140, end2, t["ring2"])):
        x, y = pt(r, e)
        out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="5" fill="{col}" stroke="{t["bg"]}" stroke-width="2"></circle>')
    out.append('</svg>')
    # pills (HTML, positioned)
    pills = []
    for r, e, txt in ((158, end1, f"{supply_frac*100:.1f}%"), (140, end2, f"{fmt(to_go)} blocks")):
        x, y = pt(r, e)
        # push the pill outward from the ring so it does not cover the dot
        ox, oy = pt(r + 18, e)
        ox = min(max(ox, 42), 298)
        pills.append(f'<div style="position:absolute;left:{ox:.0f}px;top:{oy:.0f}px;transform:translate(-50%,-50%);background:{t["pillbg"]};color:{t["pilltext"]};border:1px solid {t["line"]};border-radius:999px;padding:3px 8px;font-family:JetBrains Mono, monospace;font-size:10px;font-weight:600;white-space:nowrap;box-shadow:{t["shadow"]}">{txt}</div>')
    return "\n".join(out), "\n".join(pills), step, to_go

def stat(t, label, value, sub="", align="left", mono=True, dim=False):
    fam = "JetBrains Mono, monospace" if mono else "Space Grotesk, system-ui, sans-serif"
    op = "opacity:0.45;" if dim else ""
    return f'''<div style="display:flex;flex-direction:column;gap:2px;align-items:{'flex-end' if align=='right' else 'flex-start'};text-align:{align};{op}">
  <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:10px;font-weight:700;letter-spacing:1.4px;color:{t['muted']}">{label}</div>
  <div style="font-family:{fam};font-size:17px;font-weight:700;color:{t['text']};line-height:1.1">{value}</div>
  <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:10.5px;font-weight:500;color:{t['muted']}">{sub}</div>
</div>'''

def page(theme, live, sel_index):
    t = THEMES[theme]
    h, algo, size, ntx, tm = blocks[sel_index]
    alabel, acol = ALGO[algo]
    svg, pills, step, to_go = dial_svg(t, h, sel_index)
    dt = datetime.datetime.fromtimestamp(tm, datetime.UTC)
    # block-specific figures (verified from getblockstats)
    if h == 24151775:
        fees, fee_med, fee_min, fee_max = 0.0, "—", "—", "—"
    elif h == 24151710:
        fees, fee_med, fee_min, fee_max = 0.64499045, "10,003", "110", "11,020"
    else:
        raise SystemExit("no stats for that block")
    reward = SUBSIDY + fees
    behind = sel_index
    mode_pill = (f'<div style="display:flex;align-items:center;gap:6px;font-family:Space Grotesk, system-ui, sans-serif;font-size:11px;font-weight:700;letter-spacing:1.4px;color:{t["live"]}"><span style="width:8px;height:8px;border-radius:50%;background:{t["live"]};box-shadow:0 0 0 3px rgba(0,212,170,0.18);display:inline-block"></span>LIVE</div>'
                 if live else
                 f'<div style="display:flex;align-items:center;gap:6px;font-family:Space Grotesk, system-ui, sans-serif;font-size:11px;font-weight:700;letter-spacing:1.4px;color:{t["muted"]}"><span style="width:8px;height:8px;border-radius:50%;background:{t["muted"]};display:inline-block"></span>VIEWING BLOCK</div>')
    # timer tile
    if live:
        elapsed = 9
        timer_frac = elapsed / 15
        d, _ = arc(40, timer_frac, cx=52, cy=52)
        timer = f'''<div style="position:relative;width:104px;height:104px;flex:none">
  <svg viewBox="0 0 104 104" width="104" height="104" style="display:block"><circle cx="52" cy="52" r="40" fill="none" stroke="{t['track']}" stroke-width="6"></circle><path d="{d}" fill="none" stroke="{t['live']}" stroke-width="6" stroke-linecap="round"></path></svg>
  <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px">
    <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">LAST BLOCK</div>
    <div style="font-family:JetBrains Mono, monospace;font-size:20px;font-weight:700;color:{t['text']}">{elapsed}s</div>
    <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:9px;font-weight:500;color:{t['muted']}">of 15s target</div>
  </div>
</div>'''
    else:
        timer = f'''<div style="position:relative;width:104px;height:104px;flex:none">
  <svg viewBox="0 0 104 104" width="104" height="104" style="display:block"><circle cx="52" cy="52" r="40" fill="none" stroke="{t['track']}" stroke-width="6"></circle></svg>
  <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px">
    <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">MINED AT</div>
    <div style="font-family:JetBrains Mono, monospace;font-size:15px;font-weight:700;color:{t['text']}">{dt:%H:%M:%S}</div>
    <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:9px;font-weight:500;color:{t['muted']}">{behind} behind tip</div>
  </div>
</div>'''
    knob_left = 100 if live else 100 - (behind / 240) * 100
    html = f'''<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&amp;family=JetBrains+Mono:wght@500;700&amp;display=swap">
  <style>
    body {{ margin: 0; background: {t['bg']}; }}
    a {{ color: #0066cc; text-decoration: none; }} a:hover {{ color: #3d5cff; }}
  </style>
</helmet>
<div style="width:390px;min-height:1000px;background:{t['bg']};color:{t['text']};font-family:Space Grotesk, system-ui, sans-serif;display:flex;flex-direction:column;gap:14px;padding:12px 16px 28px;box-sizing:border-box">

  <div style="display:flex;align-items:center;justify-content:space-between;height:44px">
    <div style="display:flex;align-items:center;gap:10px">
      {SYMBOL.format(s=30)}
      <div style="font-family:Space Grotesk, system-ui, sans-serif;font-size:15px;font-weight:700;letter-spacing:2.2px">TIMECHAIN</div>
    </div>
    {mode_pill}
    <div style="width:44px;height:44px;display:flex;align-items:center;justify-content:center;color:{t['muted']}">{GEAR}</div>
  </div>

  <div style="display:grid;grid-template-columns:repeat(3, minmax(0, 1fr));gap:10px;align-items:start">
    {stat(t, "REDUCTION", f"#{step}", "cut 1.116% monthly", mono=False)}
    {stat(t, "SUBSIDY", f"{SUBSIDY:,.2f}", "DGB per block", align="center")}
    {stat(t, "USD / DGB", f"{PRICE:.5f}".rstrip("0"), f"{1/PRICE:,.0f} DGB per USD", align="right", dim=not live)}
  </div>

  <div style="position:relative;width:340px;height:340px;margin:6px auto 0">
    {svg}
    <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:184px;display:flex;flex-direction:column;align-items:center;gap:3px;text-align:center">
      <div style="font-size:9.5px;font-weight:700;letter-spacing:1.6px;color:{t['muted']}">BLOCK HEIGHT</div>
      <div style="font-family:JetBrains Mono, monospace;font-size:31px;font-weight:700;letter-spacing:-0.5px;line-height:1;color:{t['text']}">{fmt(h)}</div>
      <div style="display:flex;align-items:center;gap:6px;margin-top:4px">
        <span style="width:8px;height:8px;border-radius:2px;background:{acol};display:inline-block"></span>
        <span style="font-size:11px;font-weight:700;letter-spacing:1.4px;color:{acol}">{alabel.upper()}</span>
      </div>
      <div style="font-family:JetBrains Mono, monospace;font-size:11.5px;font-weight:600;color:{t['text']};margin-top:2px;white-space:nowrap">{fee_med} <span style="color:{t['muted']};font-weight:500">sat/vB</span> <span style="color:{t['muted']};font-weight:500">[{fee_min} – {fee_max}]</span></div>
      <div style="font-family:JetBrains Mono, monospace;font-size:12px;font-weight:600;color:{t['text']}">{size:,} B <span style="color:{t['muted']};font-weight:500">·</span> {ntx} tx</div>
      <a href="#" style="display:flex;align-items:center;justify-content:center;width:44px;height:32px;color:{t['muted']}">{EXT}</a>
    </div>
    {pills}
  </div>

  <div style="display:flex;align-items:baseline;justify-content:space-between">
    <div style="font-family:JetBrains Mono, monospace;font-size:38px;font-weight:700;letter-spacing:-1px;line-height:1">{dt:%H:%M}<span style="font-size:14px;font-weight:500;color:{t['muted']};letter-spacing:0;margin-left:6px">UTC</span></div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:1px">
      <div style="font-size:11px;font-weight:700;letter-spacing:1.6px;color:{t['muted']}">{dt:%A}</div>
      <div style="font-size:17px;font-weight:700;letter-spacing:0.5px">{dt:%b %-d, %Y}</div>
    </div>
  </div>

  <div style="display:flex;align-items:center;gap:10px">
    <div style="width:44px;height:44px;border:1.5px solid {t['line']};border-radius:12px;display:flex;align-items:center;justify-content:center;color:{t['text']};flex:none">{CHEV_L}</div>
    <div style="position:relative;flex:1;height:44px;display:flex;align-items:center">
      <div style="position:absolute;left:0;right:0;height:3px;border-radius:2px;background:{t['track']}"></div>
      <div style="position:absolute;left:0;width:{knob_left:.1f}%;height:3px;border-radius:2px;background:#0066cc"></div>
      <div style="position:absolute;left:{knob_left:.1f}%;transform:translateX(-50%);width:26px;height:26px;border-radius:50%;background:{t['bg']};border:4px solid {t['knob']};box-sizing:border-box;box-shadow:{t['shadow']}"></div>
      <div style="position:absolute;left:0;right:0;top:32px;text-align:center;font-size:9.5px;font-weight:700;letter-spacing:1.6px;color:{t['muted']}">SCRUB BLOCKS · {"TIP" if live else f"{behind} BACK"}</div>
    </div>
    <div style="width:44px;height:44px;border:1.5px solid {t['line']};border-radius:12px;display:flex;align-items:center;justify-content:center;color:{t['text']};flex:none">{CHEV_R}</div>
  </div>

  <div style="display:flex;align-items:center;gap:12px;margin-top:6px">
    {timer}
    <div style="flex:1;background:{t['card']};border:1px solid {t['line']};border-radius:16px;padding:12px 14px;display:flex;flex-direction:column;gap:8px;box-shadow:{t['shadow']}">
      <div style="display:grid;grid-template-columns:repeat(3, minmax(0, 1fr));gap:4px">
        <div style="display:flex;flex-direction:column;gap:2px"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">SUBSIDY</div><div style="font-family:JetBrains Mono, monospace;font-size:13px;font-weight:700">{SUBSIDY:,.2f}</div></div>
        <div style="display:flex;flex-direction:column;gap:2px;align-items:center"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">+ FEES</div><div style="font-family:JetBrains Mono, monospace;font-size:13px;font-weight:700">{fees:,.3f}</div></div>
        <div style="display:flex;flex-direction:column;gap:2px;align-items:flex-end"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">= REWARD</div><div style="font-family:JetBrains Mono, monospace;font-size:13px;font-weight:700;color:#0066cc">{reward:,.2f}</div></div>
      </div>
      <div style="height:1px;background:{t['line']}"></div>
      <div style="display:flex;align-items:center;justify-content:space-between">
        <div style="font-size:9.5px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">MINED BY</div>
        <div style="display:flex;align-items:center;gap:6px;font-size:12px;font-weight:700">m2pool.com <span style="font-size:9px;font-weight:700;letter-spacing:1px;color:{acol};border:1px solid {acol};border-radius:999px;padding:2px 7px">{alabel.upper()}</span></div>
      </div>
    </div>
  </div>

  <div style="background:{t['card']};border:1px solid {t['line']};border-radius:16px;padding:14px;display:flex;flex-direction:column;gap:12px;box-shadow:{t['shadow']}">
    <div style="display:flex;align-items:center;justify-content:space-between">
      <div style="font-size:10px;font-weight:700;letter-spacing:1.6px;color:{t['muted']}">FEE RATES</div>
      <div style="font-size:10px;font-weight:500;color:{t['muted']}">sat/vB</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(2, minmax(0, 1fr));gap:10px">
      <div style="background:{t['card2']};border-radius:12px;padding:10px 12px;display:flex;flex-direction:column;gap:2px"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">PRIORITY</div><div style="font-family:JetBrains Mono, monospace;font-size:20px;font-weight:700">1,100</div><div style="font-size:9.5px;color:{t['muted']}">next 2 blocks · ~30 s</div></div>
      <div style="background:{t['card2']};border-radius:12px;padding:10px 12px;display:flex;flex-direction:column;gap:2px"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">ANYTIME</div><div style="font-family:JetBrains Mono, monospace;font-size:20px;font-weight:700">110</div><div style="font-size:9.5px;color:{t['muted']}">within 20 blocks · ~5 min</div></div>
    </div>
    <div style="height:1px;background:{t['line']}"></div>
    <div style="display:flex;align-items:center;justify-content:space-between">
      <div style="font-size:10px;font-weight:700;letter-spacing:1.6px;color:{t['muted']}">MEMPOOL</div>
      <div style="font-size:10px;font-weight:500;color:{t['muted']}">{'live' if live else 'live · not block-specific'}</div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(3, minmax(0, 1fr));gap:8px">
      <div style="display:flex;flex-direction:column;gap:2px"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">INFLOW</div><div style="font-family:JetBrains Mono, monospace;font-size:18px;font-weight:700">0</div><div style="font-size:9.5px;color:{t['muted']}">vB / s</div></div>
      <div style="display:flex;flex-direction:column;gap:2px;align-items:center;text-align:center"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">UNCONFIRMED</div><div style="font-family:JetBrains Mono, monospace;font-size:18px;font-weight:700">0</div><div style="font-size:9.5px;color:{t['muted']}">transactions</div></div>
      <div style="display:flex;flex-direction:column;gap:2px;align-items:flex-end;text-align:right"><div style="font-size:9px;font-weight:700;letter-spacing:1.2px;color:{t['muted']}">DEPTH</div><div style="font-family:JetBrains Mono, monospace;font-size:18px;font-weight:700">0</div><div style="font-size:9.5px;color:{t['muted']}">blocks</div></div>
    </div>
  </div>

  <div style="display:grid;grid-template-columns:repeat(3, minmax(0, 1fr));gap:10px;align-items:start">
    {stat(t, "SUPPLY", f"{SUPPLY/1e9:.2f}B", f"{SUPPLY/CAP*100:.2f}% of 21B", mono=True)}
    {stat(t, "NEXT CUT", fmt(to_go), f"blocks · ~{to_go*15/86400:.1f} days", align="center")}
    {stat(t, "MARKET", f"${MCAP/1e6:.1f}M", "USD", align="right", dim=not live)}
  </div>

  <div style="display:flex;flex-wrap:wrap;gap:8px 14px;justify-content:center;padding-top:4px">
    {''.join(f'<div style="display:flex;align-items:center;gap:6px"><span style="width:9px;height:9px;border-radius:50%;background:{c};display:inline-block"></span><span style="font-size:10.5px;font-weight:700;letter-spacing:0.8px;color:{t["muted"]}">{lbl.upper()}</span><span style="font-family:JetBrains Mono, monospace;font-size:10.5px;font-weight:600;color:{t["text"]}">{share[k]/240*100:.0f}%</span></div>' for k,(lbl,c) in ALGO.items())}
  </div>

</div>
</x-dc>
</body>
</html>
'''
    return html

files = {
    "Main.dc.html": page("dark", True, 0),
    "Light.dc.html": page("light", True, 0),
    "Scrubbed.dc.html": page("dark", False, 65),
}
for name, html in files.items():
    open(os.path.join(here, name), "w").write(html)
canvas = {
    "artboards": [
        {"file": "Main.dc.html", "title": "Live · Dark", "x": 0, "y": 0, "w": 390, "h": 1160},
        {"file": "Light.dc.html", "title": "Live · Light", "x": 480, "y": 0, "w": 390, "h": 1160},
        {"file": "Scrubbed.dc.html", "title": "Scrubbed 65 blocks back · Dark", "x": 960, "y": 0, "w": 390, "h": 1160},
    ],
    "annotations": [
        {"id": "data-note", "x": 0, "y": -150, "w": 460,
         "text": "All figures are real DigiByte mainnet data captured 2026-09-04 from our node: height 24,151,775, subsidy 253.56 DGB, supply 18.46B (87.9% of 21B), reduction step #130, last 240 blocks by algorithm. Sample values: fee-rate estimates (Priority/Anytime) and the 9 s timer."},
        {"id": "rings-note", "x": 960, "y": -150, "w": 400,
         "text": "Rings, outer to inner: supply of 21B cap; blocks to next 1.116% subsidy cut (175,200-block cycle); algorithm share of the last 240 blocks; one tick per block for the last hour, length = block size. DigiShield retargets every block, so there is no difficulty ring."},
    ],
    "launch": {"view": "canvas"},
}
json.dump(canvas, open(os.path.join(here, "canvas.json"), "w"), indent=2)
print("wrote", list(files), "sizes", {k: len(v) for k, v in files.items()})
