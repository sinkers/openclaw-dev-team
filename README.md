# openclaw-dev-team

A four-agent OpenClaw development team — pre-configured, ready to deploy. Clone, run setup, configure, and you have a coordinated team covering product, architecture, DevOps, and system administration.

## What You Get

| Agent | Role | Emoji | Model |
|-------|------|-------|-------|
| **Claw** | System Administrator | 🛡️ | Claude Opus |
| **Scout** | Product Manager / PMM | 🔍 | Claude Sonnet |
| **Arch** | Development Manager / Tech Lead | 🏗️ | Claude Opus |
| **Forge** | DevOps Engineer | ⚙️ | Claude Sonnet |

Each agent has its own workspace, persona, memory, and operating rules. They're designed to work together as a coherent team — Scout hands roadmaps to Arch, Arch directs Forge, Claw watches over all of them.

## Prerequisites

- [OpenClaw](https://openclaw.dev) installed and configured
- An Anthropic API key (for Claude Opus and Sonnet)
- `bash` 4.0+
- `git`

## Quick Start

```bash
# 1. Clone
git clone https://github.com/sinkers/openclaw-dev-team.git
cd openclaw-dev-team

# 2. Run setup
chmod +x setup.sh
./setup.sh --project-name myproject

# 3. Configure
cp config/openclaw.json.template config/openclaw.json
# Edit config/openclaw.json — fill in API keys, project name, channel IDs

# 4. Register agents with OpenClaw
# Merge/reference config/openclaw.json entries into your OpenClaw config

# 5. Start your agents
# Each agent's workspace is now at ~/.openclaw/workspace-<agent>/
```

## Team Structure

```
User / Product Owner
  └── Scout 🔍  (product direction, roadmaps, research)
  └── Arch 🏗️   (technical decisions, agent orchestration)
        └── Forge ⚙️  (CI/CD, infra, deployment)
  └── Claw 🛡️   (health monitoring, incident escalation — watches everything)
```

Full details: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

## Agent Files

Each agent's directory under `agents/` contains:

- **SOUL.md** — behavioural rules, tone, decision-making principles
- **IDENTITY.md** — name, role, emoji, model
- **AGENTS.md** — startup sequence and workflow rules
- **MEMORY.md** — template for long-term context (fill in your project details)
- **HEARTBEAT.md** — (Claw only) recurring job schedule

## Customising

1. Edit `MEMORY.md` files — fill in `<project name>`, `<user name>`, team roster
2. Edit `SOUL.md` files — adjust tone or responsibilities to fit your team
3. Update `config/openclaw.json.template` — add your channels and model preferences

## Workflow Standards (all agents)

- **Branching:** `feature/*` and `bug/*` off `main`. PRs before merging. No Git Flow.
- **PRs:** ALL review comments addressed before merge — not just critical ones
- **Testing:** Coverage must not decrease. Bug fixes require regression tests.
