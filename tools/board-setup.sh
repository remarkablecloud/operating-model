#!/usr/bin/env bash
# board-setup.sh: create a project's board, labels and pinned issues, and
# write tools/board.json for the other tools.
#
#   tools/board-setup.sh <owner> <owner/repo> "<board title>" <founder login> [time zone]
#
# <owner> is the organization or user that owns the board. Needs gh with the
# project scope (gh auth refresh -s project) and jq. Run once, at kickoff.
# It ends by printing the steps GitHub only allows by hand.
set -euo pipefail

owner=${1:-}; repo=${2:-}; title=${3:-}; founder=${4:-}; tz=${5:-UTC}
if [ -z "$owner" ] || [ -z "$repo" ] || [ -z "$title" ] || [ -z "$founder" ]; then
	echo 'usage: tools/board-setup.sh <owner> <owner/repo> "<board title>" <founder login> [time zone]' >&2
	exit 2
fi
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
conf=$here/board.json
[ -e "$conf" ] && { echo "board-setup.sh: $conf exists; this project already has a board" >&2; exit 1; }
warn() { echo "board-setup.sh: $1 (do it by hand; see the end)" >&2; manual+=("$1"); }
manual=()

number=$(gh project create --owner "$owner" --title "$title" --format json --jq .number)
project_id=$(gh project view "$number" --owner "$owner" --format json --jq .id)
echo "board $number created"
gh project link "$number" --owner "$owner" --repo "$repo" >/dev/null 2>&1 || warn "link the board to $repo"

field() { gh project field-create "$number" --owner "$owner" --name "$1" --data-type "$2" "${@:3}" >/dev/null || warn "create the field '$1'"; }
field Priority SINGLE_SELECT --single-select-options "Urgent,High,Medium,Low"
field Size SINGLE_SELECT --single-select-options "XS,S,M,L,XL"
field Estimate NUMBER
field Actual NUMBER
field "Start date" DATE
field "Target date" DATE
field Agent TEXT

# Status: Needs Attention first, then the flow.
status_id=$(gh project field-list "$number" --owner "$owner" --format json --jq '.fields[] | select(.name=="Status") | .id')
# shellcheck disable=SC2016
gh api graphql -f f="$status_id" -f query='
mutation($f:ID!){ updateProjectV2Field(input:{fieldId:$f, singleSelectOptions:[
  {name:"Needs Attention", color:RED, description:"Waits on the founder"},
  {name:"Backlog", color:GRAY, description:"Not ready to start"},
  {name:"Ready", color:BLUE, description:"Has a brief that passes the checklist"},
  {name:"In progress", color:YELLOW, description:"A Coder is on it"},
  {name:"In review", color:PURPLE, description:"Pull request open"},
  {name:"Done", color:GREEN, description:"Merged"}]}){ projectV2Field{ ... on ProjectV2SingleSelectField{ id } } } }' >/dev/null 2>&1 ||
	warn "set the Status options to: Needs Attention, Backlog, Ready, In progress, In review, Done"

label() { gh label create "$1" --repo "$repo" --color "$2" --description "$3" --force >/dev/null || warn "create the label '$1'"; }
label "decision required" D93F0B "Waits on a founder decision"
label marketing C5DEF5 "Marketing, content or business work, off the board"
label pause B60205 "On the Pause issue: stops every heartbeat"
label operating-model 5319E7 "A change proposed for the operating model itself"
label bug D73A4A "Something is broken"
label feature A2EEEF "Something new for customers"
label task EDEDED "Operations, research or a decision"

issue() { gh issue create --repo "$repo" --title "$1" --body "$2" | sed 's#.*/##'; }
report_issue=$(issue "Morning report" "The architect posts the morning report and every deploy line here, one comment each.")
pause_issue=$(issue "Pause" "Add the label \`pause\` to this issue to stop every heartbeat. Remove it to resume.")
gh issue pin "$report_issue" --repo "$repo" >/dev/null 2>&1 || warn "pin issue #$report_issue (Morning report)"
gh issue pin "$pause_issue" --repo "$repo" >/dev/null 2>&1 || warn "pin issue #$pause_issue (Pause)"

jq -n --arg project "$title" --arg owner "$owner" --argjson number "$number" --arg repo "$repo" \
	--argjson report "$report_issue" --argjson pause "$pause_issue" --arg founder "$founder" --arg tz "$tz" '
	{project: $project, owner: $owner, project_number: $number, repos: [$repo], default_repo: $repo,
	 report_issue: $report, pause_issue: $pause, founder_login: $founder, founder_timezone: $tz,
	 report_hour: 7, lanes: 2, hours_per_day: 6, train_windows_utc: [], status_url: ""}' >"$conf"
echo "wrote $conf (project id $project_id); set lanes, hours_per_day, train_windows_utc and status_url there"

cat <<END

By hand, in the board's settings (GitHub offers no command for these):
  1. Workflows: turn on "Item closed" and "Pull request merged" (set Status to Done),
     "Auto-add to project" for $repo, and "Item added to project" (set Status to Backlog).
  2. Views: add a Roadmap view using Start date and Target date, and a Board view grouped by Status.
  3. The agents' GitHub App or bot account: give it write access to $repo and to the board.
END
for m in "${manual[@]:-}"; do [ -n "$m" ] && echo "  also: $m"; done
exit 0
