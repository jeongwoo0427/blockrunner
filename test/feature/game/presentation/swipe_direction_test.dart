import 'package:blockrunner/core/config/app_constants.dart';
import 'package:blockrunner/feature/game/domain/entity/direction.dart';
import 'package:blockrunner/feature/game/presentation/game_play/swipe_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const threshold = AppConstants.swipeThreshold;

  group('네 방향', () {
    test('오른쪽', () {
      expect(directionFromSwipe(const Offset(60, 0)), Direction.right);
    });

    test('왼쪽', () {
      expect(directionFromSwipe(const Offset(-60, 0)), Direction.left);
    });

    test('아래 — 화면 좌표는 아래로 갈수록 y 가 커진다', () {
      expect(directionFromSwipe(const Offset(0, 60)), Direction.down);
    });

    test('위', () {
      expect(directionFromSwipe(const Offset(0, -60)), Direction.up);
    });
  });

  group('임계값', () {
    test('임계값에 못 미치면 탭으로 보고 무시한다', () {
      expect(directionFromSwipe(const Offset(threshold - 1, 0)), isNull);
      expect(directionFromSwipe(const Offset(0, -(threshold - 1))), isNull);
      expect(directionFromSwipe(Offset.zero), isNull);
    });

    test('임계값과 같으면 인정한다', () {
      expect(directionFromSwipe(const Offset(threshold, 0)), Direction.right);
    });

    test('대각선으로 합친 거리가 넘어도 두 성분이 모두 미달이면 무시한다', () {
      // 길이는 약 32 로 임계값을 넘지만 어느 방향을 의도했는지 알 수 없다.
      const delta = Offset(threshold - 1, threshold - 1);

      expect(delta.distance, greaterThan(threshold));
      expect(directionFromSwipe(delta), isNull);
    });

    test('임계값을 인자로 바꿀 수 있다', () {
      expect(directionFromSwipe(const Offset(10, 0)), isNull);
      expect(
        directionFromSwipe(const Offset(10, 0), threshold: 5),
        Direction.right,
      );
    });
  });

  group('대각선 판정', () {
    test('가로 성분이 크면 가로로 간다', () {
      expect(directionFromSwipe(const Offset(80, -50)), Direction.right);
    });

    test('세로 성분이 크면 세로로 간다', () {
      expect(directionFromSwipe(const Offset(-50, 80)), Direction.down);
    });

    test('두 성분이 정확히 같으면 가로가 이긴다', () {
      expect(directionFromSwipe(const Offset(60, 60)), Direction.right);
      expect(directionFromSwipe(const Offset(-60, -60)), Direction.left);
    });
  });
}
