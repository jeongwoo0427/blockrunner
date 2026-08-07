# 배포

웹 빌드를 **Docker 이미지 하나**로 서빙한다. 컨테이너 안에서 Flutter 를 얕은 클론해 빌드하고
(`Dockerfile` 1단계), 산출물만 `nginx:1.21.1-alpine` 로 옮긴다(2단계).
**빌드 머신에 Flutter 가 없어도 된다.**

```
[리버스 프록시 (TLS 종단)]  →  호스트:7001  →  컨테이너 nginx :80
```

```bash
docker compose up -d --build
```

`--build` 가 없으면 기존 이미지를 재사용해 **변경사항이 반영되지 않는다.**
첫 배포나 문제 확인 시에는 `-d` 를 빼고 로그를 보는 편이 낫다.

**앞단 리버스 프록시 설정은 이 저장소에 두지 않는다.** 도메인 · 인증서 경로 · 서버 설정 위치는
배포 환경마다 다르고, 공개 저장소에 적을 성격의 정보가 아니다. 아래에는 **환경과 무관하게
지켜야 하는 조건**만 적는다.

---

## 웹 빌드 플래그

```bash
fvm flutter build web --release --wasm --no-web-resources-cdn
```

**`Dockerfile` 과 같은 값이어야 한다.** 한쪽만 바꾸면 로컬에서 확인한 것과 배포된 것이 달라진다.

- `--wasm` 은 dart2wasm(skwasm)과 dart2js(canvaskit)을 **모두** 빌드한다. WasmGC 를 지원하는
  브라우저는 `main.dart.wasm` 을, 아니면 `main.dart.js` 를 받는다 (그래서 `build/web` 전체를 서빙한다).
- `--no-web-resources-cdn` 은 엔진 산출물(`skwasm.wasm` 등)을 gstatic CDN 대신 같은 출처에서
  받게 한다. 서드파티 의존이 사라지고, **같은 출처로 와야 nginx 의 gzip 대상이 된다.**
  CDN 으로 되돌리려면 이 플래그만 빼면 된다.

---

## 배포 후 확인

압축이 실제로 걸렸는지 한 번 확인할 것:

```bash
curl -sI -H "Accept-Encoding: gzip" http://localhost:7001/main.dart.wasm   # 컨테이너 직접
curl -sI -H "Accept-Encoding: gzip" https://<도메인>/main.dart.wasm        # 프록시 너머
```

→ `Content-Type: application/wasm` 과 `Content-Encoding: gzip` 이 함께 나와야 한다.
컨테이너에서는 나오는데 프록시 너머에서 `Content-Encoding` 이 사라졌다면, 앞단에
`proxy_set_header Accept-Encoding "";` 가 있는지 확인할 것 — **그 줄이 있으면 컨테이너가
압축을 못 한다.**

압축이 걸리면 첫 로딩에서 실제로 받는 것이 절반 이하가 된다 (실측).

| 브라우저 | 받는 것 | 압축 전 → 후 |
|---|---|---|
| WasmGC 지원 | `main.dart.wasm` | 2,187K → **807K** |
| | `skwasm.wasm` | 3,497K → **1,499K** |
| 그 외 | `main.dart.js` | 2,535K → **752K** |
| | `canvaskit.wasm` | 7,060K → **2,835K** |

---

## 앞단 프록시 — 지켜야 하는 조건 세 가지

**설정 자체는 저장소에 없다.** 어떤 프록시를 쓰든 아래만 지키면 된다.

1. **`Content-Type` 과 `Content-Encoding` 을 그대로 통과시킬 것.** `.wasm` MIME 과 gzip 은 전부
   컨테이너 안 `nginx.conf` 가 처리한다. 앞단은 손대지 않고 넘기기만 하면 된다.
2. **`Accept-Encoding` 을 지우지 말 것.** nginx 기준으로 `proxy_set_header Accept-Encoding "";`
   가 있으면 컨테이너가 압축할 기회를 잃어 위 표의 이득이 통째로 사라진다.
3. **TLS 는 앞단에서 끝낼 것.** 컨테이너는 평문 :80 만 연다.

인증서를 certbot 의 nginx 플러그인으로 발급한다면 **서버 블록보다 인증서가 먼저**여야 한다 —
`listen 443 ssl` 은 인증서 파일이 없으면 nginx 가 아예 뜨지 않는다. 그리고 설치까지 맡기는
`certbot --nginx` 대신 **`certbot certonly --nginx`** 를 쓰는 편이 낫다. 설치를 맡기면 certbot 이
프록시 설정 파일을 직접 고치는데, 여러 사이트가 한 파일에 들어 있으면 그것까지 건드린다.

---

## 검증 없이 넘기기 쉬운 것

`nginx.conf` 의 `.mjs` 처리를 빼면 **화면이 흰 채로 멈춘다.** 이 nginx 버전의 `mime.types` 에
`.mjs` 매핑이 없어 `application/octet-stream` 으로 나가고, ES 모듈은 MIME 을 엄격히 검사해
로드를 거부한다. 콘솔에만 나오고 화면에는 아무 말도 안 나오므로 원인을 찾기 어렵다.

고치는 방법은 **`default_type`** 이어야 한다. `types { }` 블록을 쓰면 부모의 매핑을 통째로
갈아치워 CSS · JS 까지 깨진다.

**Flutter 버전은 두 곳에 있다** — `.fvmrc` 와 `Dockerfile` 의 `git clone --branch`.
함께 움직이지 않으면 로컬에서 통과한 것이 배포 빌드에서 깨지고, 원인은 코드에 있는 것처럼 보인다.
