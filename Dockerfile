# Stage 1 - Install dependencies and build the app
FROM debian:latest AS build-env

# Install flutter dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip gdb libstdc++6 libglu1-mesa \
    fonts-droid-fallback lib32stdc++6 python3 \
    && apt-get clean

# Clone the flutter repo (shallow clone for speed)
# 버전은 .fvmrc 의 로컬 버전과 맞춘다. 둘이 갈리면 로컬에서 통과한 것이
# 배포에서 깨지고, 그때는 원인이 코드에 있는 것처럼 보인다.
RUN git clone --depth 1 --branch 3.44.8 \
    https://github.com/flutter/flutter.git /usr/local/flutter

WORKDIR /usr/local/flutter

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter setup
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
# --wasm: dart2wasm(skwasm) 과 dart2js(canvaskit) 을 모두 빌드한다. WasmGC 를
#   지원하는 브라우저는 main.dart.wasm 을, 아니면 main.dart.js 를 받는다.
#   판 전체를 CustomPainter 로 그리고 블록이 상시 움직이는 게임이라 skwasm 쪽 이득이 크다.
# --no-web-resources-cdn: 엔진 산출물을 gstatic CDN 대신 같은 출처에서 받는다
#   (서드파티 의존이 사라지고, nginx.conf 의 gzip 대상이 된다)
RUN flutter build web --release --wasm --no-web-resources-cdn

# Stage 2 - Create the run-time image
# nginx 1.21 이상이어야 한다 — 기본 mime.types 에 application/wasm 이 그때 들어왔다.
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
