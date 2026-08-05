import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/feature/level/data/repository/level_repository_impl.dart';
import 'package:blockrunner/feature/level/data/repository/tutorial_repository_impl.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/repository/tutorial_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_notifier.dart';
import 'package:blockrunner/feature/level/presentation/level_select/level_select_screen_state.dart';
import 'package:blockrunner/feature/progress/progress_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// level feature 의 계층별 DI Providers

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final levelRepositoryProvider = Provider<LevelRepository>(
  (ref) => LevelRepositoryImpl(),
);

/// 튜토리얼을 이미 봤는지 기억한다. 저장이 필요한 유일한 level 데이터다.
final tutorialRepositoryProvider = Provider<TutorialRepository>(
  (ref) =>
      TutorialRepositoryImpl(preferences: ref.read(sharedPreferencesProvider)),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final levelUsecasesProvider = Provider(
  (ref) => LevelUsecases.fromRepositories(
    levelRepository: ref.read(levelRepositoryProvider),
    progressRepository: ref.read(progressRepositoryProvider),
    // 컨테이너를 거쳐 꺼낸다. 새로 만들면 스트림이 갈려 플레이 화면의
    // 클리어 알림을 영영 받지 못한다.
    clearResults: ref.read(progressUsecasesProvider).saveClearResult.stream,
  ),
);

/// ----------------------------------------------------------------------------
/// Presentation
/// ----------------------------------------------------------------------------

/// 앱의 첫 화면이라 오래 유지된다 — `autoDispose` 를 붙이지 않는다.
/// 클리어 알림 구독도 이 provider 의 수명을 따른다.
final levelSelectScreenNotifierProvider =
    NotifierProvider<LevelSelectScreenNotifier, LevelSelectScreenState>(
      LevelSelectScreenNotifier.new,
    );
