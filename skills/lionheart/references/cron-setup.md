# Cron Setup — Daily and Weekly Heartbeat Installation

This guide explains how to install the Lionheart daily and weekly heartbeats
as cron jobs in Hermes.

> ⚠️ **All generated output (Telegram reports, reco.sh, cron logs) MUST be in
> English.** German is reserved exclusively for direct conversation with the user.

## Prerequisites

- Hermes Agent installed (`~/.hermes/` populated)
- Lionheart skill available (canonical: `~/gits/deen-lupysta/skills/lionheart/`)
- Telegram bot configured (for delivery)
- `~/.deenlupysta/MYDEENLUPYSTA.md` exists (Lionheart reads it to know what's installed)

## Installation

### 1. Register the daily cron job

```shell
hermes cronjob create \
  --name "lionheart-daily" \
  --schedule "0 9 * * *" \
  --prompt "Run the Lionheart daily check. Use your lionheart skill. Read ~/.deenlupysta/MYDEENLUPYSTA.md to determine installed stages, run the corresponding .sh test files from ~/gits/deen-lupysta/test/, send a short Telegram report, and write ~/reco.sh only if there are failures or sudo requirements." \
  --deliver all \
  --skills lionheart
```

> 🚨 **Critical: `deliver` defaults to `local`!**
>
> If you do NOT pass `--deliver all`, the cron job will save its output to the
> local log and **never reach your Telegram chat**. Always pass `--deliver all`
> for any user-facing notification job.

### 2. Register the weekly cron job (optional)

```shell
hermes cronjob create \
  --name "lionheart-weekly" \
  --schedule "0 10 * * 0" \
  --prompt "Run the Lionheart weekly checkup. Use your lionheart skill. Run all daily checks plus the weekly deep checks from references/weekly-checks.md. Append to ~/reco.sh if a daily reco.sh from today exists, otherwise write a fresh one." \
  --deliver all \
  --skills lionheart
```

### 3. Verify delivery

After the first scheduled run (or trigger manually):

```shell
hermes cronjob list
```

Look for the `deliver` column. It must read `all` (or your custom target),
never `local` for notification jobs.

### 4. Manual trigger (for testing)

```shell
hermes chat -q "Leo, run the daily check" -s lionheart
hermes chat -q "Leo, run the weekly checkup" -s lionheart
```

Or from the Hermes Desktop App: open a session, prefix with the `lionheart`
skill, and ask Leo to run the check.

## Common Pitfalls

| # | Pitfall | Symptom | Fix |
|---|---------|---------|-----|
| 1 | Forgot `--deliver all` | Cron runs, log saved, **no Telegram message** | `hermes cronjob update --job-id <id> --deliver all` |
| 2 | Skill not loaded by cron prompt | Lionheart runs in generic mode, no test execution | Re-create with `--skills lionheart` |
| 3 | MYDEENLUPYSTA.md missing | Lionheart reports error and stops | Create with Conrad (the Concierge) |
| 4 | `.env` keys missing in gateway | 401 errors, empty reports | Verify systemd drop-in or `.env` |
| 5 | Cron schedule in wrong timezone | Heartbeat fires at unexpected local time | Hermes cron uses server local time; check `date` |
| 6 | reco.sh overwritten by weekly | Weekly recommendations lost | Use append logic (see `references/reco-format.md`) |

## See also

- `references/daily-checks.md` — what the daily check does
- `references/weekly-checks.md` — the deeper Sunday inspection
- `references/reco-format.md` — how `~/reco.sh` is structured
