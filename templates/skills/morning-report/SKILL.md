---
name: morning-report
description: Architect only. Use on the first heartbeat of the day when the tick state says the morning report is due, to re-plan the board and write, post and mail the report.
---
# The morning report

Once a day, on the first tick at or after the report hour in the founder's time zone for which the pinned "Morning report" issue has no report dated today. A missed tick is caught up by the next; a second tick never sends a second report.

## 1. Re-plan

Set Estimate on every new or changed card. Then `python3 tools/fetch_cards.py && python3 tools/plan.py --apply` writes Start and Target for every Backlog and Ready card from the build order, the estimates, the dependencies and the Coders that can run. It writes only what changed.

## 2. Write it, in four parts

- **What I did since the last report:** merges, deploys, decisions taken (with D numbers, and for my own, one line each so the founder can reverse them), each with its card.
- **Where we stand:** Coders running and their cards; the Needs Attention cards, oldest first; production status; spend against the ceilings; model cost per Coder session; CI minutes against the allowance; anything that broke.
- **How far the goal is:** the current milestone's cards done out of the total, its blockers, the hours left at the Estimate fields; estimate against actual so far; the measures (pull requests sent back, refusals, Coders stuck twice).
- **The plan for the day:** what starts, what ships on each train, what waits on the founder.

Numbers are read, not remembered: from the board, the CI, the billing pages, the clock.

## 3. The Gantt

`python3 tools/gantt.py gantt.png gantt.md` draws the plan as an image and as a Mermaid block.

## 4. Post and mail

1. Post the text with the Mermaid block as a comment on the pinned "Morning report" issue, headed "Morning report, <date>".
2. Mail it as HTML with the image inline to the founder, subject "{{PROJECT}} morning report, <date>".
3. If the mail fails, say so in one line on the issue and in the chat; the posted report stands.

Lite profile: skip the re-plan, the Gantt and the mail unless the project uses them; post a short note only on days with activity.
