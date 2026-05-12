# reco.sh Format Specification

`~/reco.sh` is Lionheart's recommendation file — an executable shell script
with commented action suggestions. Frank opens the file, reads Lionheart's
comments, can edit or delete commands, and then executes everything at once:
`bash ~/reco.sh`.

## Base Rules

```bash
#!/bin/bash
set -euo pipefail
```

- `set -e` — abort on error (no blind execution)
- `set -u` — abort on undefined variables
- `set -o pipefail` — pipeline errors are detected

## Entry Format

Each entry consists of a **comment block** (detailed, entertaining,
informative) and the **commands** (compact, commented if necessary).

```bash
# ─────────────────────────────────────────────
# 🟡 Brew Updates (already handled by Lionheart)
#
# What I did:
#    brew upgrade yazi fd just
#
# Why: yazi 0.3.3 → 0.3.4 (bugfixes), fd 9.0 → 10.0 (performance),
#      just 1.25 → 1.26 (new features, backward-compatible)
#
# Nothing to do here — info only.
# ─────────────────────────────────────────────
```

For 🔴 recommendations:

```bash
# ─────────────────────────────────────────────
# 🔴 Docker container restart: searxng
#
# Problem: SearXNG not responding (curl timeout on localhost:8080).
# Container is running but the application is hung.
#
# Solution: Restart the container. No data loss — config is in
# ~/.searxng/config/ and the volume is persistent.
#
# Command:
docker restart searxng
#
# Verify afterwards: curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
# (should return 200)
# ─────────────────────────────────────────────
```

## Tier Markers

| Tier | Marker | Meaning |
|---|---|---|
| 🟢 | `(Info)` | Lionheart handled it, documented for transparency |
| 🟡 | `(Done)` | Lionheart handled it, Frank should know |
| 🔴 | `(Recommendation)` | Not executed — Frank decides |

## Archiving

Before each overwrite of `~/reco.sh`:

```bash
# Archive old reco.sh (if it exists)
if [ -f ~/reco.sh ]; then
  TS=$(date +%Y%m%d-%H%M%S)
  mv ~/reco.sh ~/.lionheart/reco-history/reco-${TS}.sh
  echo "📦 Old reco.sh archived: reco-history/reco-${TS}.sh"
fi
```

## No reco.sh When Everything Is Fine

If the checkup had no 🔴 recommendations and no 🟡 actions, and no old
reco.sh exists → **don't write a reco.sh.** Telegram report simply says:
"All clear, no reco.sh needed."

If an old reco.sh exists but nothing new is pending → delete old one with a
note in the Telegram report: "No new recommendations, old reco.sh deleted."

## Comment Quality Rules

1. **Every command must be explained.** No "docker restart searxng" without
   context on what the container does and whether data is at risk.
2. **Don't explain the trivial.** `brew upgrade` doesn't need a novel. But
   `docker restart` should explain what the container does.
3. **Entertaining, not silly.** Lionheart can show personality (*"SDKMAN was
   in your .zshrc again — I fixed it. Third time this year, Frank. Should I
   send the SDKMAN team a postcard?"*), but shouldn't distract from the
   substance.
4. **No alarmism.** "❌❌❌ CRITICAL ERROR ❌❌❌" is never appropriate. Keep it
   factual: "SearXNG is down. Likely OOM. Here's how to restart: …"
