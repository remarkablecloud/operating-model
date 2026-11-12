---
name: review-merge
description: Architect only. Use when a pull request has green CI and a close-out, to review it, merge it and close the card.
---
# Review and merge

Merge only when all of these hold: CI is green on a head that contains current main; the close-out is complete (skill `close-out` gives its shape); your review below passes. Anything else goes back to the Coder as a comment on the pull request with the exact item.

## The review

1. **The brief:** every item is done as the brief defined "done"; items marked code-complete rather than exercised are acceptable only where the brief allowed it.
2. **The diff:** it does what the card says and nothing else; no file that belonged to another Coder; tests cover the behavior; no test skipped or loosened to pass.
3. **Secrets:** none in the diff, the logs, the fixtures or the comments.
4. **Rows:** the Coder's "as built" rows in `docs/DECISIONS.md` are true to the diff; `docs/FOR_NOW.md` has a row wherever the code holds a "for now" or a number the design named.
5. **Memory rows:** each is true, verified by the Coder, has its source, is not a duplicate, and holds no secret, personal data or text lifted from untrusted content. Fix the wording, or drop the row and say why.
6. **Copy:** any text a customer reads follows the copy rules in `CLAUDE.md`. If the text itself is new, it is the founder's: ask (skill `ask-decision`).
7. **Founder-gated:** if the change is on the founder-gated list, it is asked before it ships.
8. **Questions:** any question the Coder asked on the card is answered.

## The merge

1. Squash-merge with "fixes #<card>" so the board moves the card to Done. Never move a card to Done by hand.
2. Confirm the card went Done; set Actual from the close-out.
3. Turn the close-out's open items into cards, and its founder's steps into a Needs Attention card.
4. Add any new memory file to `docs/memory/INDEX.md`.
5. Archive the Coder's workspace and prune its branch.

A refusal of the merge is reported on the card and in the chat, never worked around. Never edit a running Coder's worktree.
