# Tools

Copied into a project's `tools/` at kickoff. They read `tools/board.json` (written by `board-setup.sh`; shape in `board.example.json`), need `gh` with the project scope, `jq`, `git` and Python 3 (`matplotlib` for the Gantt), and keep their working files in `tools/.work/` (not committed).

| Tool | What it does |
|---|---|
| `board-setup.sh` | Once, at kickoff: creates the board, its fields (Status with Needs Attention first, Priority, Size, Estimate, Actual, Start date, Target date, Agent), the labels and the pinned "Morning report" and "Pause" issues; writes `board.json`; prints the steps GitHub only allows by hand (workflows, the Roadmap view). |
| `tick-state.sh` | Every heartbeat: one small JSON with the mode (run, hold or pause), whether the morning report is due, the founder's cards and whether each was answered, Ready and running cards, pull requests with their checks, production, the release window, and `changed` (false when nothing moved since the last tick). |
| `status.sh` | Moves one card's Status. Refuses Done: the merge does that. |
| `fetch_cards.py` | Every open card with its fields and body, to `.work/cards.json`. |
| `plan.py` | Start and Target dates from Priority, the estimates, the dependencies and the Coders that can run (`lanes` and `hours_per_day` in `board.json`). `--apply` writes only the fields that changed, paced. |
| `gantt.py` | The plan as a PNG and a Mermaid block. |
| `coder-guard.sh` | The Coder guard, a Claude Code PreToolUse hook. Its rules are in `/etc/coder-guard.conf` (`coder-guard.conf.example`). Without a configuration it refuses everything. |
| `tests/` | `test_guard.sh` (every rule on what it must refuse and what it must let through) and `test_plan.py`. Run both after any change to the guard's configuration or the planner. |

## Notes

- **Dependencies** are read from the lines `Blocked by:` and `Depends on:` in a card's body (the issue forms put them there). `#12` is a card of the same repository; `other-repo#12` or `owner/other-repo#12` is a card elsewhere on the board. Words other than card numbers after `Blocked by:` mean "blocked by something outside the board", and the card is not dated.
- **All board fields are project fields**, written with `gh project item-edit`, so the tools work the same on an organization's board and on a user's.
- **The guard is a tripwire, not a wall.** The wall is the Coder's Unix user holding no production key. When a rule gives a false positive, rename the thing that tripped it; do not loosen the rule. Add a test for both sides of every new rule.
- **Status of these tools:** the planner, the Gantt and the guard are covered by the tests here. `board-setup.sh`, `tick-state.sh`, `status.sh` and `fetch_cards.py` talk to GitHub and have been exercised only against a stand-in for `gh`; run the first kickoff with a person watching, and fix here what GitHub answers differently.
