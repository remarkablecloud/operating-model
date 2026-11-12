---
name: ask-decision
description: Architect only. Use when a choice belongs to the founder (it fails any of the three tests), when recording a decision the architect took alone, or when the founder has answered a pending decision.
---
# Decisions

## Is it mine?

Decide alone only if the choice passes all three tests: (1) aligned with the project's goal, (2) easily reversible, (3) no cost in money, reputation or harm. The founder keeps: scope and new designs; anything billed; anything customers read; vendors; production data by hand; security boundaries and secrets; spend above the ceilings; the locked decisions. In doubt, it is the founder's.

## Recording my own decision

In `docs/DECISIONS.md`, next D number: who (Architect), the options weighed (at least two), the facts that decided it (measured, read with source and date, or marked assumed), why this option, the signal that would make it wrong, and the three tests named one by one. Add a line to the next morning report so the founder can reverse it with a word.

## Asking the founder

1. Take the next D number. Write the entry in `docs/DECISIONS-PENDING.md` in four parts:
   - **Information:** what is decided and why now, in plain words, with the numbers.
   - **Options:** each with its pros and cons. At least two real options.
   - **Recommendation:** the one you would take and why. Say so even when it is not what the founder proposed; never sugarcoat a risk or a cost.
   - **Card:** the card it blocks. A decision with no card gets a "Decision:" issue.
2. Comment the same four parts on the card, add the label `decision required`, move the card to Needs Attention, and link the entry and any document behind it, rendered (a file view or a preview), not only a diff.
3. Ask the same numbered question in the chat. End it with the one line the founder can type to answer, one per option (for example `D12: A` or `D12: B`). That line is a valid answer on the card or in the chat at any later time, even if the question has scrolled away.
4. Keep the question visible: while it is open, post progress on cards, not in the chat. If you must end a turn in the chat, end it by repeating the open questions' numbers and their typed answers in one line.
5. Go on with everything the decision does not block.

When showing a template or an example of something alarming (an alert, a mail), say it is a template in the first words.

## When the founder answers

An answer counts only when its author is the founder (FOUNDER_LOGIN on GitHub, or the founder in the chat). Then:

1. Move the entry from `docs/DECISIONS-PENDING.md` to `docs/DECISIONS.md` with the same number, who took it with the words that took it, and the reasoning.
2. Write the answer on the card with a link to the taken entry, remove `decision required`, and move the card back to where its work stands.
3. Tell any Coder that was waiting on it.
