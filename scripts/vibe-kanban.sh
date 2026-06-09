#!/usr/bin/env zsh
# ==============================================================================
# 72-vibe-kanban.sh — Vibe-Kanban Remote Stack (Deen Lupysta, self-hosted)
#
# Manages the local self-hosted "Cloud" compose stack from
#   ~/gits/vibe-kanban/crates/remote/docker-compose.yml
# Lightweight profile: remote-db + electric + remote-server (no relay).
# Auth: bootstrap local admin (single shared credential pair in .env.remote).
# Web UI: http://localhost:3001
#
# The remote-server image builds from source on first `up` (~5-10 min on this
# machine). Subsequent `up` invocations reuse the Docker layer cache and are
# fast.
# ==============================================================================

# ---- paths --------------------------------------------------------------------
export VK_REPO="$HOME/gits/vibe-kanban"
export VK_COMPOSE_DIR="$VK_REPO/crates/remote"
export VK_COMPOSE_FILE="$VK_COMPOSE_DIR/docker-compose.yml"
export VK_ENV_FILE="$VK_COMPOSE_DIR/.env.remote"
export VK_URL="http://localhost:3001"

# ---- preflight ----------------------------------------------------------------
_vk_require() {
    command -v "$1" >/dev/null 2>&1 || {
        print -r -- "❌ missing: $1 — $2" >&2
        return 1
    }
    [ -f "$VK_COMPOSE_FILE" ] || {
        print -r -- "❌ compose file not found: $VK_COMPOSE_FILE" >&2
        return 1
    }
    [ -f "$VK_ENV_FILE" ] || {
        print -r -- "❌ .env.remote not found: $VK_ENV_FILE" >&2
        return 1
    }
}

# ---- wrapper ------------------------------------------------------------------
vk() {
    emulate -L zsh
    local subcmd="${1:-help}"
    shift || true

    case "$subcmd" in
        up|start)
            _vk_require docker "finish the Docker setup first" || return 1
            _vk_require "docker compose" "Docker Compose v2 required" || return 1
            (cd "$VK_COMPOSE_DIR" && \
                docker compose --env-file "$VK_ENV_FILE" -f "$VK_COMPOSE_FILE" up -d "$@")
            ;;

        down|stop)
            (cd "$VK_COMPOSE_DIR" && \
                docker compose --env-file "$VK_ENV_FILE" -f "$VK_COMPOSE_FILE" down "$@")
            ;;

        build)
            (cd "$VK_COMPOSE_DIR" && \
                docker compose --env-file "$VK_ENV_FILE" -f "$VK_COMPOSE_FILE" build "$@")
            ;;

        logs)
            (cd "$VK_COMPOSE_DIR" && \
                docker compose --env-file "$VK_ENV_FILE" -f "$VK_COMPOSE_FILE" logs -f "$@")
            ;;

        ps|status)
            docker ps --filter "name=remote-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            ;;

        health)
            curl -sS -o /dev/null -w "%{http_code}\n" "$VK_URL/v1/health" 2>/dev/null \
                || print -r -- "❌ $VK_URL unreachable"
            ;;

        open)
            command -v xdg-open >/dev/null && xdg-open "$VK_URL" >/dev/null 2>&1 \
                || open "$VK_URL" 2>/dev/null \
                || print -r -- "open $VK_URL in your browser"
            ;;

        token)
            # Print a fresh access token for the bootstrap admin (uses local auth).
            _vk_require curl "curl is required" || return 1
            local email="${SELF_HOST_LOCAL_AUTH_EMAIL:-}"
            local pass="${SELF_HOST_LOCAL_AUTH_PASSWORD:-}"
            if [ -z "$email" ] || [ -z "$pass" ]; then
                # pull from .env.remote if not exported
                email="$(grep -E '^SELF_HOST_LOCAL_AUTH_EMAIL=' "$VK_ENV_FILE" | cut -d= -f2- | tr -d '"')"
                pass="$(grep -E '^SELF_HOST_LOCAL_AUTH_PASSWORD=' "$VK_ENV_FILE" | cut -d= -f2- | tr -d '"')"
            fi
            curl -sS -X POST "$VK_URL/v1/auth/local/login" \
                -H "Content-Type: application/json" \
                -d "{\"email\":\"$email\",\"password\":\"$pass\"}" \
                | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token', d))"
            ;;

        reset|wipe)
            # ⚠️ Destructive: drops DB + Electric state. Keeps JWT secret.
            (cd "$VK_COMPOSE_DIR" && \
                docker compose --env-file "$VK_ENV_FILE" -f "$VK_COMPOSE_FILE" down -v "$@")
            ;;

        help|*)
            cat <<EOF
vk — Vibe-Kanban stack manager (Deen Lupysta)

Subcommands:
  up [args]      Start the stack in detached mode (builds on first run)
  down [args]    Stop the stack (keeps volumes)
  build [args]   Rebuild the remote-server image without restarting
  logs [svc]     Tail logs (optionally for a single service)
  ps / status    List running vibe-kanban containers
  health         Curl \$VK_URL/v1/health and print HTTP status
  open           Open the web UI in your default browser
  token          Print a fresh JWT access token (bootstrap admin)
  reset / wipe   ⚠️  Stop stack AND drop all volumes (full state reset)

Paths:
  repo     \$VK_REPO
  compose  \$VK_COMPOSE_FILE
  env      \$VK_ENV_FILE
  web ui   \$VK_URL
EOF
            ;;
    esac
}
