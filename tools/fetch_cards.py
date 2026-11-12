#!/usr/bin/env python3
"""Every open card on the board with its fields and body, written to cards.json.

usage: fetch_cards.py            (reads tools/board.json, writes tools/.work/cards.json)
"""
import json, os
from collections import Counter
from _board import config, gh, project_id, work_dir

Q = """query($id:ID!,$c:String){ node(id:$id){ ... on ProjectV2 { items(first:100, after:$c){
  pageInfo{ hasNextPage endCursor }
  nodes{ id
    fieldValues(first:30){ nodes{
      ... on ProjectV2ItemFieldSingleSelectValue{ name field{ ... on ProjectV2FieldCommon{ name } } }
      ... on ProjectV2ItemFieldNumberValue{ number field{ ... on ProjectV2FieldCommon{ name } } }
      ... on ProjectV2ItemFieldTextValue{ text field{ ... on ProjectV2FieldCommon{ name } } }
      ... on ProjectV2ItemFieldDateValue{ date field{ ... on ProjectV2FieldCommon{ name } } } } }
    content{ ... on Issue{ number title body state repository{ nameWithOwner } } } } } } } }"""


def main():
    cfg = config()
    pid = project_id(cfg)
    out, cur = [], None
    while True:
        args = ["api", "graphql", "-f", f"query={Q}", "-f", f"id={pid}"] + (["-f", f"c={cur}"] if cur else [])
        d = json.loads(gh(*args))["data"]["node"]["items"]
        for n in d["nodes"]:
            c = n.get("content") or {}
            if not c or c.get("state") != "OPEN":
                continue
            f = {}
            for v in n["fieldValues"]["nodes"]:
                name = ((v or {}).get("field") or {}).get("name")
                if name:
                    f[name] = next((v[k] for k in ("name", "number", "text", "date") if k in v), None)
            out.append({"item": n["id"], "repo": c["repository"]["nameWithOwner"], "number": c["number"],
                        "title": c["title"], "body": c["body"], "status": f.get("Status"),
                        "estimate": f.get("Estimate"), "priority": f.get("Priority"),
                        "start": f.get("Start date"), "target": f.get("Target date")})
        if not d["pageInfo"]["hasNextPage"]:
            break
        cur = d["pageInfo"]["endCursor"]
    path = os.path.join(work_dir(), "cards.json")
    json.dump(out, open(path, "w"))
    print(len(out), "open cards", dict(Counter(x["status"] for x in out)), "->", path)


if __name__ == "__main__":
    main()
