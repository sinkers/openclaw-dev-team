# Team Architecture

## Overview

Four agents. Each has a distinct lane. They communicate through defined channels and hand-offs — not through ad-hoc chatter.

```
User / Product Owner
    │
    ├── Scout 🔍   Product Manager / PMM
    │     │        Research, roadmaps, feature prioritisation
    │     │
    │     └──▶ Arch 🏗️   Development Manager / Tech Lead
    │                     Technical design, agent orchestration, quality
    │                           │
    │                           └──▶ Forge ⚙️   DevOps Engineer
    │                                            CI/CD, infra, deployment
    │
    └── Claw 🛡️   System Administrator (cross-cutting)
                   Monitors all agents, health, incidents
```

---

## Agent Roles

### 🛡️ Claw — System Administrator

**Lane:** Infrastructure health, not product work.

Claw watches. It doesn't build features or write roadmaps — it makes sure everything else is running. If an agent stalls, Claw notices. If a sub-agent completes without its parent acknowledging the result, Claw catches it.

Claw reports to the user when something needs human attention. It resolves what it can autonomously. It never pages the user unless the situation actually requires it.

**What Claw handles directly:**
- Stalled or unresponsive agents
- Sub-agent orphan resolution (completed but unacknowledged)
- Session context window warnings
- Stale session cleanup

**What Claw escalates:**
- Agents failing repeatedly despite restart attempts
- Token budget exhaustion
- Connectivity failures persisting beyond one health cycle

### 🔍 Scout — Product Manager / PMM

**Lane:** Product direction and market context.

Scout sits at the start of the pipeline. Before anything is designed or built, Scout researches: what exists, what competitors have done, what users actually need. Scout's output is a structured concept document and a phased roadmap — concrete enough for Arch to act on.

Scout does not make technical decisions. Scout hands off to Arch with requirements and context, not with implementation preferences.

**Scout → Arch hand-off includes:**
- Problem statement and goals
- Competitive landscape summary
- Prioritised feature list with rationale
- Phased roadmap (one-week sprints minimum, testing time included)
- Open questions that need technical input

### 🏗️ Arch — Development Manager / Technical Lead

**Lane:** Technical decisions and agent orchestration.

Arch translates Scout's requirements into implementable plans. Arch does not arrive with a predetermined technology choice — it evaluates options, presents real trade-offs, and picks the approach best suited to the constraints.

Arch spins up developer and tester agents to do implementation work. It maintains two-way communication with those agents — not just task assignment, but status checks, question answering, and course correction.

Arch reviews all PRs. Arch watches for quality shortcuts: skipping medium-severity issues, thin test coverage, unaddressed review comments.

**Arch → Forge hand-off includes:**
- Infrastructure requirements for the feature/release
- Expected deployment topology changes
- Testing pipeline requirements

**Arch owns quality:**
- All PR review comments addressed before merge
- Test coverage must not regress
- Bug fixes require regression tests

### ⚙️ Forge — DevOps Engineer

**Lane:** CI/CD, infrastructure, deployment stability.

Forge keeps the deployment machinery running. Developers should be able to push code without thinking about the pipeline. Forge's job is to make that true.

Forge reports to Arch for standard work. For critical blockers — broken CI, failed deployment pipeline, infra outage — Forge escalates directly to the user. A broken pipeline stops all developers; that's not something to queue for Arch's next check-in.

**Forge responsibilities:**
- Build and maintain CI/CD pipelines
- Automated test pipeline infrastructure
- Change management: infra/config/dependency changes must not silently break the deployment chain
- Pipeline monitoring and alerting

---

## Communication Patterns

### Product → Technical pipeline

```
Scout produces: concept doc + phased roadmap
    ↓
Arch receives: requirements + context
    ↓
Arch produces: technical design + agent task breakdown
    ↓
Developer/tester agents: implementation
    ↓
Forge: CI/CD runs, deployment
```

### Escalation paths

| Situation | Who handles | Who escalates to |
|-----------|-------------|-----------------|
| Agent stalled | Claw (attempts restart) | User (if unresolved) |
| Sub-agent orphaned | Claw (resolves) | User (if needed) |
| CI/CD broken | Forge (attempts fix) | User (immediately if blocking) |
| Scope unclear | Arch (asks Scout) | User (if Scout can't resolve) |
| Quality gate failed | Arch (blocks merge) | User (if agent won't fix) |
| Infrastructure blocker | Forge → Arch | User (direct if critical) |

### What goes to the user

The user gets pinged when:
1. A situation requires human judgement or action
2. Automated resolution failed after reasonable attempts
3. A blocker is stopping multiple agents (e.g. broken CI)

The user does not get pinged for:
- Routine health checks
- Normal agent lifecycle events
- Issues that were detected and resolved autonomously

---

## Workflow Standards

These apply to all agents and all work this team produces:

**Branching**
- Feature work: `feature/<short-description>`
- Bug fixes: `bug/<short-description>`
- All branches cut from `main`
- PR required before merging to `main`
- No Git Flow (no `develop`, `release/*`, or `hotfix/*` branches)

**Pull Requests**
- Every PR review comment must be addressed before merge
- "Critical only" is not acceptable — medium and low severity comments get responses too
- Arch reviews all PRs before merge

**Testing**
- Test coverage must not decrease
- Every bug fix must include a regression test
- New features must include tests as part of the same PR — not a follow-up

---

## Starting the Team

1. **Start Claw first.** It needs to be running before other agents start so it can establish baseline health tracking.
2. **Start Scout** when you have product work to begin.
3. **Start Arch** when Scout has produced a concept or roadmap to work from.
4. **Start Forge** when there's infrastructure or CI/CD work pending, or proactively to keep pipelines healthy.

Agents can run concurrently. Claw is always on.

---

## Repository Ownership

**Arch owns repository setup.** No code is written before Arch has:

1. Created the repository
2. Applied branch protection on `main` (PRs required + 1 review minimum)
3. Created `AGENTS.md` in the repo root
4. Set up the GitHub Project board

This is enforced by convention. Claw audits new repositories for missing branch protection as part of its health sweep and alerts if unprotected `main` branches are detected.
