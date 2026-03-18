#!/usr/bin/env bash
# arch-checkin.sh — Arch developer agent check-in
# Runs every 15 minutes via cron. Pings each registered developer agent,
# checks responsiveness, and reports stale/silent agents to Arch.
#
# Crontab entry:
#   */15 * * * * /path/to/openclaw-dev-team/scripts/arch-checkin.sh >> /var/log/arch-checkin.log 2>&1
#
# Configuration: set these environment variables or create a .env file at AGENT_ROSTER_FILE

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${ARCH_CHECKIN_CONFIG:-$SCRIPT_DIR/../config/agent-roster.json}"
OPENCLAW_URL="${OPENCLAW_URL:-http://localhost:18789}"
OPENCLAW_TOKEN="${OPENCLAW_TOKEN:-}"
ARCH_SESSION_KEY="${ARCH_SESSION_KEY:-arch}"
STALE_THRESHOLD_MINUTES="${STALE_THRESHOLD_MINUTES:-20}"
PING_TIMEOUT_SECONDS="${PING_TIMEOUT_SECONDS:-15}"

# ── Helpers ──────────────────────────────────────────────────────────────────

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
err() { log "ERROR: $*" >&2; }

require() {
  command -v "$1" >/dev/null 2>&1 || { err "Required command not found: $1"; exit 1; }
}

require curl
require jq
require python3

# ── Load roster ───────────────────────────────────────────────────────────────

if [[ ! -f "$CONFIG_FILE" ]]; then
  err "Agent roster not found at $CONFIG_FILE"
  err "Copy config/agent-roster.json.template to config/agent-roster.json and configure it"
  exit 1
fi

AGENTS=$(jq -c '.agents[]' "$CONFIG_FILE")
if [[ -z "$AGENTS" ]]; then
  log "No agents in roster — nothing to check"
  exit 0
fi

# ── Ping each agent ───────────────────────────────────────────────────────────

STALE_AGENTS=()
UNRESPONSIVE_AGENTS=()
HEALTHY_AGENTS=()

while IFS= read -r agent; do
  name=$(echo "$agent" | jq -r '.name')
  session_key=$(echo "$agent" | jq -r '.session_key')
  agent_url=$(echo "$agent" | jq -r '.openclaw_url // empty')
  agent_token=$(echo "$agent" | jq -r '.token // empty')

  TARGET_URL="${agent_url:-$OPENCLAW_URL}"
  TARGET_TOKEN="${agent_token:-$OPENCLAW_TOKEN}"

  log "Pinging $name (session: $session_key)"

  RESPONSE=$(curl -s \
    --max-time "$PING_TIMEOUT_SECONDS" \
    -X POST "$TARGET_URL/v1/chat/completions" \
    -H "Authorization: Bearer $TARGET_TOKEN" \
    -H "Content-Type: application/json" \
    -H "x-openclaw-session-key: $session_key" \
    -d "{\"model\":\"openclaw:$name\",\"messages\":[{\"role\":\"user\",\"content\":\"arch-checkin: status? Reply with one of: idle | working: <brief task description> | blocked: <reason>\"}]}" \
    2>/dev/null) || true

  if [[ -z "$RESPONSE" ]]; then
    log "  ⚠️  $name — no response (timeout or connection refused)"
    UNRESPONSIVE_AGENTS+=("$name")
    continue
  fi

  STATUS_CODE=$(echo "$RESPONSE" | jq -r '.error.code // empty' 2>/dev/null || true)
  if [[ -n "$STATUS_CODE" ]]; then
    log "  ⚠️  $name — API error: $(echo "$RESPONSE" | jq -r '.error.message // "unknown"')"
    UNRESPONSIVE_AGENTS+=("$name")
    continue
  fi

  REPLY=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null || true)
  if [[ -z "$REPLY" ]]; then
    log "  ⚠️  $name — empty reply"
    UNRESPONSIVE_AGENTS+=("$name")
    continue
  fi

  log "  ✅ $name — $REPLY"
  HEALTHY_AGENTS+=("$name: $REPLY")

done <<< "$AGENTS"

# ── Report to Arch ────────────────────────────────────────────────────────────

TOTAL=${#HEALTHY_AGENTS[@]}
UNRESPONSIVE=${#UNRESPONSIVE_AGENTS[@]}

if [[ $UNRESPONSIVE -eq 0 && ${#STALE_AGENTS[@]} -eq 0 ]]; then
  log "All $TOTAL developer agents healthy — no action needed"
  exit 0
fi

# Build alert message for Arch
ALERT="arch-checkin alert ($(date '+%H:%M')):\n"

if [[ ${#UNRESPONSIVE_AGENTS[@]} -gt 0 ]]; then
  ALERT+="🔴 Unresponsive (no reply within ${PING_TIMEOUT_SECONDS}s):\n"
  for a in "${UNRESPONSIVE_AGENTS[@]}"; do
    ALERT+="  - $a\n"
  done
fi

if [[ ${#STALE_AGENTS[@]} -gt 0 ]]; then
  ALERT+="🟡 Stale (no output for >${STALE_THRESHOLD_MINUTES}min):\n"
  for a in "${STALE_AGENTS[@]}"; do
    ALERT+="  - $a\n"
  done
fi

ALERT+="Healthy: $(IFS=', '; echo "${HEALTHY_AGENTS[*]:-none}")\n"
ALERT+="Action: review the unresponsive agents and determine if tasks need to be reassigned."

log "Sending alert to Arch..."

curl -s \
  --max-time 30 \
  -X POST "$OPENCLAW_URL/v1/chat/completions" \
  -H "Authorization: Bearer $OPENCLAW_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-openclaw-session-key: $ARCH_SESSION_KEY" \
  -d "$(jq -n --arg msg "$(printf "$ALERT")" '{model:"openclaw:arch",messages:[{role:"user",content:$msg}]}')" \
  > /dev/null 2>&1 || err "Failed to notify Arch"

log "Alert sent. Exiting."
exit 1  # non-zero so cron logs capture the alert
