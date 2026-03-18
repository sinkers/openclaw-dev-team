#!/usr/bin/env bash
# setup.sh — Install openclaw-dev-team agent workspaces
# Usage: ./setup.sh [--openclaw-dir <path>] [--project-name <name>]

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
OPENCLAW_DIR="${HOME}/.openclaw"
PROJECT_NAME=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --openclaw-dir)
      OPENCLAW_DIR="$2"
      shift 2
      ;;
    --project-name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--openclaw-dir <path>] [--project-name <name>]"
      echo ""
      echo "  --openclaw-dir   Path to OpenClaw root directory (default: ~/.openclaw)"
      echo "  --project-name   Project name to embed in agent MEMORY.md files"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }
skip()    { echo "[SKIP]  $*"; }

# Copy a file only if destination does not already exist
safe_copy() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" ]]; then
    skip "$dst already exists — not overwriting"
  else
    cp "$src" "$dst"
    success "Copied $dst"
  fi
}

# ── Agents ────────────────────────────────────────────────────────────────────
AGENTS=(claw scout arch forge)

# ── Pre-flight ────────────────────────────────────────────────────────────────
info "OpenClaw directory : $OPENCLAW_DIR"
info "Project name       : ${PROJECT_NAME:-<not set>}"
echo ""

if [[ ! -d "$OPENCLAW_DIR" ]]; then
  warn "OpenClaw directory does not exist: $OPENCLAW_DIR"
  read -r -p "Create it? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    mkdir -p "$OPENCLAW_DIR"
    success "Created $OPENCLAW_DIR"
  else
    echo "Aborting." >&2
    exit 1
  fi
fi

# ── Create workspace dirs and copy agent files ────────────────────────────────
echo "── Installing agent workspaces ──────────────────────────────────────────"
for agent in "${AGENTS[@]}"; do
  workspace="${OPENCLAW_DIR}/workspace-${agent}"
  source_dir="${SCRIPT_DIR}/agents/${agent}"

  info "Setting up workspace: $workspace"
  mkdir -p "$workspace"

  if [[ ! -d "$source_dir" ]]; then
    warn "Source directory not found: $source_dir — skipping agent $agent"
    continue
  fi

  # Copy each file in the agent source dir
  for src_file in "$source_dir"/*; do
    [[ -f "$src_file" ]] || continue
    filename="$(basename "$src_file")"
    dst_file="${workspace}/${filename}"
    safe_copy "$src_file" "$dst_file"
  done

  # If a project name was given, substitute placeholder in MEMORY.md
  if [[ -n "$PROJECT_NAME" && -f "${workspace}/MEMORY.md" ]]; then
    if grep -q '<project name>' "${workspace}/MEMORY.md" 2>/dev/null; then
      sed -i "s/<project name>/${PROJECT_NAME}/g" "${workspace}/MEMORY.md"
      info "  Substituted <project name> → $PROJECT_NAME in MEMORY.md"
    fi
  fi

  echo ""
done

# ── Create memory subdirectories ──────────────────────────────────────────────
echo "── Creating memory directories ──────────────────────────────────────────"
for agent in "${AGENTS[@]}"; do
  workspace="${OPENCLAW_DIR}/workspace-${agent}"
  memory_dir="${workspace}/memory"
  if [[ ! -d "$memory_dir" ]]; then
    mkdir -p "$memory_dir"
    success "Created $memory_dir"
  else
    skip "$memory_dir already exists"
  fi
done

echo ""

# ── Post-install checklist ────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════════════════"
echo "  Post-Install Checklist"
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "  [ ] 1. Fill in MEMORY.md for each agent:"
for agent in "${AGENTS[@]}"; do
  echo "           ${OPENCLAW_DIR}/workspace-${agent}/MEMORY.md"
done
echo ""
echo "  [ ] 2. Update <user name> and team roster in each MEMORY.md"
echo ""
echo "  [ ] 3. Copy and configure OpenClaw template:"
echo "           cp ${SCRIPT_DIR}/config/openclaw.json.template <your openclaw config>"
echo "         Then fill in:"
echo "           - API keys"
echo "           - Channel IDs (Telegram, Slack, etc.)"
echo "           - Project name"
echo "           - Model preferences"
echo ""
echo "  [ ] 4. Register each agent workspace with OpenClaw"
echo ""
echo "  [ ] 5. Start Claw first — it monitors the other agents"
echo ""
echo "  [ ] 6. Start Scout, Arch, and Forge once Claw is running"
echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "  Done. Good luck."
echo "════════════════════════════════════════════════════════════════════════"
