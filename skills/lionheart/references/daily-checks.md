# Daily Checks

Daily health check. Duration: ~30 seconds (depends on how many stages are installed).

## Workflow

1. Read `~/.deenlupysta/MYDEENLUPYSTA.md` to determine which stages are installed.
2. For each installed stage, run the corresponding `.sh` test files from `~/gits/deen-lupysta/test/`.
3. Collect all PASS/FAIL/SKIP results.
4. Send a short Telegram report.
5. Write `~/reco.sh` only if there are failures or sudo requirements.
6. List any [hitl] checks for the user's awareness.

## What the Tests Check

The `.sh` test files are self-documenting. Each test file has a header comment
explaining which stage it corresponds to. Lionheart does not duplicate the check
list here — the test files are the source of truth.

Run a test manually to see what it checks:

```bash
bash ~/gits/deen-lupysta/test/de-02-zsh1-shlib-test.sh
```

## Additional Daily Checks (not in test files)

These checks are Lionheart-specific and not part of the stage test suite:

### System Health (always runs)

```bash
# Disk space
df -h / /home 2>/dev/null | awk 'NR>1 {print $6, $5, $4" free"}'
```

Report only if usage >90%. If >95%: ⚠️ in Telegram, reco.sh entry with `du -sh` diagnostics.

```bash
# Journal errors last 24h
journalctl -p err --since "24h ago" --no-pager 2>/dev/null | tail -20
```

Count, don't send all lines:
- 0 entries → nothing to report
- 1-4 → "X journal errors, nothing critical"
- 5+ → ⚠️ in Telegram, details in reco.sh

```bash
# Shlib lock integrity
[ -f ~/.zshrc.lock ] && ! cmp -s ~/.zshrc ~/.zshrc.lock && \
  echo "⚠️ SHLIB LOCK VIOLATION" && diff -u --color=never ~/.zshrc.lock ~/.zshrc | head -30
```

If lock violated → ⚠️ in Telegram, full diff in reco.sh. Something wrote to .zshrc
without the user's knowledge.

## Telegram Report Templates

All clear:
```
Leo here. All healthy. ✋
```

With findings:
```
⚠️ Lionheart Daily Check: 2 failures in de-04-net-security.
Details in ~/reco.sh
```

With hitl checks:
```
Leo here. All auto-tests pass. ✋
[hitl] checks available: 3 (see test files for details).
```

## No reco.sh When Everything Is Fine

If all tests pass, no sudo checks pending, no old reco.sh → don't write reco.sh.
If an old reco.sh exists but nothing new → archive old one, note in Telegram report:
"No new recommendations, old reco.sh archived."
