#!/usr/bin/env bash
# tick-state.sh: everything a heartbeat needs to know, as one small JSON.
#
# The architect runs this first on every tick and acts on what it prints,
# instead of running a dozen commands and reading their full output. When
# "changed" is false and nothing is due, the tick ends in one line.
#
# Reads tools/board.json (or $OM_BOARD_CONFIG). Run from the repository, after
# git pull. Needs gh (with the project scope), jq and git.
#
# Output fields:
#   mode              "run", "hold" or "pause", from the labels on the pinned "Pause" issue
#   paused            true when mode is "pause" (nothing else is fetched)
#   report_due        no "Morning report" comment dated today (founder's time zone) and the report hour has come
#   needs_attention   the founder's cards, each with founder_answered (the last comment's author is the founder)
#   ready, in_progress, in_review, backlog_count
#   prs               open pull requests with checks green, pending or failing (and the failing names)
#   production        the status URL's HTTP code, when one is configured
#   train             window_open (a window opened this hour and no tag since), last_tag, commits_since_tag
#   changed           false when all of the above is identical to the previous tick
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
conf=${OM_BOARD_CONFIG:-$here/board.json}
[ -f "$conf" ] || { echo "tick-state.sh: no board configuration at $conf" >&2; exit 1; }
c() { jq -r "$1" "$conf"; }

owner=$(c .owner); project=$(c .project_number); default_repo=$(c .default_repo)
founder=$(c .founder_login); tz=$(c '.founder_timezone // "UTC"'); report_hour=$(c '.report_hour // 7')
pause_issue=$(c '.pause_issue // 0'); report_issue=$(c '.report_issue // 0'); status_url=$(c '.status_url // ""')

# Pause first: when paused, nothing else is fetched.
mode=run
if [ "$pause_issue" != 0 ]; then
	mode=$(gh issue view "$pause_issue" --repo "$default_repo" --json labels \
		--jq '[.labels[].name] as $l | if ($l | index("pause")) != null then "pause" elif ($l | index("hold")) != null then "hold" else "run" end')
fi
if [ "$mode" = pause ]; then
	jq -n '{mode: "pause", paused: true}'
	exit 0
fi

