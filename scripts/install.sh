#!/usr/bin/env bash
#
# install.sh — One-line installer for the LiberFi CLI + agent skills.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/liberfi-io/liberfi-skills/main/scripts/install.sh | bash
#
# Optional environment variables / flags:
#   LIBERFI_AGENTS=cursor,claude-code   Install skills only for the given agents
#                                       (default: all detected agents).
#   LIBERFI_SKIP_CLI=1                  Skip CLI install/upgrade.
#   LIBERFI_SKIP_SKILLS=1               Skip skills install.
#   LIBERFI_SKIP_PING=1                 Skip the connectivity check.
#
# Examples:
#   curl -fsSL .../install.sh | LIBERFI_AGENTS=cursor bash
#   curl -fsSL .../install.sh | bash -s -- --agents cursor,claude-code
#
# What this script does (idempotent — safe to re-run):
#   1. Verify Node.js (>= 18) and npm are available.
#   2. Install or upgrade @liberfi.io/cli globally.
#   3. Install all LiberFi skills via `npx skills add liberfi-io/liberfi-skills --all`.
#   4. Verify CLI works (`lfi --version`) and reach the API (`lfi ping`).
#   5. Print next steps (login, first command).
#
# Exit codes:
#   0  success
#   1  prerequisite missing (Node / npm / bash)
#   2  CLI install failed
#   3  skills install failed
#   4  verification failed (non-fatal — printed as warning)

set -euo pipefail

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_DIM='\033[2m'
  C_RED='\033[31m'
  C_GREEN='\033[32m'
  C_YELLOW='\033[33m'
  C_CYAN='\033[36m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_CYAN=''
fi

step()  { printf "${C_CYAN}${C_BOLD}==>${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$*"; }
info()  { printf "    %s\n" "$*"; }
ok()    { printf "    ${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn()  { printf "    ${C_YELLOW}!${C_RESET} %s\n" "$*"; }
fail()  { printf "    ${C_RED}✗${C_RESET} %s\n" "$*" >&2; }
hr()    { printf "%s\n" "${C_DIM}--------------------------------------------------${C_RESET}"; }

# ---------------------------------------------------------------------------
# Argument parsing (supports both env vars and flags)
# ---------------------------------------------------------------------------
LIBERFI_AGENTS="${LIBERFI_AGENTS:-}"
LIBERFI_SKIP_CLI="${LIBERFI_SKIP_CLI:-}"
LIBERFI_SKIP_SKILLS="${LIBERFI_SKIP_SKILLS:-}"
LIBERFI_SKIP_PING="${LIBERFI_SKIP_PING:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agents)
      LIBERFI_AGENTS="$2"; shift 2 ;;
    --skip-cli)
      LIBERFI_SKIP_CLI=1; shift ;;
    --skip-skills)
      LIBERFI_SKIP_SKILLS=1; shift ;;
    --skip-ping)
      LIBERFI_SKIP_PING=1; shift ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *)
      warn "Ignoring unknown argument: $1"
      shift ;;
  esac
done

# ---------------------------------------------------------------------------
# 1. Prerequisite check
# ---------------------------------------------------------------------------
step "Checking prerequisites"

if ! command -v node >/dev/null 2>&1; then
  fail "Node.js not found. Install Node.js 18+ from https://nodejs.org/ first."
  exit 1
fi
NODE_VERSION="$(node -v 2>/dev/null || echo unknown)"
NODE_MAJOR="$(printf '%s' "$NODE_VERSION" | sed -E 's/^v?([0-9]+).*/\1/')"
if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
  ok "Node.js $NODE_VERSION"
else
  warn "Node.js $NODE_VERSION detected; 18+ is recommended."
fi

if ! command -v npm >/dev/null 2>&1; then
  fail "npm not found. It usually ships with Node.js — please reinstall Node."
  exit 1
fi
ok "npm $(npm -v)"

# ---------------------------------------------------------------------------
# 2. Install / upgrade @liberfi.io/cli
# ---------------------------------------------------------------------------
if [ -n "$LIBERFI_SKIP_CLI" ]; then
  step "Skipping CLI install (LIBERFI_SKIP_CLI=1)"
