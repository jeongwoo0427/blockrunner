import 'package:blockrunner/feature/level/data/repository/level_repository_impl.dart';
import 'package:blockrunner/feature/level/domain/repository/level_repository.dart';
import 'package:blockrunner/feature/level/domain/usecase/level_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// level feature 의 계층별 DI Providers

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final levelRepositoryProvider = Provider<LevelRepository>(
  (ref) => LevelRepositoryImpl(),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

final levelUsecasesProvider = Provider(
  (ref) => LevelUsecases.fromRepositories(
    levelRepository: ref.read(levelRepositoryProvider),
  ),
);

/// ----------------------------------------------------------------------------
/// Presentation
/// ----------------------------------------------------------------------------
///
/// 레벨 선택 화면의 Notifier 는 `08-level-select` 에서 추가한다.