# The morning report: due when the hour has come and today has none.
today=$(TZ=$tz date +%F); hour=$((10#$(TZ=$tz date +%H)))
report_due=false
if [ "$report_issue" != 0 ] && [ "$hour" -ge "$report_hour" ]; then
	last=$(gh issue view "$report_issue" --repo "$default_repo" --json comments \
		--jq '[.comments[] | select(.body | startswith("Morning report")) | .createdAt] | last // ""')
	if [ -z "$last" ] || [ "$(TZ=$tz date -d "$last" +%F)" != "$today" ]; then report_due=true; fi
fi

# The board, without Done.
items=$(gh project item-list "$project" --owner "$owner" --limit 1000 --format json |
	jq '[.items[] | select(.status != "Done") | {n: .content.number, repo: .content.repository, title: .title, status: .status, priority: (.priority // null), agent: (.agent // null), labels: (.labels // [])}]')

# The founder's cards: answered when the last comment is the founder's.
needs='[]'
while IFS=$'\t' read -r n repo; do
	[ -n "$n" ] || continue
	lastc=$(gh issue view "$n" --repo "$repo" --json comments --jq '.comments | last | {author: (.author.login // ""), at: (.createdAt // "")}' 2>/dev/null || echo '{"author":"","at":""}')
	[ "$lastc" = null ] && lastc='{"author":"","at":""}'
	needs=$(jq --argjson n "$n" --arg repo "$repo" --argjson l "$lastc" --arg f "$founder" \
		'. + [{n: $n, repo: $repo, last_comment_by: $l.author, last_comment_at: $l.at, founder_answered: ($l.author == $f and $f != "")}]' <<<"$needs")
done < <(jq -r '.[] | select(.status == "Needs Attention" and .n != null) | [.n, .repo] | @tsv' <<<"$items")
needs=$(jq --argjson items "$items" '[.[] as $x | ($items[] | select(.n == $x.n and .repo == $x.repo)) as $i | $x + {title: $i.title, labels: $i.labels}]' <<<"$needs")

# Open pull requests and their checks, per repository.
prs='[]'
while read -r repo; do
	[ -n "$repo" ] || continue
	p=$(gh pr list --repo "$repo" --state open --json number,title,headRefName,statusCheckRollup | jq --arg repo "$repo" '
		[.[] | (.statusCheckRollup // []) as $c
		 | ([$c[] | select((.conclusion // .state // "") | IN("FAILURE","TIMED_OUT","CANCELLED","ACTION_REQUIRED","ERROR","STARTUP_FAILURE")) | (.name // .context)]) as $bad
		 | ([$c[] | select(((.status // "COMPLETED") != "COMPLETED") or ((.state // "") | IN("PENDING","EXPECTED")))] | length) as $wait
		 | {repo: $repo, number, title, branch: .headRefName,
		    checks: (if ($bad | length) > 0 then "failing" elif $wait > 0 then "pending" elif ($c | length) == 0 then "none" else "green" end),
		    failing: $bad}]')
	prs=$(jq --argjson p "$p" '. + $p' <<<"$prs")
done < <(c '.repos[]')

# Production, when a status URL is configured.
production=null
if [ -n "$status_url" ]; then
	code=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$status_url" || echo 000)
	production=$(jq -n --arg c "$code" '{http: ($c | tonumber)}')
fi

# The release train: a window is open during the hour it starts, until a tag is cut.
now=$(date -u +%s); utc_hour=$((10#$(date -u +%H)))
last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [ -n "$last_tag" ]; then
	tag_time=$(git log -1 --format=%ct "$last_tag")
	since=$(git rev-list --count "$last_tag"..HEAD)
else
	tag_time=0
	since=$(git rev-list --count HEAD 2>/dev/null || echo 0)
fi
window_open=false
while read -r w; do
	[ -n "$w" ] || continue
	wh=$((10#${w%%:*}))
	if [ "$utc_hour" -eq "$wh" ]; then
		opened=$(date -u -d "$(date -u +%F) $w" +%s)
		if [ "$now" -ge "$opened" ] && [ "$tag_time" -lt "$opened" ]; then window_open=true; fi
	fi
done < <(c '(.train_windows_utc // [])[]')

state=$(jq -n --argjson report_due "$report_due" --argjson items "$items" --argjson needs "$needs" --argjson prs "$prs" \
	--arg mode "$mode" --argjson production "$production" --argjson window_open "$window_open" --arg last_tag "$last_tag" --argjson since "$since" '
	{mode: $mode, paused: false, report_due: $report_due,
	 needs_attention: $needs,
	 ready: [$items[] | select(.status == "Ready") | {n, repo, title, priority}],
	 in_progress: [$items[] | select(.status == "In progress") | {n, repo, title, agent}],
	 in_review: [$items[] | select(.status == "In review") | {n, repo, title, agent}],
	 backlog_count: ([$items[] | select(.status == "Backlog")] | length),
	 prs: $prs, production: $production,
	 train: {window_open: $window_open, last_tag: $last_tag, commits_since_tag: $since}}')

# Changed since the previous tick?
dir=${OM_WORK_DIR:-$here/.work}; mkdir -p "$dir"
sum=$(jq -cS . <<<"$state" | sha256sum | cut -d' ' -f1)
changed=true
[ -f "$dir/tick.sha" ] && [ "$(cat "$dir/tick.sha")" = "$sum" ] && changed=false
echo "$sum" >"$dir/tick.sha"

jq --argjson changed "$changed" --arg now "$(TZ=$tz date '+%F %H:%M %Z')" '. + {changed: $changed, now: $now}' <<<"$state"
