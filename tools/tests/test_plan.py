#!/usr/bin/env python3
"""Tests of the planner on a small made-up board.   python3 tools/tests/test_plan.py"""
import datetime as dt, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from plan import dependencies, make_plan


def card(repo, n, est, pr=None, status="Backlog", body=""):
    return {"repo": repo, "number": n, "estimate": est, "priority": pr, "status": status, "body": body, "title": f"card {n}", "item": f"I{n}"}


A, B = "acme/app", "acme/site"
cards = [
    card(A, 1, 6, "High"),
    card(A, 2, 6, "High", body="### Dependencies\n\nBlocked by: #1\nDepends on: none"),
    card(B, 1, 3, "Medium"),                                   # same number, other repository
    card(B, 2, 3, "Medium", body="Blocked by: #1"),            # the site's #1, not the app's
    card(B, 3, 2, "Low", body="**Blocked by:** app#2 (the API)\nDepends on: acme/site#2"),
    card(A, 4, 2, "Urgent", status="Needs Attention"),
    card(A, 5, 2, "High", body="Blocked by: #4"),              # waits behind the founder's card
    card(A, 6, 2, "High", body="Blocked by: the vendor contract"),
    card(A, 7, None, "High"),
]
by = {f"{c['repo']}#{c['number']}": c for c in cards}
assert dependencies(by[f"{B}#2"], "acme")[0] == [f"{B}#1"], "a bare #n is the card's own repository"
assert dependencies(by[f"{B}#3"], "acme") == ([f"{A}#2"], [f"{B}#2"], False)
assert dependencies(by[f"{A}#6"], "acme")[2] is True
assert dependencies(by[f"{A}#2"], "acme") == ([f"{A}#1"], [], False)

start = dt.date(2030, 1, 1)
plan, waiting = make_plan(cards, lanes=2, hours_per_day=6, start=start, default_owner="acme")
p = {k: (dt.date.fromisoformat(s), dt.date.fromisoformat(e)) for k, s, e in plan}
w = dict(waiting)
assert set(p) == {f"{A}#1", f"{A}#2", f"{B}#1", f"{B}#2", f"{B}#3"}, sorted(p)
assert w[f"{A}#4"] == "needs the founder" and w[f"{A}#5"] == "after a waiting card"
assert w[f"{A}#6"] == "blocked outside the board" and w[f"{A}#7"] == "no estimate"
assert p[f"{A}#1"][0] == start and p[f"{B}#1"][0] == start, "two lanes start together"
assert p[f"{A}#2"][0] > p[f"{A}#1"][1] or p[f"{A}#2"][0] >= start + dt.timedelta(days=1), "a blocked card starts after its blocker"
assert p[f"{B}#2"][0] >= p[f"{B}#1"][0]
assert p[f"{B}#3"][0] >= p[f"{A}#2"][1], "blocked across repositories"
assert p[f"{B}#3"][1] >= p[f"{B}#2"][1], "cannot end before what it depends on"
for k, (s, e) in p.items():
    assert e >= s, k
print("plan: all tests pass")
