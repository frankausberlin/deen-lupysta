# reco.sh Format Specification

`~/reco.sh` is Lionheart's recommendation file — an executable shell script
with commented action suggestions. The user opens the file, reads Lionheart's
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
# 🔴 SearXNG container down
#
# Problem: SearXNG not responding (curl timeout on localhost:8090).
# Container is running but the application is hung.
#
# Solution: Restart the container. No data loss — config is in
# ~/.searxng/config/ and the volume is persistent.
#
# Command:
docker restart searxng
#
# Verify afterwards: curl -s -o /dev/null -w "%{http_code}" http://localhost:8090
# (should return 200)
# ─────────────────────────────────────────────
```

## What Goes Into reco.sh

- **Failed [auto] tests** — the test that failed, why it failed, how to fix it
- **Sudo checks** — checks that couldn't run without root (commented, user must uncomment)
- **Weekly recommendations** — updates available, cleanup suggestions
- **[hitl] check summaries** — what the user should check manually

## What Does NOT Go Into reco.sh

- Passed tests (no entry needed)
- Information-only checks (disk usage, model lists) — these go in the Telegram report
- nala update/upgrade — never suggest this (user's sacred morning routine)

## Archiving

Before each **fresh** write of `~/reco.sh`:

```bash
# Archive old reco.sh (if it exists)
if [ -f ~/reco.sh ]; then
  TS=$(date +%Y%m%d-%H%M%S)
  mkdir -p ~/.lionheart/reco-history
  mv ~/reco.sh ~/.lionheart/reco-history/reco-${TS}.sh
  echo "📦 Old reco.sh archived: reco-history/reco-${TS}.sh"
fi
```

## Append Logic (Weekly Checkup Only)

The weekly checkup may need to add sudo recommendations to a reco.sh that was
already written by the daily check on the same day. This is the **only** situation
where reco.sh is appended to, not overwritten:

1. Check if `~/reco.sh` was created today (same date).
2. If yes: append the weekly section with a `# Weekly Checkup` header.
3. If no: archive old reco.sh (if exists) and write a new one.

```bash
# Check if reco.sh was created today
if [ -f ~/reco.sh ]; then
  RECO_DATE=$(stat -c %y ~/reco.sh 2>/dev/null | cut -d' ' -f1)
  TODAY=$(date +%Y-%m-%d)
  if [ "$RECO_DATE" = "$TODAY" ]; then
    # Append weekly section
    echo "" >> ~/reco.sh
    echo "# ═══════════════════════════════════════════" >> ~/reco.sh
    echo "# Weekly Checkup — $(date)" >> ~/reco.sh
    echo "# ═══════════════════════════════════════════" >> ~/reco.sh
    # ... append weekly recommendations ...
  else
    # Archive and write fresh
    # ... archive logic ...
    # ... write new reco.sh ...
  fi
fi
```

## No reco.sh When Everything Is Fine

If all tests pass and no sudo checks are pending:
- If no old reco.sh exists → **don't write a reco.sh.** Telegram report says:
  "All clear, no reco.sh needed."
- If an old reco.sh exists → archive it, note in Telegram report:
  "No new recommendations, old reco.sh archived."

## Comment Quality Rules

1. **Every command must be explained.** No `docker restart searxng` without
   context on what the container does and whether data is at risk.
2. **Don't explain the trivial.** `brew upgrade` doesn't need a novel. But
   `docker restart` should explain what the container does.
3. **Entertaining, not silly.** Lionheart can show personality (*"SDKMAN was
   in your .zshrc again — third time this year, Frank. Should I send the
   SDKMAN team a postcard?"*), but shouldn't distract from the substance.
4. **No alarmism.** "❌❌❌ CRITICAL ERROR ❌❌❌" is never appropriate. Keep it
   factual: "SearXNG is down. Likely OOM. Here's how to restart: …"
