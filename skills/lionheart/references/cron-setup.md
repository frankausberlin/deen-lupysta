# Cron Setup — Daily Heartbeat Installation

This guide explains how to install the Lionheart daily heartbeat as a
cron job in Hermes.

> ⚠️ **All generated output (Telegram reports, reco.sh, KNOWN_ISSUES.md,
> cron logs) MUST be in English.** German is reserved exclusively for
> direct conversation with the User.

## Prerequisites

- Hermes Agent installed (`~/.hermes/` populated)
- Lionheart skill available (canonical: `~/gits/deen-lupysta/skills/lionheart/`)
- Telegram bot configured (for delivery)
- A workspace directory (e.g. `~/labor/heartbeat/`)

## Installation

### 1. Register the cron job

Use the Hermes cron CLI to register a recurring daily heartbeat:

```shell
hermes cronjob create \
  --name "lionheart-daily" \
  --schedule "0 9 * * *" \
  --prompt "Run the Lionheart daily heartbeat. Use your lionheart skill, perform the 8 daily Tier-1 health checks, deliver a short Telegram report, and write ~/reco.sh only if there are 🟡 or 🔴 items." \
  --deliver all \
  --skills lionheart
```

> 🚨 **Critical Pitfall #8: `deliver` defaults to `local`!**
>
> If you do NOT pass `--deliver all` on `create`, the cron job will save
> its output to the local log and **never reach your Telegram chat**.
> The default is silently `local` to keep cron runs quiet by default.
> Always pass `--deliver all` for any user-facing notification job, or
> update the job afterward with:
>
> ```shell
> hermes cronjob update --job-id <id> --deliver all
> ```

### 2. Verify delivery

After the first scheduled run (or trigger manually):

```shell
hermes cronjob run --job-id <id>
```

Confirm in Telegram that the report arrived.

### 3. Inspect the job

```shell
hermes cronjob list
```

Look for the `deliver` column. It must read `all` (or your custom
target), never `local` for notification jobs.

## Manual Trigger (for testing)

Outside the cron schedule:

```shell
hermes chat -q "Leo, run the daily heartbeat" -s lionheart
```

Or from the Hermes Desktop App: open a session, prefix with the
`lionheart` skill, and ask Leo to run the heartbeat.

## Common Pitfalls

| # | Pitfall | Symptom | Fix |
|---|---|---|---|
| 1 | Forgot `--deliver all` | Cron runs, log saved, **no Telegram message** | `hermes cronjob update --job-id <id> --deliver all` |
| 2 | Skill not loaded by cron prompt | Lionheart runs in generic mode, no 4-tier logic | Re-create with `--skills lionheart` |
| 3 | `.env` keys missing in gateway | 401 errors, empty reports | Verify systemd drop-in or `.env` (see Hermes Gateway docs) |
| 4 | Cron schedule in wrong timezone | Heartbeat fires at unexpected local time | Hermes cron uses server local time; check `date` |
| 5 | Reco.sh overwritten without archive | Old recommendations lost | See `references/reco-format.md` — archiving is mandatory |

## See also

- `references/daily-checks.md` — what the daily heartbeat actually does
- `references/reco-format.md` — how `~/reco.sh` is structured
- `references/weekly-checks.md` — the deeper Sunday inspection
