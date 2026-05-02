import 'package:shared_preferences/shared_preferences.dart';

const kOnboardingStagePrefKey = 'anchor.onboarding_stage';

enum OnboardingStage {
  intro,     // time input + narrative (new users start here)
  focus,     // focus filter
  quickies,  // quickies selection
  complete;  // done

  static OnboardingStage fromString(String? value) {
    if (value == null) return OnboardingStage.intro;
    return OnboardingStage.values.firstWhere(
      (stage) => stage.name == value,
      orElse: () => OnboardingStage.intro,
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
    if (!hasSchedule && !hasFocusPriorities) return '/onboarding/intro';
    if (!hasFocusPriorities) return '/onboarding/focus-filter';
    if (stage == OnboardingStage.quickies) return '/onboarding/quickies';
    return '/home';
  }

  static Future<void> saveStage(OnboardingStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOnboardingStagePrefKey, stage.name);
  }
}
