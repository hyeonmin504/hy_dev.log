---
name: index
description: scripts/build_index.py 를 실행해 index.md 를 재생성하고 결과(편수·태그 수·새로 생긴 태그)를 보고한다. 사용자가 "/index", "색인 갱신", "인덱스 다시 만들어"라고 하면 사용.
---

# /index — 색인 재생성

1. `python3 scripts/build_index.py` 실행.
2. `git diff --stat index.md` 로 변화를 보고. 새 태그가 생겼으면 비슷한 기존 태그가 있는지 확인해 통일을 제안한다(예: `#jpa` 와 `#hibernate`).
3. `index.md` 를 손으로 고치지 않는다. 형식을 바꾸고 싶으면 스크립트를 고친다.
4. 커밋하지 않는다.
