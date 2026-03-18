# TOOLS.md — Required Tools

This document lists all tools required to run the OpenClaw development team. Set these up before assigning any development work.

---

## Core (always required)

### OpenClaw
The agent platform. All agent communication, routing, scheduling, and session management.
- Install: `npm install -g openclaw@latest`
- Docs: https://docs.openclaw.ai

### Claude (Anthropic)
Primary LLM for all agents.
- API key required: https://console.anthropic.com
- Set in `openclaw.json` under `auth.profiles`
- Recommended: Opus for Arch and Claw, Sonnet for Scout and Forge

### GitHub
Source control, project board, CI/CD, branch protection.
- `gh` CLI required: https://cli.github.com
- Authenticate: `gh auth login --scopes "repo,project"`
- All repositories must have branch protection on `main` before development begins

### Codex
AI code review tool. **All developer agents must run Codex review before opening a PR.**
- Install: `npm install -g @openai/codex` (or per OpenAI's current install instructions)
- Authenticate: requires OpenAI API key set as `OPENAI_API_KEY` environment variable
- Usage:
  ```bash
  codex "Review the changes I've made in this branch for bugs, edge cases, and code quality."
  ```
- Agents should run this in the project root with the relevant branch checked out
- Codex runs locally — it can see all files in the repo

---

## Cross-Model Code Review

PRs are reviewed by a different model to the one that wrote the code. The second model provides an independent review before merge.

| Default reviewer | How |
|---|---|
| Gemini | Via OpenClaw Gemini integration or direct API |
| Claude | For PRs written by non-Claude agents |

Configure your review model in `openclaw.json` or via the OpenClaw coding-agent skill.

---

## Development Tools (project-specific)

These are set up per project type. Arch selects and documents the relevant preset when initialising a new project.

See `presets/` for per-project-type setup scripts:
- `presets/flutter.sh` — Flutter/Dart mobile apps (iOS + Android)
- `presets/web.sh` — Web frontend (Node.js)
- `presets/backend.sh` — Backend/API services
- `presets/python.sh` — Python projects

---

## Deployment (project-specific)

| Target | Tool |
|---|---|
| iOS | TestFlight → App Store |
| Android | Google Play Console |
| Web | Vercel / Fly.io / Railway (GitHub Actions deploy) |
| Backend | Docker → VPS or Railway |
| Self-hosted / remote access | Tailscale (see sinkers/openclaw-network-setup) |

---

## Remote Access

To query your OpenClaw instance remotely (phone, terminal, ClawTalk):
- See: https://github.com/sinkers/openclaw-network-setup
- Recommended: Tailscale (private mesh VPN, no open ports)
- Agent status endpoint (once agent-status plugin installed): `GET /v1/agents/status`
