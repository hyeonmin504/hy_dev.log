# hy_dev.log

개발하면서 겪은 경험을 먼저 기록하고, 거기서 나온 지식을 정리합니다. 순서가 중요합니다. 지식은 경험에서 뽑아내는 것이지 따로 쓰는 게 아닙니다.

## 원칙 하나

**내가 직접 쓰는 곳은 `log/` 하나입니다.** 그날 겪은 일을 시간순으로 서사로 씁니다.
나머지(`notes/`, `index.md`, `retro/`)는 전부 `log/`에서 파생됩니다. 일지는 한 번 쓰면 고치지 않습니다.

```
log/  (원본, 매일, 서사)
  │
  ├──▶ notes/   같은 경험이 반복되면 주제 글로 응축 (til · troubleshooting · decisions)
  ├──▶ index.md 태그 색인 (스크립트 생성)
  └──▶ retro/   주간·월간 회고 (log를 돌아보며)
```

## 폴더

| 경로 | 내용 | 누가 쓰나 |
|---|---|---|
| `log/YYYY/YYYY-MM-DD.md` | 하루 일지. 서사 5~12줄 + 태그 한 줄 | 나 (에이전트가 초안 도움) |
| `notes/til/` | 작은 발견 하나 | 에이전트 제안 → 내가 승인 |
| `notes/troubleshooting/` | 증상 → 가설 → 원인 → 해결 → 교훈 | 〃 |
| `notes/decisions/` | 기술 선택의 맥락·결정·결과 (ADR) | 〃 |
| `retro/YYYY-Wnn.md`, `retro/YYYY-MM.md` | 주간·월간 회고 | 〃 |
| `index.md` | 태그별 · 최근순 색인 | 스크립트 |
| `templates/` | 각 글의 템플릿 | - |

## 일지 한 편의 모양

```
# 2026-07-30

배포 후 커넥션 풀이 고갈됐다는 알림을 받았다. 처음엔 풀 크기가 작아서라고
생각했는데, 메트릭을 보니 커넥션 생성률이 비정상적으로 높았다. 풀 크기
문제면 대기 시간이 튀어야지 생성률이 튈 이유가 없다. 설정을 다시 보니
max-lifetime이 분 단위가 아니라 초 단위로 들어가 있었다. 고치니 생성률이
300배 떨어졌다. 다음에 풀 문제가 보이면 크기보다 생성률부터 볼 것.

태그: #hikari #connection-pool #observability
```

결론보다 **"처음엔 ~라고 생각했는데"** 같은 틀렸던 생각이 더 중요합니다. 그게 다음에 같은 착각을 막아줍니다.

## 에이전트와 같이 쓰기

이 저장소에서 `claude`를 열면 아래 스킬을 쓸 수 있습니다. 규칙은 [`CLAUDE.md`](CLAUDE.md)에 있습니다.

| 스킬 | 하는 일 |
|---|---|
| `/log <오늘 겪은 일>` | 오늘 일지 초안 작성. 형제 레포의 오늘 커밋을 재료로 쓰되 일반화해서 씀 |
| `/promote` | 최근 일지를 읽고 `notes/`로 승격할 후보를 제안, 승인 시 작성 |
| `/index` | `index.md` 재생성 |
| `/retro [주차 또는 월]` | 해당 기간 일지를 모아 회고 초안 작성 |
| `/flow <파일·심볼·설명>` | 형제 레포 코드를 읽고 흐름 슈도코드 블록 생성 (코드 복사 아님) |

## 공개 저장소 규칙

이 저장소는 공개입니다. 아래는 쓰지 않습니다. 훅이 저장 전에 차단합니다.

- 회사 내부 URL, 호스트명, 계정, 토큰, 키
- 고객·선수·팀 등 실제 데이터와 실명
- 티켓 번호, 내부 문서 링크

도메인 용어는 기술 패턴으로 바꿔 씁니다. "대진표 생성이 느렸다" 대신 "트리 구조 생성 로직이 느렸다"처럼.

코드는 복사하지 않고 **흐름을 슈도코드로** 씁니다. 코드는 바뀌지만 흐름은 남습니다. 형식은 [`CLAUDE.md`](CLAUDE.md)의 코드 인용 규칙.

## 참고한 형식

- [jbranchaud/til](https://github.com/jbranchaud/til), [simonw/til](https://github.com/simonw/til) — 주제 폴더 + 짧은 글 + 색인
- [Michael Nygard ADR](https://github.com/joelparkerhenderson/architecture-decision-record/blob/main/locales/en/templates/decision-record-template-by-michael-nygard/index.md) — 맥락 / 결정 / 결과
- [Pragmatic Engineer Work Log](https://blog.pragmaticengineer.com/work-log-template-for-software-engineers/), Julia Evans Brag Document — 주 단위 임팩트 기록
- LLM wiki 패턴 — 원본(raw)과 응축(synthesis) 분리, 색인은 생성
