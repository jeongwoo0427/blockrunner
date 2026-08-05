import 'package:blockrunner/feature/game/domain/usecase/game_usecases.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_notifier.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// game feature 의 계층별 DI Providers

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------
///
/// game 전용 repository 는 없다. 레벨 데이터는 level feature 의
/// `levelRepositoryProvider` 를 그대로 쓴다.

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final gameUsecasesProvider = Provider(
  (ref) => GameUsecases.fromRepositories(
    levelRepository: ref.read(levelRepositoryProvider),
  ),
);

/// ----------------------------------------------------------------------------
/// Presentation
/// ----------------------------------------------------------------------------

/// 레벨 번호로 키잉된다. 화면을 나가면 진행 중이던 판을 버린다.
final gamePlayScreenNotifierProvider = NotifierProvider.autoDispose
    .family<GamePlayScreenNotifier, GamePlayScreenState, int>(
      GamePlayScreenNotifier.new,
    );
