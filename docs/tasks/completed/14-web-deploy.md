# 14. 웹 개시 — Docker

## 목표

만든 게임을 **주소 하나로 열 수 있게** 한다. 지금은 로컬에서 `fvm flutter run -d web-server` 를
띄우는 것이 웹으로 보는 유일한 방법이라, 다른 사람에게 보여줄 수도 없고 실기기 브라우저에서
확인할 수도 없다.

## 선행 조건

- 없음. 코드는 이미 웹에서 돌아간다 (`10-responsive`, `11-i18n` 까지 완료)

## 작업

### 1. 옆 프로젝트의 구성을 그대로 가져온다

`../aboutme` 가 이미 같은 모양으로 돌고 있다.

```
[리버스 프록시 (TLS 종단)]  →  호스트:7001  →  컨테이너 nginx :80
```

**새로 설계하지 않는다.** 이 방식이 이미 여러 사이트에서 돌고 있고, 그 과정에서 겪은
함정(`.mjs` MIME, gzip 이 프록시에서 죽는 것)이 aboutme 의 설정 파일에 주석으로 남아 있다.
같은 문제를 다시 겪을 이유가 없다.

**앞단 프록시 설정은 저장소에 넣지 않는다.** 공개 저장소이고, 도메인 · 인증서 경로 · 서버 설정
위치는 프로젝트 정보가 아니라 배포 환경 정보다. 저장소에는 **어떤 프록시든 지켜야 하는 조건**만
남긴다 (README §배포).

### 2. 저장소에 넣을 파일 4개

| 파일 | 하는 일 |
|---|---|
| `Dockerfile` | 2단계. debian 에서 Flutter 3.44.8 얕은 클론 → `flutter build web --release --wasm --no-web-resources-cdn` → 산출물만 `nginx:1.21.1-alpine` 로 |
| `nginx.conf` | gzip · `.mjs` MIME · `try_files`. Dockerfile 이 `conf.d/default.conf` 로 복사 |
| `docker-compose.yaml` | `7001:80`, `restart: always`, `container_name: blockrunner` |
| `.dockerignore` | 빌드 컨텍스트 축소 |

**빌드 플래그 두 개에 이유가 있다.**
- `--wasm` — dart2wasm(skwasm)과 dart2js(canvaskit)을 **둘 다** 만든다. WasmGC 를 지원하는
  브라우저는 `main.dart.wasm` 을, 아니면 `main.dart.js` 를 받으므로 `build/web` 전체를 서빙한다.
  판 전체를 `CustomPainter` 로 그리고 블록이 상시 움직이는 게임이라 skwasm 쪽 이득이 크다.
- `--no-web-resources-cdn` — 엔진 산출물을 gstatic 대신 같은 출처에서 받는다. 서드파티 의존이
  사라지고, **같은 출처로 와야 nginx 의 gzip 대상이 된다.**

**Flutter 버전은 `.fvmrc`(3.44.8)와 Dockerfile 두 곳에 있다.** 한쪽만 올리면 로컬에서 통과한
것이 배포에서 깨지고, 그때 원인이 코드에 있는 것처럼 보인다. Dockerfile 주석에 박아 둔다.

### 3. `web/` 에 남은 스캐폴드 기본값

배포하면 그대로 노출되는 자리다.

- `<title>` 과 `apple-mobile-web-app-title` 이 소문자 `blockrunner` → `BlockRunner`
- `manifest.json` 의 `name`/`short_name` 도 마찬가지
- `manifest.json` 의 `background_color`/`theme_color` 가 Flutter 기본 파랑 `#0175C2` →
  앱 실제 색으로 (`#FAF8FF` 라이트 `surface` / `#2F5FD0` `BaseTheme.seed`)

**HTML 로딩 화면은 넣지 않는다.** aboutme 는 `web/css/style.css` 에 `LOADING` 애니메이션을 두는데,
blockrunner 에는 **이미 앱 자체 스플래시가 있다**(`AppConstants.splashDuration` 2.8초).
둘을 겹치면 로딩 화면이 연달아 두 번 나온다. 다운로드 구간의 흰 화면이 실제로 거슬리는지는
한 번 올려 보고 판단한다.

### 4. 앞단 프록시 (배포 환경 쪽, sudo 필요)

설정 내용은 저장소 밖이다. 순서와 원칙만 적어 둔다.

1. **기존 인증서의 authenticator 를 먼저 확인한다.** 새 방식을 발명하지 말고 그 환경에서 이미
   돌고 있는 방식을 그대로 따른다
2. **인증서가 서버 블록보다 먼저** — `listen 443 ssl` 은 인증서 파일이 없으면 nginx 가 아예
   뜨지 않는다. 설치까지 맡기는 `certbot --nginx` 대신 **`certonly`** 를 쓴다. 설치를 맡기면
   certbot 이 설정 파일을 직접 고치는데, 여러 사이트가 한 파일에 있으면 그것까지 건드린다
3. 서버 블록 추가 → `nginx -t` → `reload`. **`proxy_set_header Accept-Encoding "";` 를 넣지
   않는다** — 넣으면 컨테이너가 gzip 을 못 한다

## 완료 기준

