#!/usr/bin/env python3
"""Start and Target dates for every card that can be dated.

The build order is Priority, then the smaller estimate first. A card starts
after the cards that block it, on the first Coder lane that is free. A card
that depends on another cannot end before it.

usage: plan.py [--apply] [--cards FILE] [--start YYYY-MM-DD]
  --apply   write Start date and Target date on the board (only what changed)
Reads cards.json (fetch_cards.py), writes plan.json next to it.
"""
import argparse, datetime as dt, json, os, re, sys, time
from collections import Counter

PRIORITY = {"Urgent": 0, "High": 1, "Medium": 2, None: 3, "Low": 4}
REF = re.compile(r"(?:([\w.-]+/[\w.-]+)|([\w.-]+))?#(\d+)")


def dependencies(card, default_owner):
    """(blocked_by, depends_on, blocked_outside) from the 'Blocked by:' and 'Depends on:' lines of the body."""
    out = {"blocked by": [], "depends on": []}
    outside = False
    for line in (card.get("body") or "").splitlines():
        m = re.match(r"\s*[-*]?\s*\**\s*(blocked by|depends on)\s*\**\s*:\s*\**(.*)", line, re.I)
        if not m:
            continue
        label, text = m.group(1).lower(), m.group(2)
        for full, repo, n in REF.findall(text):
            # a bare #12 is a card of the same repository as this card
            r = full or (f"{default_owner}/{repo}" if repo else card["repo"])
            out[label].append(f"{r}#{n}")
        rest = REF.sub("", re.sub(r"\(.*?\)", "", text))
        rest = re.sub(r"\b(none|and|or)\b", "", rest, flags=re.I)
        if label == "blocked by" and re.search(r"[A-Za-z]{4,}", rest):
            outside = True  # blocked by something that is not a card
    return out["blocked by"], out["depends on"], outside


def make_plan(cards_list, lanes, hours_per_day, start, default_owner=""):
    cards = {f"{c['repo']}#{c['number']}": c for c in cards_list}
    info = {k: dependencies(c, default_owner) for k, c in cards.items()}
    dated, waiting = [], []
    for k, c in cards.items():
        why = None
        if c.get("status") == "Needs Attention":
            why = "needs the founder"
        elif c.get("status") in ("In review", "Done"):
            why = "already in review"
        elif info[k][2]:
            why = "blocked outside the board"
        elif not c.get("estimate"):
            why = "no estimate"
        (waiting.append((k, why)) if why else dated.append(k))
    changed = True
    while changed:  # a card blocked by a waiting card waits too
        changed = False
        for k in list(dated):
            if any(b in cards and b not in dated for b in info[k][0]):
                dated.remove(k); waiting.append((k, "after a waiting card")); changed = True
    order = sorted(dated, key=lambda k: (PRIORITY.get(cards[k].get("priority"), 3), float(cards[k]["estimate"])))
    end, free, plan, pending = {}, [0.0] * lanes, [], list(order)
    while pending:
        k = next((p for p in pending if not any(b in pending and b != p for b in info[p][0])), None)
        if k is None:  # a cycle of Blocked by: say so and break it at the top card
            k = pending[0]
            print(f"warning: dependency cycle at {k}", file=sys.stderr)
        pending.remove(k)
        days = float(cards[k]["estimate"]) / hours_per_day
        ready = max([end[b] for b in info[k][0] if b in end] + [0.0])
        lane = min(range(lanes), key=lambda j: max(free[j], ready))
        s = max(free[lane], ready)
        free[lane] = s + days
        end[k] = max([s + days] + [end[d] for d in info[k][1] if d in end])
        sd = start + dt.timedelta(days=int(s))
        ed = start + dt.timedelta(days=max(int(s), int(end[k] - 1e-9)))
        plan.append((k, str(sd), str(ed)))
    return plan, waiting


def apply(plan, cards_list, cfg):
    from _board import gh, project_id
    pid = project_id(cfg)
    fields = json.loads(gh("project", "field-list", str(cfg["project_number"]), "--owner", cfg["owner"],
                           "--format", "json", "--limit", "50"))["fields"]
    fid = {f["name"]: f["id"] for f in fields}
    for name in ("Start date", "Target date"):
        if name not in fid:
            sys.exit(f"the board has no '{name}' field")
    cards = {f"{c['repo']}#{c['number']}": c for c in cards_list}
    written = 0
    for k, s, e in plan:
        c = cards[k]
        for name, new, old in (("Start date", s, c.get("start")), ("Target date", e, c.get("target"))):
            if new == old:
                continue
            gh("project", "item-edit", "--project-id", pid, "--id", c["item"], "--field-id", fid[name], "--date", new)
            written += 1
            time.sleep(0.4)  # bulk edits trip GitHub's rate limit
    print(f"applied: {written} fields written")


def main():
    from _board import config, work_dir
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--cards")
    ap.add_argument("--start")
    a = ap.parse_args()
    cfg = config()
    path = a.cards or os.path.join(work_dir(), "cards.json")
    cards_list = json.load(open(path))
    start = dt.date.fromisoformat(a.start) if a.start else dt.date.today() + dt.timedelta(days=1)
    plan, waiting = make_plan(cards_list, int(cfg.get("lanes", 2)), float(cfg.get("hours_per_day", 6)),
                              start, cfg.get("owner", ""))
    json.dump({"plan": plan, "waiting": waiting}, open(os.path.join(os.path.dirname(path), "plan.json"), "w"))
    cards = {f"{c['repo']}#{c['number']}": c for c in cards_list}
    hours = sum(float(cards[k]["estimate"]) for k, _, _ in plan)
    last = max((e for _, _, e in plan), default="none")
    print(f"dated {len(plan)}, waiting {len(waiting)}; last target {last}; {hours:.0f} session hours")
    print("waiting:", dict(Counter(w for _, w in waiting)))
    if a.apply:
        apply(plan, cards_list, cfg)


if __name__ == "__main__":
    main()
