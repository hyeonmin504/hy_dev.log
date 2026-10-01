#!/usr/bin/env bash
# 공개 저장소 보호: Write/Edit 내용과 git commit 직전 스테이징 diff 에서 내부 정보 패턴을 찾으면 차단한다.
# exit 2 = 차단 (stderr 가 에이전트에게 전달됨)
set -u
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')

# 패턴: 회사 도메인·패키지 경로·내부 링크·클라우드 식별자·키·티켓 번호·사설 IP
PATTERN='sportsprism\.net|net\.sportsprism|atlassian\.net|notion\.so|amazonaws\.com|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|(password|passwd|secret|token)[[:space:]]*[:=][[:space:]]*[^[:space:]]{6,}|(^|[^A-Za-z0-9])(DEV|DEVT|SJ)-[0-9]{1,5}([^0-9]|$)|(^|[^0-9])(10|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]+\.[0-9]+'

check() {  # $1 = 검사 대상 텍스트, $2 = 출처 설명
  hits=$(printf '%s' "$1" | grep -nEio "$PATTERN" | head -5)
  if [ -n "$hits" ]; then
    echo "차단: 공개 저장소에 내부 정보 패턴이 들어가려 합니다 ($2)." >&2
    echo "$hits" >&2
    echo "일반화해서 다시 쓰거나, 오탐이면 사용자에게 확인하세요. (패턴은 .claude/hooks/guard-public.sh)" >&2
    exit 2
  fi
}

case "$tool" in
  Write)
    check "$(printf '%s' "$input" | jq -r '.tool_input.content // ""')" "Write $(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')" ;;
  Edit)
    check "$(printf '%s' "$input" | jq -r '.tool_input.new_string // ""')" "Edit $(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')" ;;
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
    if printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+commit'; then
      check "$(git -C "${CLAUDE_PROJECT_DIR:-.}" diff --cached 2>/dev/null | grep '^+' | grep -v '^+++')" "git commit 스테이징 diff"
    fi ;;
esac
exit 0
