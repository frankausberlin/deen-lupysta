# Weekly Checkup Checks

Sunday morning, full program. All daily checks run first, followed by the
weekly deep inspections below. Duration: 2-5 minutes.

## What the Weekly Checkup Does

1. Run all daily checks (see `daily-checks.md`).
2. Run the additional weekly checks below.
3. Collect all results.
4. Telegram short message + `~/reco.sh` (appended if daily reco.sh exists).

## Weekly Deep Checks

These checks go beyond the stage test suite. They cover things that don't
need daily monitoring but should be checked weekly.

### Version Updates Available?

```bash
# Homebrew
brew update >/dev/null 2>&1 && brew outdated

# Cargo tools
cargo install-update --list 2>/dev/null || echo "cargo-update not installed"

# pnpm global tools
pnpm outdated -g 2>/dev/null || echo "pnpm outdated failed"

# uv tools
uv tool upgrade --all --dry-run 2>/dev/null || echo "uv tool check failed"
```

Report count of available updates. List in reco.sh as info (not recommendation,
since the user triggers upgrades himself).

### Node.js / Rust / Go / Java / Ruby Version Checks

```bash
echo "fnm: $(fnm --version)"
echo "Node: $(node --version)"
echo "LTS latest: $(fnm ls-remote --lts 2>/dev/null | tail -1)"

rustup update --dry-run 2>/dev/null || echo "rustup check failed"

go version 2>/dev/null
apt list --upgradable 2>/dev/null | grep golang-go || echo "go: no apt info"

echo "rbenv: $(rbenv --version 2>/dev/null || echo 'not installed')"
echo "Ruby global: $(rbenv global 2>/dev/null || echo 'not set')"
echo "Gems outdated: $(gem outdated 2>/dev/null | wc -l)"
```

Note in reco.sh if updates available. Info only.

### SDKMAN Tampered With .zshrc?

```bash
if grep -q "THIS MUST BE AT THE END OF THE FILE" ~/.zshrc 2>/dev/null; then
  echo "⚠️ SDKMAN tampered with .zshrc! Shlib lock violated."
fi
```

If detected → ⚠️ in Telegram, repair command in reco.sh:
`cp ~/.zshrc.lock ~/.zshrc && exec zsh` (without the SDKMAN block; user must
manually integrate SDKMAN into shlib).

### Stale fnm_multishells Paths?

```bash
grep -R "fnm_multishells" ~/.shlib/shlibs 2>/dev/null && echo "⚠️ STALE FNM PATHS" || true
grep -R -E '^export PATH=([^"$]|"[^$]*")' ~/.shlib/shlibs 2>/dev/null && echo "⚠️ HARDCODED PATHS" || true
```

If found → document in reco.sh.

### Docker Cleanup

```bash
echo "Dangling images: $(docker images -f 'dangling=true' -q 2>/dev/null | wc -l)"
echo "Docker disk usage: $(docker system df 2>/dev/null | tail -1)"
```

If dangling images >0: `docker image prune -f` is safe — recommend in reco.sh.
If >1GB total Docker waste: note in reco.sh.

### deensync — Clean Copy Current?

```bash
# Check if source and target directories are in sync
diff -rq ~/gits/deen-lupysta/ ~/labor/synced-deen-lupysta/ \
  --exclude='.git' --exclude='ignore' 2>/dev/null | wc -l
```

If there are differences: recommend running `deensync` in reco.sh.

### fail2ban Statistics (needs sudo — goes to reco.sh)

```bash
# This command requires sudo — add to reco.sh as a recommendation:
# sudo fail2ban-client status sshd
```

Note in reco.sh: "Run to see fail2ban statistics: X currently banned, Y total this week."

### auth.log Deep Analysis

```bash
# Repeat-offender IPs this week
grep "Failed password" /var/log/auth.log 2>/dev/null | \
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -5
```

Top IPs listed in reco.sh. User can decide whether to manually block them.
Lionheart NEVER blocks IPs.

### Ollama Models & Disk Usage (only if Stage 4 installed)

```bash
ollama list 2>/dev/null
echo "---"
du -sh /usr/share/ollama/.ollama/models 2>/dev/null || du -sh ~/.ollama/models 2>/dev/null
```

Model list and disk usage in reco.sh as info.

## Telegram Report Template (Sunday Checkup)

```
🦁 Lionheart Weekly Checkup — {date}

Daily checks: X pass, Y fail
Weekly checks: Z updates available, W issues found
[hitl] checks: N available

Details in ~/reco.sh: M items
Happy Sunday, Frank! ☕
```
