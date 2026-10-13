---
name: index
description: scripts/build_index.py 를 실행해 index.md 를 재생성하고, 색인 누락·미커밋 링크·공개 정보를 점검한 뒤 결과(편수·태그 수·새로 생긴 태그·커밋 묶음)를 보고한다. 사용자가 "/index", "색인 갱신", "인덱스 다시 만들어"라고 하면 사용.
---

# /index — 색인 재생성과 점검

색인은 디스크의 파일을 읽어 만든다. 그래서 **아직 커밋하지 않은 일지도 색인에 링크된다.** 색인만 커밋해 push하면 공개 레포에서 그 링크가 깨진다. 이 스킬은 재생성 뒤 그걸 잡아낸다.

## 1. 재생성

`python3 scripts/build_index.py` 실행. `index.md` 를 손으로 고치지 않는다. 형식을 바꾸고 싶으면 스크립트를 고친다.

## 2. 누락 점검

아래를 한 번에 돌려 표로 보고한다. zsh 는 변수를 단어로 나누지 않으므로 파일 목록은 반드시 `-z | xargs -0` 이나 `while read` 로 넘긴다.

```bash
# 2-1. 기록 파일 중 색인에 없는 것 (있으면 스크립트 문제 — 원인부터 본다)
find log notes retro -name '*.md' | sort | while read f; do grep -qF "($f)" index.md || echo "누락: $f"; done
# 2-2. 색인 링크 중 파일이 없는 것
grep -o '([a-z]*/[^)]*\.md)' index.md | tr -d '()' | sort -u | while read p; do [ -f "$p" ] || echo "없음: $p"; done
# 2-3. 요약 줄이 없는 일지 (색인 설명이 비게 됨)
find log -name '*.md' | while read f; do grep -q '^\*\*요약\*\*' "$f" || echo "요약없음: $f"; done
# 2-4. 색인이 링크하지만 아직 커밋되지 않은 파일 → 색인과 같이 커밋해야 하는 묶음
git ls-files -z --others --exclude-standard log notes retro | xargs -0 -I{} sh -c 'grep -qF "({})" index.md && echo "미커밋 링크: {}"'
# 2-5. 이미 커밋된 일지 중 커밋된 색인에서 빠져 있던 것 (지난번에 /index 를 안 돌린 흔적)
git show HEAD:index.md > "${TMPDIR:-/tmp}/idx_head.md"
git ls-files log notes retro | grep '\.md$' | while read f; do grep -qF "($f)" "${TMPDIR:-/tmp}/idx_head.md" || echo "커밋색인에없음: $f"; done
```

## 3. 공개 정보 점검 (2-4 묶음 + index.md)

이 레포는 공개다. 커밋 대상이 될 파일을 `.claude/hooks/guard-public.sh` 의 `PATTERN` 과 같은 패턴으로 검사한다. 가드 훅은 이 레포에서 연 세션에서만 돌기 때문에, 다른 레포 세션에서 실행될 때도 직접 검사해야 한다.

```bash
P=$(grep -m1 "^PATTERN=" .claude/hooks/guard-public.sh | sed "s/^PATTERN='//; s/'$//")
{ git ls-files -z --others --exclude-standard log notes retro; printf 'index.md\0'; } | xargs -0 grep -nEio "$P"
```

걸리면 커밋 묶음에서 그 파일을 빼고 보고한다. 오탐인지는 사용자가 정한다.

## 4. 태그

`git diff index.md` 에서 새로 생긴 `### #태그` 를 뽑고, 비슷한 기존 태그가 있으면 통일을 제안한다(예: `#jpa` 와 `#hibernate`, `#logging` 과 `#json-logging`).

## 5. 보고와 커밋

보고 형식:

| 항목 | 결과 |
|---|---|
| 편수·태그 수 | `총 N편 · 태그 M개` (이전 값과 함께) |
| 2-1 누락 / 2-2 깨진 링크 / 2-3 요약 없음 | 건수와 파일 |
| 커밋 묶음 | `index.md` + 2-4 의 미커밋 파일 목록 |
| 공개 정보 점검 | 0건 또는 걸린 파일·줄 |
| 새 태그 | 목록과 통일 제안 |

- **커밋은 사용자가 지시할 때만 한다** (CLAUDE.md 금지 규칙). 대신 "커밋 묶음을 커밋할까요?" 한 번만 묻는다.
- 지시를 받으면 **커밋 묶음 전체를 한 커밋으로** 올린다. 색인만 따로 커밋하지 않는다. 묶음 밖의 미커밋 변경(`CLAUDE.md`, 스킬 등)은 건드리지 않는다.
- 커밋 메시지는 레포 관례 `docs: <무엇> — <핵심>` 를 따른다. 예: `docs: 3~9월 일지 12편 추가하고 색인 재생성 — 총 18편·태그 94개`
- push 도 지시가 있을 때만. push 전에 `git fetch` 후 `git rev-list --left-right --count origin/main...HEAD` 로 원격이 앞서 있지 않은지 본다.
