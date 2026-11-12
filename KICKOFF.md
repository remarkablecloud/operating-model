# Kickoff: the architect's first task

When the founder says "go" on a design package (`design/DESIGN-PACKAGE.md` filled), the architect agent turns it into a project in motion. Order matters: each step uses the one before.

## Before the first step (the founder's, once per project)

- **The profile:** Full or Lite (`OPERATING-MODEL.md`, "Profiles").
- **Identities:** a GitHub App or bot account for the agents, so nothing an agent posts carries the founder's login.
- **The Coder's user:** a Unix user on the build machine with no production keys, with the guard installed (`tools/coder-guard.sh` and its configuration).
- **The architect's production access** (when there is a production): a restricted deploy user that can run the release script and the read-only checks, nothing else.
- **The merge queue** on main, where the GitHub plan offers it, with CI set to run on the queue's merges (the `merge_group` event). Record yes or no as MERGE_QUEUE in `CLAUDE.md`.
- **The mail route** for the morning report (Full profile).

## The steps

1. **Read the package whole**, mockups, journey and decision log included. Anything unclear or contradictory becomes a question for the founder before step 5, not a guess.
2. **The repository:** create it (or use the one named), with:
   - `CLAUDE.md` from `templates/CLAUDE.md`, filled from the package (the locked decisions of section 8, conventions, security rules, the values table, the operating model's version);
   - `docs/OPERATING-MODEL.md`, copied unchanged;
   - `docs/DESIGN.md` (the package itself) and `docs/mockups/`;
   - `docs/DECISIONS.md`, `docs/DECISIONS-PENDING.md`, `docs/FOR_NOW.md`;
   - `docs/memory/` from `templates/memory/`;
   - `.claude/skills/` from `templates/skills/`;
   - `.github/` from `templates/github/`;
   - `tools/` from `tools/`.
3. **The decision log:** `docs/DECISIONS.md` seeded with the package's D1 to Dn, each keeping its number, who and the reasoning; `docs/DECISIONS-PENDING.md` with the open questions (section 13), each numbered on from Dn in four parts, with its card.
4. **The board:** `tools/board-setup.sh` (Status with Needs Attention first, Priority, Size, Estimate, Actual, Start date, Target date, Agent; the labels; the pinned issues "Morning report" and "Pause"; `tools/board.json`). It prints the few steps GitHub only allows by hand.
5. **The plan, from the goal backwards:** the milestones of section 4 (each a GitHub milestone with its acceptance), then the work as cards: one card is one session's work (a Coder, 1 to 6 hours); larger pieces are split, or get a design card first when their design is not settled. Every card has its acceptance, its dependencies (Blocked by, Depends on, the mirror Blocks, and GitHub's own links), its estimate, its priority and its milestone. Foundations first (repository skeleton, CI, environments, the data model, authentication, deploys), so later cards build on something running.
6. **The schedule:** Start and Target dates from the build order, the estimates, the dependencies and the Coders that can run (`tools/plan.py`), and the Gantt (`tools/gantt.py`).
7. **The founder's questions:** every open question and every step only the founder can take (accounts, keys, domains, vendor contracts) as a card in Needs Attention with its four parts or its exact steps.
8. **The first morning report:** the plan in four parts and the Gantt, mailed and posted on the pinned issue; the founder reads the whole plan once and answers what blocks.
9. **The first Coders:** briefs (skill `write-brief`) for the top cards nothing blocks, moved to Ready, Coders started within the limits.
10. **The rhythm:** the heartbeat (`paseo/heartbeat-prompt.txt`), the weekly retro (`paseo/retro-prompt.txt`), the release train once there is a production. From here the project runs under `docs/OPERATING-MODEL.md`.

**The kickoff is done** when the board holds the whole first release as cards with estimates and dependencies, the plan shows a target date for it, the founder's questions are in Needs Attention, and the first Coders are running.
