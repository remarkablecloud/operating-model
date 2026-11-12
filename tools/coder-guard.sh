#!/usr/bin/env bash
# The Coder guard: a Claude Code PreToolUse hook that refuses the commands a
# Coder never runs (production deploys and writes, the release script, pushes
# to main, merges, release tags, secret files) and logs every decision.
#
# Install it root-owned (mode 755) outside the repository, and wire it as a
# PreToolUse hook for Bash, Read, Edit and Write in the settings every agent
# session on the build machine loads. Which sessions it binds is decided by
# the environment: the Coder profile sets AGENT_ROLE=coder. Any other role
# passes straight through, so the architect, which merges and releases, is
# never refused here.
#
# Its rules come from /etc/coder-guard.conf (see coder-guard.conf.example;
# $CODER_GUARD_CONF overrides the path, for tests). A Coder session without a
# readable configuration is refused everything: the guard fails closed.
#
# Exit 2 refuses the call and the reason reaches the session; exit 0 lets it
# through. This is a tripwire, not a wall: the wall is that the Coder's Unix
# user holds no production key.
set -euo pipefail

[ "${AGENT_ROLE:-}" = coder ] || exit 0

GUARD_LOG=/var/log/coder-guard/events.jsonl
PROD_HOSTS_RE='' DEPLOY_RE='' RELEASE_SCRIPT_RE='' RELEASE_TAG_RE='' SECRET_PATHS_RE='' SECRET_CMD_RE='' KEY_VARS_RE='' ARCHITECT_FILES_RE=''
EXTRA_REFUSE=()
conf=${CODER_GUARD_CONF:-/etc/coder-guard.conf}
if [ ! -r "$conf" ]; then
  echo "coder guard: no configuration at $conf; refusing everything until it is installed" >&2
  exit 2
fi
# shellcheck disable=SC1090
. "$conf"

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // .tool_input.file_path // ""')

log() {
  printf '{"ts":"%s","tool":"%s","decision":"%s","reason":"%s","command":%s}\n' \
    "$(date -u +%FT%TZ)" "$tool" "$1" "$2" "$(printf '%s' "$cmd" | cut -c1-400 | jq -Rs .)" >>"$GUARD_LOG" 2>/dev/null || true
}
refuse() {
  log refused "$1"
  echo "coder guard: $1 (Coders never do this; the architect or the founder does). Report it on the card; do not work around it." >&2
  exit 2
}
has() { [ -n "$1" ] && printf '%s' "$2" | grep -Eq -- "$1"; }
hasi() { [ -n "$1" ] && printf '%s' "$2" | grep -Eiq -- "$1"; }

# Where a command can start: the beginning, after a separator, or after a
# wrapper such as bash, sh, exec, env, time, nohup, sudo.
START='(^|[;&|(] *|(bash|sh|exec|env|time|nohup|sudo) +([^ ]+ +)*)'

# Writing verbs on a production host: the service manager, file changes,
# package tools, and the SQL verbs that change rows or structure.
PROD_WRITE_RE="(systemctl +(start|stop|restart|reload|enable|disable|kill|daemon-reload|mask)|(^|[ ;&|(\"'])(rm|mv|cp|install|tee|ln|chmod|chown|useradd|usermod|passwd|crontab|reboot|shutdown|apt|apt-get|dpkg|yum|dnf|sed +-i)([ ;&|)]|\$)|(^|[^a-z_])(insert|update|delete|alter|drop|truncate|create|grant|revoke|vacuum|reindex)([^a-z_]|\$))"

case "$tool" in
  Bash)
    if has "$RELEASE_SCRIPT_RE" "$cmd" && has "$START"'(\./)?([^ ;&|]*/)?('"$RELEASE_SCRIPT_RE"')( |$)' "$cmd"; then refuse "the release script"; fi
    if has "$DEPLOY_RE" "$cmd"; then refuse "production deploy"; fi
    if [ -n "$PROD_HOSTS_RE" ]; then
      if has '(scp|rsync) [^;&|]*('"$PROD_HOSTS_RE"'):' "$cmd"; then refuse "file copy to a production host"; fi
      if has 'ssh [^;&|]*('"$PROD_HOSTS_RE"')' "$cmd" && hasi "$PROD_WRITE_RE" "$cmd"; then refuse "write on a production host (reads are allowed)"; fi
    fi
    if has 'git +push +[^;&|]*(origin +main|:main)( |$|[;&|])' "$cmd"; then refuse "push to main"; fi
    if has 'git +push +[^;&|]*(--force|-f( |$))' "$cmd"; then refuse "force push"; fi
    if has "$RELEASE_TAG_RE" "$cmd" || has 'gh +release +create' "$cmd"; then refuse "release tag"; fi
    if has 'gh +pr +merge|pulls/[0-9]+/merge' "$cmd"; then refuse "merge (the architect merges)"; fi
    if has "$SECRET_CMD_RE" "$cmd"; then refuse "configuration or secret file"; fi
    for rule in "${EXTRA_REFUSE[@]:-}"; do
      [ -n "$rule" ] || continue
      if has "${rule%%::*}" "$cmd"; then refuse "${rule##*::}"; fi
    done
    # Heredoc bodies are prose (a brief, an issue body); only the command lines
    # outside them are checked for a key assignment.
    if [ -n "$KEY_VARS_RE" ]; then
      cmd_no_heredoc=$(printf '%s\n' "$cmd" | awk '
        skip { if ($0 == marker) { skip = 0 }; next }
        match($0, /<<-?[ ]*["'"'"']?[A-Za-z_][A-Za-z0-9_]*["'"'"']?/) {
          m = substr($0, RSTART + 2, RLENGTH - 2); gsub(/^-?[ ]*["'"'"']?|["'"'"']?$/, "", m); marker = m; skip = 1
        }
        { print }')
      if has '(^|[;&|] *)(export +)?'"$KEY_VARS_RE"'=' "$cmd_no_heredoc"; then refuse "a key or secret set on the command line"; fi
    fi ;;
  Read | Edit | Write)
    if has "$SECRET_PATHS_RE" "$cmd"; then refuse "configuration or secret file"; fi
    # Coders propose their own rows in DECISIONS.md, FOR_NOW.md and the memory
    # files; the architect reviews them in the pull request. The files below
    # stay the architect's.
    if [ "$tool" != Read ] && has "$ARCHITECT_FILES_RE" "$cmd"; then refuse "this file is the architect's"; fi ;;
esac

log allowed ""
exit 0
