import 'package:blockrunner/core/di/core_providers.dart';
import 'package:blockrunner/feature/progress/data/repository/progress_repository_impl.dart';
import 'package:blockrunner/feature/progress/domain/repository/progress_repository.dart';
import 'package:blockrunner/feature/progress/domain/usecase/progress_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// progress feature 의 계층별 DI Providers
///
/// 화면이 없는 feature 라 `presentation/` 이 없다. 다른 feature 가 usecase 로만 쓴다.

/// ----------------------------------------------------------------------------
/// Data
/// ----------------------------------------------------------------------------

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) =>
      ProgressRepositoryImpl(preferences: ref.read(sharedPreferencesProvider)),
);

/// ----------------------------------------------------------------------------
/// Domain
/// ----------------------------------------------------------------------------

/// `SaveClearResultUsecase` 가 스트림을 들고 있으므로 **인스턴스가 하나여야 한다.**
/// provider 가 캐시하므로 여기서 꺼내 쓰는 한 방출과 구독이 같은 스트림을 본다.
final progressUsecasesProvider = Provider(
  (ref) => ProgressUsecases.fromRepositories(
    progressRepository: ref.read(progressRepositoryProvider),
  ),
);
