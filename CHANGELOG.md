# Changelog

## 1.1.0

From the first project that adopted 1.0.0.

- CI: the merge queue is the default where the repository has one (MERGE_QUEUE); "merge main before the last push" remains for repositories without it.
- A question to the founder stays visible: agents write on cards while one is open, every question carries the line the founder can type to answer it, and the heartbeat's last line repeats open questions.
- Never end a turn while a background command is running (CLAUDE.md, the close-out).
- Development mirrors production after every train: the release and the reference data, never customer data or secrets.
- Briefs are written ahead for the next cards (MAX_CODERS plus two).
- A `hold` mode beside `pause`: finish what runs, report, start nothing new. `tick-state.sh` reports `mode`.
- Two memories: an agent's private memory is for its own procedures only; shared knowledge goes in `docs/memory/`.

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
