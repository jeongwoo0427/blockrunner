-- nvim 프로젝트 로컬 설정 (`:h exrc`). flutter-tools 의 `:FlutterRun` 대상 목록.
--
-- quizlab 과 달리 **flavor 도 엔트리포인트 분기도 없다** — 서버가 없어 dev/prod 를
-- 나눌 이유가 없고 진입점은 `lib/main.dart` 하나다. 그래서 목록을 나누는 축은
-- flavor 가 아니라 **플랫폼**이다 (docs/architecture.md §12).
--
-- Flutter 는 FVM 으로 3.44.8 에 고정돼 있다(`.fvmrc`). flutter-tools 가 `.fvm/flutter_sdk`
-- 를 집도록 전역 설정에서 `fvm = true` 가 켜져 있어야 한다 — quizlab 과 같은 조건이다.
require("flutter-tools").setup_project({
  {
    name = "Chrome (debug)",
    target = "lib/main.dart",
    flutter_mode = "debug",
    device = "chrome",
  },
  {
    -- 휴대폰 실기기에서 같은 와이파이로 붙어볼 때 쓴다. 스와이프 손맛은
    -- 데스크탑 브라우저의 마우스 드래그로는 확인되지 않는다.
    name = "Web-server (debug)",
    target = "lib/main.dart",
    flutter_mode = "debug",
    device = "web-server",
    web_port = "1818",
    additional_args = { "--web-hostname=0.0.0.0" },
  },
  {
    name = "macOS (debug)",
    target = "lib/main.dart",
    flutter_mode = "debug",
    device = "macos",
  },
  {
    -- 기기를 고르지 않는다. 붙어 있는 시뮬레이터·실기기를 flutter 가 고르게 둔다.
    name = "Device (debug)",
    target = "lib/main.dart",
    flutter_mode = "debug",
  },
  {
    -- 연출이 60fps 로 도는지는 debug 빌드로 판단할 수 없다 (기획서 §7).
    name = "Chrome (release)",
    target = "lib/main.dart",
    flutter_mode = "release",
    device = "chrome",
  },
})
