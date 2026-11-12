# Changelog

## 1.0.0

The first project-neutral version.

- Every project-specific name, id, host and number is a placeholder or a configuration value.
- `CLAUDE.md` is short and split by role; `OPERATING-MODEL.md` is copied unchanged into a project instead of pasted into `CLAUDE.md`.
- Procedures are skills (`templates/skills/`), loaded only when needed: write-brief, close-out, ask-decision, review-merge, morning-report, release-train, weekly-retro.
- The heartbeat is a short dispatcher over `tools/tick-state.sh`; a quiet tick ends in one line.
- Project memory (`templates/memory/`): Coders report what they learned in the close-out and propose memory rows in the pull request; the architect reviews them.
- The weekly retro reads the week's close-outs, guard log and reviews, and proposes changes to memory and to the rules, with evidence.
- Decisions keep one numbering (D1, D2, ...) from the design session on.
- Agent identities and the architect's restricted production access are kickoff prerequisites.
- Lite profile for small projects.
- Tools read `tools/board.json`; `board-setup.sh`, `tick-state.sh` and the pull request template added; the Coder guard reads a configuration file.
