#!/usr/bin/env bash
# status.sh <issue> <status> [owner/repo]: move one card on the board.
#
#   tools/status.sh 41 "In progress"   # when the Coder starts
#   tools/status.sh 41 "In review"     # when the pull request opens
#
# Reads tools/board.json (or $OM_BOARD_CONFIG). The gh login needs the project
# scope. Done is refused: the board's own workflow moves a card there when the
# pull request merges.
#
# Exit codes: 0 moved (prints the issue, the old and the new status); 1 a
# failure or a refused status; 2 usage.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
conf=${OM_BOARD_CONFIG:-$here/board.json}
issue=${1:-}
status=${2:-}
if [[ ! "$issue" =~ ^[0-9]+$ || -z "$status" ]]; then
	echo "usage: tools/status.sh <issue number> <Needs Attention|Backlog|Ready|In progress|In review> [owner/repo]" >&2
	exit 2
fi
case "$status" in
"Needs Attention" | Backlog | Ready | "In progress" | "In review") ;;
Done)
	echo "status.sh: never move a card to Done by hand; the merge's 'fixes #$issue' does it" >&2
	exit 1
	;;
*)
	echo "status.sh: unknown status '$status'" >&2
	exit 1
	;;
esac
[ -f "$conf" ] || { echo "status.sh: no board configuration at $conf" >&2; exit 1; }

owner=$(jq -r .owner "$conf")
project=$(jq -r .project_number "$conf")
repo=${3:-$(jq -r .default_repo "$conf")}

project_id=$(gh project view "$project" --owner "$owner" --format json --jq .id)
fields=$(gh project field-list "$project" --owner "$owner" --format json)
field_id=$(jq -r '.fields[] | select(.name=="Status") | .id' <<<"$fields")
option_id=$(jq -r --arg s "$status" '.fields[] | select(.name=="Status") | .options[] | select(.name==$s) | .id' <<<"$fields")
if [ -z "$field_id" ] || [ -z "$option_id" ]; then
	echo "status.sh: the board has no Status option '$status'" >&2
	exit 1
fi
item=$(gh project item-list "$project" --owner "$owner" --format json --limit 1000 |
	jq -r --argjson n "$issue" --arg r "$repo" '.items[] | select(.content.number==$n and ((.content.repository // "") | endswith($r))) | [.id, (.status // "")] | @tsv')
if [ -z "$item" ]; then
	echo "status.sh: issue #$issue of $repo has no card on the board" >&2
	exit 1
fi
item_id=$(cut -f1 <<<"$item")
old=$(cut -f2 <<<"$item")
gh project item-edit --project-id "$project_id" --id "$item_id" --field-id "$field_id" --single-select-option-id "$option_id" >/dev/null
echo "#$issue: ${old:-no status} -> $status"
