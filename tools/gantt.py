#!/usr/bin/env python3
"""The plan as a Gantt: a PNG and a Mermaid block.

usage: gantt.py OUT.png OUT.md      (reads cards.json and plan.json from tools/.work)
"""
import datetime as dt, json, os, sys
from _board import config, short, work_dir

COLOR = {"Urgent": "#b91c1c", "High": "#dc2626", "Medium": "#2563eb", None: "#6b7280", "Low": "#9ca3af"}


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    cfg, w = config(), work_dir()
    plan = json.load(open(os.path.join(w, "plan.json")))["plan"]
    cards = {f"{c['repo']}#{c['number']}": c for c in json.load(open(os.path.join(w, "cards.json")))}
    rows = sorted(((k, dt.date.fromisoformat(s), dt.date.fromisoformat(e)) for k, s, e in plan), key=lambda r: (r[1], r[2]))
    if not rows:
        open(sys.argv[2], "w").write("No dated cards.\n"); print("no dated cards"); return
    hours = sum(float(cards[k]["estimate"]) for k, _, _ in rows)
    title = (f"{cfg.get('project', 'Project')} plan, {dt.date.today()}: {len(rows)} cards, {hours:.0f} session hours, "
             f"{cfg.get('lanes', 2)} Coders at {cfg.get('hours_per_day', 6)} h a day")

    import matplotlib; matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.dates as md
    fig, ax = plt.subplots(figsize=(12, max(4, 0.22 * len(rows) + 1.5)))
    for i, (k, s, e) in enumerate(rows):
        c = cards[k]
        ax.barh(i, (e - s).days + 1, left=md.date2num(s), color=COLOR.get(c.get("priority"), "#6b7280"),
                edgecolor="white", height=0.75)
        ax.text(md.date2num(s) - 0.15, i, f"{short(k, cfg)}  {c['title'][:58]}", ha="right", va="center", fontsize=6.5)
    ax.set_yticks([]); ax.invert_yaxis(); ax.xaxis_date()
    ax.xaxis.set_major_locator(md.AutoDateLocator()); ax.xaxis.set_major_formatter(md.DateFormatter("%b %d"))
    span = (max(r[2] for r in rows) - rows[0][1]).days + 1
    ax.set_xlim(md.date2num(rows[0][1]) - max(6, span * 0.6), md.date2num(max(r[2] for r in rows)) + 1.5)
    ax.grid(axis="x", alpha=0.3)
    ax.set_title(title + " (red Urgent and High, blue Medium, grey Low or unset)", fontsize=9)
    plt.tight_layout(); plt.savefig(sys.argv[1], dpi=110)

    out = ["```mermaid", "gantt", "  dateFormat YYYY-MM-DD", "  axisFormat %b %d"]
    for pr in ("Urgent", "High", "Medium", None, "Low"):
        rs = [r for r in rows if cards[r[0]].get("priority") == pr]
        if not rs:
            continue
        out.append(f"  section {pr or 'No priority'}")
        for k, s, e in rs:
            t = "".join(ch if ch not in ":#;," else " " for ch in cards[k]["title"][:48])
            out.append(f"  {short(k, cfg).replace('#', ' ').strip()} {t} :{s}, {(e - s).days + 1}d")
    out.append("```")
    open(sys.argv[2], "w").write("\n".join(out) + "\n")
    print("ok", len(rows))


if __name__ == "__main__":
    main()
