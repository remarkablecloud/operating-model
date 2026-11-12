# Lessons: why each rule exists

Every rule in `OPERATING-MODEL.md` came from something that went wrong, or nearly did, in a real project run this way. A rule kept without its reason gets dropped the first time it is inconvenient; this page keeps the reasons. When a project's retro changes a rule here, it adds the reason.

## Decisions

- **Every decision says who and why.** Decisions recorded as conclusions only could not be revisited: nobody knew which facts had decided them, so nobody knew when they stopped holding.
- **Pending and taken decisions in two files, one numbering.** Founder decisions were buried in chat and in comments; the founder could not see at a glance what was waiting.
- **Every pending decision has a card in Needs Attention, and the card links the documents.** A decision written only in the pending file and the chat was missed; a draft on a bare branch was hard to read. Rendered documents linked from the card are read; diffs and branches are not.
- **The architect answers questions its Coders ask, before giving the next go.** A Coder asked an (A)/(B) question mid-task; the architect gave the next go without answering it, and the pull request came back with the expensive option. Caught at review, but only just.
- **A question to the founder stays the last thing in the chat.** About five times in two days a question was pushed out of sight by an agent's next message and went unanswered. Agents write on cards while a question is open, and every question carries the line the founder can type to answer it later.
- **Say "template" when showing a template.** A template for an alert mail, shown without saying it was a template, read as a real alert and alarmed the founder.

## Work and review

- **One CI run per change.** A month's CI minutes were spent in six days, every change running CI twice.
- **A merge queue beats merging main by hand.** "Merge main before the last push" still left a gap between the tested head and the main it landed on, and cost a rebase round whenever two pull requests were ready together. The queue tests every merge on the main it lands on.
- **Test suites by exit code and failing test names, never the tail of a log.** A truncated log hid three failing integration tests behind a release candidate.
- **Lint runs next to the test suites before every push.** Fifteen release candidates were tagged while lint was red.
- **Coders write their own "as built" rows.** The architect committing rows on a Coder's branch cost a round trip per card, and twice a Coder's pull reverted the architect's commit.
- **Pre-assign migration and other shared sequence numbers in the brief.** Two Coders picked the same number three times.
- **Never edit a running Coder's worktree.** An edit landed in the middle of a Coder's merge.
- **Briefs pass a checklist.** Two briefs in one day had a wrong CI rule and a wrong integration gate.
- **Refusals are reported, never worked around.** A step quietly skipped after a refusal cost a report its production data.
- **Never end a turn while waiting.** A Coder ended its turn while a background command was still running; nothing woke it, and the card sat In progress until a heartbeat found it.
- **Briefs are written ahead.** Coder slots sat idle while the architect wrote the next brief.
- **Read the clock, never guess the time in a comment.** Guessed timestamps on issues had to be corrected by hand.

## Scale and parallelism

- **Coders in parallel only after the test suites are isolated.** Suites shared state across worktrees (a message channel, database numbers, fixed test accounts, scratch databases), so two Coders failed each other's tests. Fix the isolation, prove it by running two full suites at once, and find the real limit: it was memory, not CPU.
- **Pace bulk board edits.** Writing hundreds of fields at once tripped GitHub's rate limit for minutes; the planner writes only the fields that change, with a pause between writes.

## Guardrails

- **A guard rule matches what it must, and nothing more.** A rule refusing the release script by name also refused pushing a branch named after it; rules match running a command, not naming it, and are tested on both.
- **A guard's false positive is fixed by renaming, not by loosening.** A package whose name contained "secret" hit the rule protecting secret files; the package was renamed and the rule kept.
- **Development drifts from production, and not only its keys.** A development key lacked a permission production's has, so a live smoke failed there for a reason production does not have. Later development's catalog was more than a hundred entries behind production's, and a check run there quietly tested less than it claimed. Development's release and reference data are synced after every train.
- **Production keys never reach a Coder, and Coders run as a user that cannot reach production.** A guard that reads command text is a tripwire, not a wall.
- **Agents never share the founder's login.** While they did, a founder answer could only be told apart by the absence of an agent's header, so one forgotten header would have spoken with the founder's voice.

## Planning

- **Estimates are calibrated on actuals.** Early briefs ran two to three times high; the plan uses the calibrated numbers and the morning report keeps the running comparison.
- **A backlog listed by a machine is not a list of things to build.** Of 100 items a discovery job had listed months earlier, more than half were no longer real when checked; check what is still true before promising numbers.

## Rhythm

- **There is a mode between running and stopped.** A full pause was the only brake. "Finish what is running, report, and wait" turned out to be what the founder wanted most of the time, so it became the `hold` label.

## Learning

- **Project knowledge does not live in one agent's private memory.** The architect's own memory had filled with things Coders needed and could not read. Private memory is for an agent's own procedures; the rest goes in `docs/memory/`.

- **What a Coder learns goes into memory before its workspace is archived.** Coders are single-card and start from nothing; without a "Learned" line in the close-out, the next Coder met the same surprise.
- **Rules live in one place and are copied, not pasted.** Rules pasted into each project's instruction file drifted from their source and made every Coder load rules meant for the architect.
