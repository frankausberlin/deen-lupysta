# Weekly Checkup Checks

Sunday morning, full program. All Heartbeat checks plus deep inspections.
Duration: 2-5 minutes. Output: Telegram short message + `~/reco.sh`.

Heartbeat checks from `daily-checks.md` run first (1-8), followed by the
weekly additions below.

> ⚠️ All commands without sudo. See daily-checks.md for permission docs.

---

## 9. Brew Updates Available?

```bash
brew update >/dev/null 2>&1 && brew outdated
```

**🟢 Tier 1.** Report count. List in reco.sh as info (not recommendation,
since Frank triggers `brew upgrade` himself).

---

## 10. Cargo Tools Current?

```bash
cargo install-update --list 2>/dev/null || echo "cargo-update not installed"
```

**🟢 Tier 1.** List outdated tools in reco.sh. No automatic update.

---

## 11. pnpm Global Tools Current?

```bash
pnpm outdated -g 2>/dev/null || echo "pnpm outdated failed"
```

**🟢 Tier 1.** List in reco.sh. No automatic update.

---

## 12. uv Tool Upgrades Available?

```bash
uv tool upgrade --all --dry-run 2>/dev/null || echo "uv tool check failed"
```

**🟢 Tier 1.** List in reco.sh. No automatic upgrade.

---

## 13. fnm & Node Version Current?

```bash
echo "fnm: $(fnm --version)"
echo "Node: $(node --version)"
echo "LTS latest: $(fnm ls-remote --lts 2>/dev/null | tail -1)"
```

**🟢 Tier 1.** If Node LTS is newer than installed → note in reco.sh.

---

## 14. Rust Toolchain Current?

```bash
rustup update --dry-run 2>/dev/null || echo "rustup check failed"
```

**🟢 Tier 1.** Note in reco.sh if update available.

---

## 15. Go Version Current?

```bash
go version 2>/dev/null
apt list --upgradable 2>/dev/null | grep golang-go || echo "go: no apt info"
```

**🟢 Tier 1.** Note in reco.sh if outdated. (Caution: no `nala`! Info only.)

---

## 16. rbenv + Ruby Version

```bash
echo "rbenv: $(rbenv --version 2>/dev/null || echo 'not installed')"
echo "Ruby global: $(rbenv global 2>/dev/null || echo 'not set')"
echo "Gems outdated: $(gem outdated 2>/dev/null | wc -l)"
```

**🟢 Tier 1.** Overview in reco.sh.

---

## 17. SDKMAN Tampered With .zshrc?

```bash
if grep -q "THIS MUST BE AT THE END OF THE FILE" ~/.zshrc 2>/dev/null; then
  echo "⚠️ SDKMAN tampered with .zshrc! Shlib lock violated."
fi
```

**🟢 Tier 1, but critical.** SDKMAN likes to append to `.zshrc` — this
destroys the shlib lock and direnv integration. If detected → ⚠️ in Telegram,
repair command in reco.sh: `cp ~/.zshrc.lock ~/.zshrc && exec zsh` (but
without the SDKMAN block; Frank must manually integrate SDKMAN into shlib).

---

## 18. Stale fnm_multishells Paths?

```bash
grep -R "fnm_multishells" ~/.shlib/shlibs 2>/dev/null && echo "⚠️ STALE FNM PATHS" || true
grep -R -E '^export PATH=([^"$]|"[^$]*")' ~/.shlib/shlibs 2>/dev/null && echo "⚠️ HARDCODED PATHS" || true
```

**🟢 Tier 1.** This is a trap explicitly described in Deen Lupysta's Node.js
docs. If found → document in reco.sh.

---

## 19. Docker Images — Cleanup Needed?

```bash
echo "Dangling images: $(docker images -f 'dangling=true' -q 2>/dev/null | wc -l)"
echo "Docker disk usage: $(docker system df 2>/dev/null | tail -1)"
```

**🟡 Tier 2.** If dangling images >0: `docker image prune -f` (Lionheart does
this autonomously, safe). If >1GB total Docker waste: info in reco.sh.

---

## 20. Docker Container Log Sizes