else
  step "Installing @liberfi.io/cli (global)"
  if npm install -g @liberfi.io/cli >/tmp/liberfi-install-cli.log 2>&1; then
    if command -v lfi >/dev/null 2>&1; then
      ok "$(lfi --version 2>/dev/null || echo 'installed')"
    else
      warn "Install completed but \`lfi\` is not on PATH. You may need to add npm's"
      warn "global bin directory to PATH: $(npm bin -g 2>/dev/null || echo '<run: npm bin -g>')"
    fi
  else
    fail "Failed to install @liberfi.io/cli. See /tmp/liberfi-install-cli.log for details."
    tail -n 20 /tmp/liberfi-install-cli.log >&2 || true
    info "If permission denied, retry with: sudo npm install -g @liberfi.io/cli"
    exit 2
  fi
fi

# ---------------------------------------------------------------------------
# 3. Install LiberFi skills
# ---------------------------------------------------------------------------
if [ -n "$LIBERFI_SKIP_SKILLS" ]; then
  step "Skipping skills install (LIBERFI_SKIP_SKILLS=1)"
else
  step "Installing LiberFi skills"

  # `--all` is shorthand for `--skill '*' --agent '*' -y`. When the caller
  # restricts the agent list, we expand it manually so we can keep "-a" as
  # the agent filter while still installing every skill non-interactively.
  if [ -n "$LIBERFI_AGENTS" ]; then
    info "Targeting agents: $LIBERFI_AGENTS"
    SKILLS_ARGS=("add" "liberfi-io/liberfi-skills" "--skill" "*" "--yes")
    OLD_IFS="$IFS"; IFS=','
    for agent in $LIBERFI_AGENTS; do
      agent_trimmed="$(printf '%s' "$agent" | tr -d '[:space:]')"
      if [ -n "$agent_trimmed" ]; then
        SKILLS_ARGS+=("-a" "$agent_trimmed")
      fi
    done
    IFS="$OLD_IFS"
  else
    info "Installing every skill into every detected agent (Cursor, Claude Code, Codex, ...)."
    SKILLS_ARGS=("add" "liberfi-io/liberfi-skills" "--all")
  fi

  info "Running: npx -y skills ${SKILLS_ARGS[*]}"
  if npx -y skills "${SKILLS_ARGS[@]}"; then
    ok "Skills installed."
  else
    fail "skills CLI exited with a non-zero status."
    info "You can retry manually:"
    info "  npx -y skills ${SKILLS_ARGS[*]}"
    exit 3
  fi
fi

# ---------------------------------------------------------------------------
# 4. Verify connectivity
# ---------------------------------------------------------------------------
if [ -n "$LIBERFI_SKIP_PING" ]; then
  step "Skipping connectivity check (LIBERFI_SKIP_PING=1)"
else
  step "Verifying connectivity"
  if command -v lfi >/dev/null 2>&1; then
    if lfi ping --json >/tmp/liberfi-ping.json 2>/tmp/liberfi-ping.err; then
      ok "API reachable: $(cat /tmp/liberfi-ping.json | head -c 200)"
    else
      warn "lfi ping failed — the install itself succeeded, but the API is"
      warn "unreachable from this network. Check your connectivity / VPN."
      warn "Details: $(head -n 3 /tmp/liberfi-ping.err 2>/dev/null || true)"
    fi
  else
    warn "lfi command not on PATH yet. Open a new shell and run \`lfi ping --json\`."
  fi
fi

# ---------------------------------------------------------------------------
# 5. Next steps
# ---------------------------------------------------------------------------
hr
printf "${C_GREEN}${C_BOLD}LiberFi is ready.${C_RESET}\n\n"
printf "Next steps:\n"
printf "  ${C_CYAN}1.${C_RESET} Authenticate (agent / headless):  ${C_BOLD}lfi login key --json${C_RESET}\n"
printf "     Or via email OTP (humans):       ${C_BOLD}lfi login your@email.com --json${C_RESET}\n"
printf "  ${C_CYAN}2.${C_RESET} Confirm wallet:                    ${C_BOLD}lfi whoami --json${C_RESET}\n"
printf "  ${C_CYAN}3.${C_RESET} Try a query (in your AI agent):    ${C_BOLD}\"Show me trending tokens on Solana\"${C_RESET}\n"
printf "\n"
printf "Docs: ${C_DIM}https://github.com/liberfi-io/liberfi-skills${C_RESET}\n"
