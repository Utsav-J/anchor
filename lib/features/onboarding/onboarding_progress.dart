import 'package:shared_preferences/shared_preferences.dart';

const kOnboardingStagePrefKey = 'anchor.onboarding_stage';

enum OnboardingStage {
  opening,   // opening cinematic (brand new users start here)
  intro,     // time input + narrative
  focus,     // focus filter
  quickies,  // quickies selection
  reveal,    // ownership reveal + brand arrival
  complete;  // done

  static OnboardingStage fromString(String? value) {
    if (value == null) return OnboardingStage.opening;
    return OnboardingStage.values.firstWhere(
      (stage) => stage.name == value,
      orElse: () => OnboardingStage.opening,
    );
  }
}

class OnboardingProgress {
  OnboardingProgress._();

  /// Returns the correct initial route.
  ///
  /// Logic:
  /// - No schedule AND no priorities → brand new user → intro
  /// - Has schedule but no priorities → completed intro, start focus filter
  /// - Stage is quickies → resume at quickies
  /// - Has priorities (any other stage) → home
  static String initialLocation({
    required bool hasFocusPriorities,
    required OnboardingStage stage,
    required bool hasSchedule,
  }) {
    if (!hasSchedule && !hasFocusPriorities) return '/onboarding/opening';
    if (!hasFocusPriorities) return '/onboarding/focus-filter';
    if (stage == OnboardingStage.quickies) return '/onboarding/quickies';
    if (stage == OnboardingStage.reveal) return '/onboarding/reveal';
    return '/home';
  }

  static Future<void> saveStage(OnboardingStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOnboardingStagePrefKey, stage.name);
  }
}
