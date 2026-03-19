# AGENTS.md

This file defines the workflow rules for all developer agents working in this repository.
It is created by Arch when the repository is set up and applies to every agent without exception.

---

## Branch Workflow

- Branch off `main` for every feature or bug fix: `feature/issue-{N}-{description}` or `fix/issue-{N}-{description}`
- No direct pushes to `main` — all changes via pull request
- Keep PRs focused — one issue per PR
- PRs must be mergeable with no conflicts before requesting review

## Before Opening a PR

Complete all of the following before opening a pull request:

1. **Run Codex review on your changes**
   ```bash
   codex "Review the changes I've made in this branch. Check for bugs, edge cases, security issues, and code quality. Be specific about file and line number."
   ```
   Address any issues Codex flags before proceeding.

2. **Run the linter and static analysis** — zero issues required
   ```bash
   # Example for Flutter/Dart:
   flutter analyze
   # Example for TypeScript/JS:
   npx tsc --noEmit && npx eslint .
   ```

3. **Run the full test suite** — all tests must pass
   ```bash
   flutter test        # Flutter
   npm test            # Node/JS
   pytest              # Python
   ```

4. **Test coverage must not decrease** — check before and after your changes

5. **Format your code** — use the project formatter before committing
   ```bash
   dart format lib/ test/   # Flutter/Dart
   npx prettier --write .   # JS/TS
   ```

## Pull Request Standards

- **Title:** `[#N] Brief description` — e.g. `[#12] Fix login timeout on slow connections`
- **Body must include:**
  - What changed and why
  - How to test it
  - `Closes #N`
  - Checklist: linter ✅, tests ✅, Codex review ✅

## Code Review

PRs are reviewed by a different model to the one that wrote the code (cross-model review):

| Author | Reviewer |
|--------|----------|
| Claude (any) | Gemini |
| Gemini | Claude |
| Codex / GPT | Claude or Gemini |

**All review comments must be addressed before merge** — not just critical severity. Medium and low severity comments require a response. A comment can be declined with a clear reason, but it cannot be silently ignored.

## Testing Standards

- Every bug fix must include a regression test that would have caught the bug
- Every new feature must include tests covering the happy path and key edge cases
- Do not write tests that pass without actually asserting meaningful behaviour
- Test coverage must not decrease across the PR

## Codex Review (Required)

Run `codex review` on your branch before every PR. This is not optional.

Codex is a second set of eyes that catches issues before human review. Common things it finds:

- Logic bugs in edge cases
- Missing error handling
- Security issues (hardcoded values, unsafe input handling)
- Off-by-one errors
- Unnecessary complexity

If Codex flags something and you disagree, note your reasoning in the PR body — don't silently skip it.

## What Not to Do

- Do not open a PR with failing tests or linter warnings
- Do not push directly to `main`
- Do not merge your own PR
- Do not address only the critical review comments and ignore the rest
- Do not reduce test coverage without flagging it explicitly
- Do not skip the Codex review step

---

## Escalation

If you are stuck on the same problem for more than one iteration, stop and contact Arch. Do not continue looping. Arch will either unblock you, re-scope the task, or bring in outside help.

---

## Repository Scope

This agent is responsible for the following repositories:
- `<repo-1>` — <brief description>
- `<repo-2>` — <brief description>

If asked to work in a repository not on this list, check with Arch before proceeding.

**Note:** Developer agents are assigned no more than 2 repos as a rule, 3 at an absolute maximum and only if the third is small and infrequent. If this agent's scope needs to expand, Arch should assess whether a new agent is a better solution.
