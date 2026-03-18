# HEARTBEAT.md — Claw's Recurring Jobs

This defines all of Claw's scheduled jobs, their cadence, and what to do when they run.

---

## Schedule

| Job | Cadence | Priority |
|-----|---------|----------|
| Agent health sweep | Every 10 minutes | High |
| Connection health check | Every 30 minutes | High |
| Context window check | Each sweep (per session) | Medium |
| Sub-agent orphan scan | Each sweep | High |
| Token usage summary | Daily (end of day) | Low |
| Stale session cleanup | Daily (start of day) | Low |

---

## Job Definitions

### 🔁 Agent Health Sweep — every 10 min

**Purpose:** Catch stalled, looping, or unresponsive agents early.

**Steps:**
1. For each active agent in MEMORY.md:
   - Check last known output timestamp
   - Assess: alive / active / stalled / loop
   - Check for sub-agents spawned but not acknowledged
   - Verify reported status matches observable behaviour
2. Log a one-liner per agent: `[HH:MM] Scout: active, last output 3m ago`
3. Take action on anything anomalous (see SOUL.md escalation rules)

**Output:** Log entry in `memory/YYYY-MM-DD.md`. Escalation message if needed.

---

### 🔌 Connection Health Check — every 30 min

**Purpose:** Verify the plumbing is working before it causes a cascade.

**Steps:**
1. Check OpenClaw gateway responsiveness
2. Check API endpoint reachability for each active agent's model provider
3. Log result: `[HH:MM] Connectivity: OK` or specific failure details

**Escalation trigger:** Same failure on two consecutive checks (60-minute window).

**Output:** Log entry. Escalation if persistent failure.

---

### 📐 Context Window Check — each sweep, per session

**Purpose:** Prevent context exhaustion mid-task.

**Steps:**
1. Estimate or retrieve context usage for each active session
2. Apply thresholds:
   - 70%: note in sweep log
   - 85%: warn the agent, flag for user (low urgency)
   - 95%: immediate escalation — context loss mid-task is a data risk

**Output:** Log entry. Warning/escalation at threshold.

---

### 👻 Sub-agent Orphan Scan — each sweep

**Purpose:** Detect sub-agents that completed without their parent acknowledging results.

**Steps:**
1. Review sub-agent tracking in MEMORY.md
2. For each sub-agent: completed? parent acknowledged?
3. If completed but unacknowledged:
   - Is parent alive and responsive?
   - If yes: relay the result to the parent
   - If no: resolve parent stall first, then relay
4. Mark as resolved in MEMORY.md once parent acknowledges

**Output:** Log entry. Resolution action taken. Escalation if parent resolution fails.

---

### 📊 Token Usage Summary — daily (end of day, ~23:00 local)

**Purpose:** One daily summary, not a constant stream of usage data.

**Steps:**
1. Compile token usage per agent for the day
2. Flag any agent with anomalous usage (>2x typical, or signs of a loop)
3. Send a single summary message to the user

**Format:**
```
🛡️ Daily token summary — [date]
Scout: ~42k tokens
Arch: ~115k tokens
Forge: ~28k tokens
Anomaly: None / [Agent]: [note]
```

**Output:** One user message.

---

### 🧹 Stale Session Cleanup — daily (start of day, ~06:00 local)

**Purpose:** Don't accumulate zombie sessions.

**Steps:**
1. List all sessions with no activity in the last 24 hours
2. Verify each is genuinely inactive (not a long-running silent task)
3. Terminate inactive sessions gracefully
4. Log what was cleaned up

**Do not terminate:**
- Sessions with confirmed in-progress tasks
- Sessions flagged as intentionally long-running

**Output:** Log entry. User notification only if something unexpected was found.

---

## Missed Jobs

If Claw was offline and a scheduled job was missed:
1. On restart, note which jobs were missed in the startup log
2. Run the agent health sweep and sub-agent orphan scan immediately — these are time-sensitive
3. Run the connection health check within the first cycle
4. Daily jobs can wait for their next scheduled window, unless the day's already ended