- [x] `docker compose up -d --build` 로 컨테이너가 뜨고 `restart: always` 로 재부팅에서 살아난다
- [x] `curl -sI localhost:7001/` → `200`
- [x] `.wasm` 이 `Content-Type: application/wasm` + `Content-Encoding: gzip` 으로 나간다
- [x] `.mjs` 가 `text/javascript` 로 나간다 (여기가 `octet-stream` 이면 흰 화면에서 멈춘다)
- [x] 없는 경로가 `index.html` 로 떨어진다 (없는 `.mjs` 는 404 로 — 그게 맞다)
- [x] `analyze` 와 `test` 가 통과한다 (이 서버에 flutter 가 없어 **빌드 스테이지 이미지 안에서** 돌렸다 — 575/575)
- [ ] 도메인으로 열리고 레벨을 클리어할 수 있다 — **앞단 프록시 설정 후 사용자 확인**
- [ ] 프록시를 지난 뒤에도 `Content-Encoding: gzip` 이 남아 있다 — 같음
- [ ] **새로고침해도 별점·해금이 남아 있다** — 고정 출처가 생겼다는 것의 실제 의미다 (#91). 같음

## 열린 질문

- 다운로드 구간의 흰 화면 — 실제로 거슬리면 HTML 로딩 화면을 따로 검토한다 (§3)
- **일본어·중국어 글리프가 웹에서 두부(□)로 깨지는지** — `10-responsive` 가 "육안으로만 볼 수
  있다" 며 미확인으로 남긴 항목이다. 개시하면 비로소 확인할 수 있게 된다
- 배포 자동화(CI) 는 하지 않는다. 지금은 서버에서 `docker compose up -d --build` 한 줄이다

---

## 실제 결과

**컨테이너까지는 전부 확인했고, 앞단 프록시 연결만 사용자 쪽에 남았다.**

### 검증한 것

| 항목 | 결과 |
|---|---|
| 웹 빌드 | 성공. wasm 컴파일 84초, 최종 이미지 97.3MB |
| `analyze` + `test` | **빌드 스테이지 이미지 안에서** 돌려 `No issues found!` · **575/575 통과** |
| `.wasm` | `application/wasm` + `Content-Encoding: gzip` |
| `.mjs` | `text/javascript` |
| SPA 폴백 | 없는 경로 → `index.html`, 없는 `.mjs` → 404 |

**gzip 실측 — 첫 로딩에서 받는 것이 절반 이하가 된다.**

| 브라우저 | 파일 | 압축 전 → 후 |
|---|---|---|
| WasmGC 지원 | `main.dart.wasm` | 2,187K → 807K |
| | `skwasm.wasm` | 3,497K → 1,499K |
| 그 외 | `main.dart.js` | 2,535K → 752K |
| | `canvaskit.wasm` | 7,060K → 2,835K |

### 결정

**빌드 머신에 Flutter 가 없어서 검증 경로를 새로 만들었다.** 이 서버에는 `fvm` 도 `flutter` 도
없다. 그런데 Dockerfile 1단계가 **핀 고정된 SDK 를 이미 갖고 있으므로**, 그 스테이지를
`--target build-env` 로 뽑아 그 안에서 `analyze && test` 를 돌리면 된다. 검증을 건너뛸 이유가
아니라 검증을 다른 데서 하면 되는 문제였다. `.dockerignore` 에서 `test/` 를 **일부러 뺀** 것이
그래서다 — 최종 이미지에는 어차피 `build/web` 만 들어간다.

**`.symbols` 와 `NOTICES` 가 압축되지 않는 것은 그대로 뒀다.** 매핑이 없어 octet-stream 으로
나가는데, 둘 다 런타임에 받지 않는 파일이다(스택 심볼화 · 라이선스 표시용). `gzip_types` 에
octet-stream 을 넣으면 매핑 없는 **모든 것**을 압축하게 되므로 그러지 않았다.

**앞단 프록시 설정을 저장소에서 뺐다** (사용자 지시). 공개 저장소이고, 도메인 · 인증서 경로 ·
서버 설정 파일 위치는 프로젝트 정보가 아니라 배포 환경 정보다. 처음에는 서버 블록 전문을
README 에 넣었다가, **"어떤 프록시든 지켜야 하는 조건 세 가지"** 로 바꿨다 — 통과시킬 헤더,
지우면 안 되는 헤더, TLS 종단 위치. 조건은 환경이 바뀌어도 유효하지만 서버 블록은 아니다.

**계획 단계에서 잘못 짚은 것 하나를 고쳤다.** "80포트가 전부 308 로 리다이렉트되니 `certbot
--nginx` 가 실패할 수 있다" 고 적었는데, 실제로는 문제가 되지 않는다 — certbot 의 nginx
플러그인이 `server_name` 이 정확히 일치하는 임시 :80 블록을 만들고, **nginx 는 정확 매칭을
`server_name` 없는 catch-all 보다 우선**하므로 챌린지가 리다이렉트를 타지 않는다. 그 환경에서
이미 여러 도메인이 같은 방식으로 발급돼 있다는 것이 증거였다.

**HTML 로딩 화면은 넣지 않았다** (§3 그대로). 앱 스플래시가 이미 있어 두 번 겹친다.

### 남은 것

- 앞단 프록시 연결과 도메인 확인은 sudo 가 필요해 사용자가 실행한다
- `10-responsive` 가 남긴 **CJK 글리프 두부(□) 확인** — 개시하면 비로소 볼 수 있다
