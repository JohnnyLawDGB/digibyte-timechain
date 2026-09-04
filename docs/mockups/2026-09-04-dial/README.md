# Dial screen mockup (2026-09-04)

Shareable canvas: https://claude.ai/code/artifact/7a0e53e6-a67f-412d-b9ea-2b847a06e10f

`gen.py` renders the three artboards from `last240.txt` (the last 240 mainnet
blocks at height 24,151,775, captured from the Adam VPS node) plus the verified
figures embedded at the top of the script. Fee-rate estimates and the 9 s timer
are sample values; everything else is real chain data.

- `dial-dark.png` / `Main.dc.html` — live, dark theme
- `dial-light.png` / `Light.dc.html` — live, light theme
- `dial-scrubbed.png` / `Scrubbed.dc.html` — scrubbed 65 blocks back
