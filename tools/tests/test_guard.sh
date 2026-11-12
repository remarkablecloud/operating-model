#!/usr/bin/env bash
# Tests of the Coder guard against the example configuration: every rule is
# tested on what it must refuse and on what it must let through.
#   tools/tests/test_guard.sh
set -uo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tmp=$(mktemp -d)
sed "s#^GUARD_LOG=.*#GUARD_LOG=$tmp/log.jsonl#" "$here/../coder-guard.conf.example" >"$tmp/conf"
fails=0
t() { # t <expected exit> <tool> <command or path> [role]
	local want=$1 tool=$2 arg=$3 role=${4:-coder} j rc
	if [ "$tool" = Bash ]; then j=$(jq -n --arg c "$arg" '{tool_name:"Bash",tool_input:{command:$c}}')
	else j=$(jq -n --arg t "$tool" --arg c "$arg" '{tool_name:$t,tool_input:{file_path:$c}}'); fi
	echo "$j" | AGENT_ROLE=$role CODER_GUARD_CONF=$tmp/conf "$here/../coder-guard.sh" 2>/dev/null; rc=$?
	if [ "$rc" != "$want" ]; then echo "FAIL (exit $rc, wanted $want) $tool: $arg"; fails=$((fails + 1)); fi
}
t 0 Bash 'go test ./...'
t 2 Bash './release-train'
t 2 Bash 'cd deploy && bash release-train --now'
t 0 Bash 'git push origin fix/release-train-docs'
t 0 Bash 'git add deploy/release-train'
t 2 Bash 'deploy-production v1.2'
t 2 Bash 'git push origin main'
t 0 Bash 'git push origin main-menu-fix'
t 2 Bash 'git push origin HEAD:main'
t 2 Bash 'git push --force origin x'
t 0 Bash 'git push origin feature/x'
t 2 Bash 'gh pr merge 12 --squash'
t 2 Bash 'git tag v1.4.0'
t 0 Bash 'git tag --list'
t 0 Bash 'ssh app-1.example.com "journalctl -u app -n 50 2>/dev/null"'
t 2 Bash 'ssh app-1.example.com "systemctl restart app"'
t 2 Bash 'ssh db-1.example.com "psql -c \"DELETE FROM users\""'
t 2 Bash 'scp build.tar app-1.example.com:/srv/'
t 2 Bash 'cat /etc/example/app.conf'
t 2 Bash 'EXAMPLE_API_KEY=abc ./run'
t 0 Bash $'gh issue comment 3 --body-file - <<END\nEXAMPLE_API_KEY=abc is how it is set\nEND'
t 2 Read '/etc/example/app.conf'
t 2 Read '/home/coder/repo/server.pem'
t 0 Read '/home/coder/repo/docs/DECISIONS-PENDING.md'
t 2 Edit '/home/coder/repo/docs/DECISIONS-PENDING.md'
t 0 Edit '/home/coder/repo/docs/memory/gotchas.md'
t 0 Edit '/home/coder/repo/docs/DECISIONS.md'
t 0 Bash 'gh pr merge 12 --squash' architect
# No configuration: a Coder is refused everything.
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | AGENT_ROLE=coder CODER_GUARD_CONF=/nonexistent "$here/../coder-guard.sh" 2>/dev/null
[ $? = 2 ] || { echo "FAIL: no configuration must refuse"; fails=$((fails + 1)); }
rm -rf "$tmp"
[ "$fails" = 0 ] && echo "guard: all tests pass" || { echo "guard: $fails failed"; exit 1; }
