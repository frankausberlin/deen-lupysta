# Daily Heartbeat Checks

Daily health check, duration ~30 seconds. Acute issues only.
If nothing unusual → short Telegram status. If something's up → details in
report, possibly reco.sh.

> ⚠️ All commands run without sudo. Frank is in the `adm`, `docker`, and
> `systemd-journal` groups, giving all necessary read permissions.

---

## 1. System Services — Alive?

```bash
for svc in ollama docker mcphub open-webui; do
  if systemctl is-active --quiet "$svc"; then
    echo "  ✅ $svc"
  else
    echo "  ❌ $svc DOWN"
  fi
done
```

**🟢 Tier 1.** If down: mention in Telegram report, include restart command as
info. No automatic restart.

---

## 2. Docker Containers — All Healthy?

```bash
docker ps -a --format '{{.Names}} {{.Status}}' 2>/dev/null
```

**🟢 Tier 1.** Report containers with `Exited` or `unhealthy`. No automatic
restart.

---

## 3. Disk Space

```bash
df -h / /home 2>/dev/null | awk 'NR>1 {print $6, $5, $4" free"}'
```

**🟢 Tier 1.** Only report if usage >90% (i.e. <10% free).
If >95%: ⚠️ in Telegram, reco.sh entry with `du -sh` diagnostic commands.

---

## 4. Journal Errors — Last 24h

```bash
journalctl -p err --since "24h ago" --no-pager 2>/dev/null | tail -20
```

**🟢 Tier 1.** Count, don't send all lines:
- 0 entries → nothing to report
- 1-4 entries → Telegram: "X journal errors, nothing critical"
- 5+ entries → Telegram: "⚠️ X journal errors, details in reco.sh"

---

## 5. auth.log — Failed Logins?

```bash
grep -i "failed\|invalid user\|authentication failure" /var/log/auth.log 2>/dev/null | tail -10
```

**🟢 Tier 1.**
- 0 → nothing to report
- 1-3 → "X SSH fails" in Telegram
- 4+ → ⚠️ Telegram + details in reco.sh (include IPs)

---

## 6. pm2 Status

```bash
pm2 status 2>/dev/null || echo "pm2 unreachable"
```

**🟢 Tier 1.** Report stopped processes. No automatic restart.

---

## 7. SearXNG Reachable?

```bash
curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://localhost:8080 2>/dev/null
```

**🟢 Tier 1.** If not 200 or timeout → Telegram warning.

---

## 8. Shlib Lock — Unchanged?

```bash
[ -f ~/.zshrc.lock ] && ! cmp -s ~/.zshrc ~/.zshrc.lock && \
  echo "⚠️ SHLIB LOCK VIOLATION" && diff -u --color=never ~/.zshrc.lock ~/.zshrc | head -30
```

**🟢 Tier 1, but critical.** If lock is violated → ⚠️ in Telegram, full diff
in reco.sh. This is a serious signal — something (SDKMAN, brew, an installer)
wrote to `.zshrc` without Users's knowledge.

---

## Report Template (Telegram)

All clear:
```
Leo here. All healthy. ✋
```

With findings:
```
⚠️ Lionheart Heartbeat: SearXNG down (curl timeout), 3 SSH fails.
Details in ~/reco.sh
```

---

## Not in Heartbeat (belongs in Weekly Checkup)

- Version checks (brew, uv, cargo, pnpm, …)
- Docker image/log cleanup
- MCP server status
- fail2ban statistics
- unattended-upgrades logs
- SDKMAN tampering with .zshrc
- deensync
- Ollama models/disk usage
- Rust toolchain
- rbenv/gem
- Go version
- Java/JDK