```bash
docker ps -q | xargs -I{} sh -c 'echo "{} $(docker inspect --format="{{.Name}}" {}) $(docker logs --tail 1 {} 2>&1 | wc -c)"' 2>/dev/null
```

**🟢 Tier 1.** Simply list log sizes. Frank sees if anything exploded.
(`/etc/docker/daemon.json` has `max-size:10m` configured, so this should never
happen — but checking doesn't hurt.)

---

## 21. MCP Server Status

```bash
# mcphub status via API
curl -s --connect-timeout 5 http://localhost:3000/api/servers 2>/dev/null | \
  python3 -c "import sys,json; d=json.load(sys.stdin); [print(f'  {s[\"name\"]}: {s.get(\"status\",\"unknown\")}') for s in d.get('servers',[])]" 2>/dev/null || echo "mcphub API unreachable"
```

**🟢 Tier 1.** Report offline servers. No automatic restart (the MCPHub docs
say: "just wait and try again later").

---

## 22. Firecrawl Container

```bash
docker ps --format '{{.Names}} {{.Status}}' 2>/dev/null | grep -i firecrawl || echo "firecrawl not found"
```

**🟢 Tier 1.** If down → info in reco.sh: `cd ~/gits/firecrawl && docker compose up -d`.

---

## 23. deensync — Clean Copy Current?

```bash
# Check if source and target directories are in sync
diff -rq ~/gits/deen-lupysta/ ~/labor/synced-deen-lupysta/ \
  --exclude='.git' --exclude='ignore' 2>/dev/null | wc -l
```

**🟡 Tier 2.** If there are differences: Lionheart runs `deensync` himself
(alias = `rsync -av --delete ...`). Briefly mentioned in report: "deensync: X
files updated".

---

## 24. Ollama Models & Disk Usage

```bash
ollama list 2>/dev/null
echo "---"
du -sh /usr/share/ollama/.ollama/models 2>/dev/null || du -sh ~/.ollama/models 2>/dev/null
```

**🟢 Tier 1.** Model list and disk usage in reco.sh as info.

---

## 25. fail2ban Statistics

```bash
sudo fail2ban-client status sshd 2>/dev/null | grep -E "Currently banned|Total banned"
```

**🟢 Tier 1.** Stats in Telegram report: "fail2ban: X currently banned, Y
total this week". If many bans → note in reco.sh.

---

## 26. unattended-upgrades Log

```bash
tail -30 /var/log/unattended-upgrades/unattended-upgrades.log 2>/dev/null || echo "Log not readable"
```

**🟢 Tier 1.** Only mention in Telegram report if errors are in the log.
Otherwise: nothing.

---

## 27. p10k/Fonts Intact?

```bash
[ -f ~/.p10k.zsh ] && echo "✅ p10k config" || echo "❌ p10k config missing"
fc-list | grep -i "MesloLGS" | head -1 || echo "❌ MesloLGS Font missing"
```

**🟢 Tier 1.** Missing fonts → warning in Telegram report.

---

## 28. direnv/direnvrc Intact?

```bash
[ -f ~/.config/direnv/direnvrc ] && echo "✅ direnvrc" || echo "❌ direnvrc missing"
```

**🟢 Tier 1.**

---

## 29. auth.log Deep Analysis

```bash
# Repeat-offender IPs this week
grep "Failed password" /var/log/auth.log 2>/dev/null | \
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -5
```

**🟢 Tier 1.** Top IPs listed in reco.sh. Frank can decide whether to
manually block them. Lionheart NEVER blocks IPs.

---

## Report Template (Telegram, Sunday Checkup)

```
🦁 Lionheart Weekly Checkup — Sun, May 11

Healthy: ollama, docker, mcphub, open-webui, pm2 ✅
Cleaned up: docker image prune (1.2 GB), deensync (3 files)
Updates available: brew (4), pnpm (2), cargo (1)
⚠️ SDKMAN tampered with .zshrc!
fail2ban: 3 currently banned, 12 total this week

Recommendations in ~/reco.sh: 6 items
Known issues: 0 new

Happy Sunday, Frank! ☕
```
