import 'package:blockrunner/feature/game/data/repository/map_repository_impl.dart';
import 'package:blockrunner/feature/game/domain/repository/map_repository.dart';
import 'package:blockrunner/feature/game/domain/usecase/game_usecases.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_notifier.dart';
import 'package:blockrunner/feature/game/presentation/game_play/game_play_screen_state.dart';
import 'package:blockrunner/feature/level/level_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// game feature 의 계층별 DI Providers

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepositoryImpl(),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final gameUsecasesProvider = Provider(
  (ref) => GameUsecases.fromRepositories(
    mapRepository: ref.read(mapRepositoryProvider),
    levelRepository: ref.read(levelRepositoryProvider),
    tutorialRepository: ref.read(tutorialRepositoryProvider),
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
