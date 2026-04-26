import 'package:anchor/features/onboarding/onboarding_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routes new users to focus onboarding', () {
    expect(
      OnboardingProgress.initialLocation(
        hasFocusPriorities: false,
        stage: OnboardingStage.focus,
      ),
      '/onboarding/focus-filter',
    );
  });

  test('routes users with saved focus but unfinished quickies to quickies', () {
    expect(
      OnboardingProgress.initialLocation(
        hasFocusPriorities: true,
        stage: OnboardingStage.quickies,
      ),
      '/onboarding/quickies',
    );
  });

  test('routes completed users home', () {
    expect(
      OnboardingProgress.initialLocation(
        hasFocusPriorities: true,
        stage: OnboardingStage.complete,
      ),
      '/home',
    );
  });
}
