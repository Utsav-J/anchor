import 'package:shared_preferences/shared_preferences.dart';

const kOnboardingStagePrefKey = 'anchor.onboarding_stage';

enum OnboardingStage {
  focus,
  quickies,
  complete;

  static OnboardingStage fromString(String? value) {
    if (value == null) return OnboardingStage.complete;

    return OnboardingStage.values.firstWhere(
      (stage) => stage.name == value,
      orElse: () => OnboardingStage.focus,
    );
  }
}

class OnboardingProgress {
  OnboardingProgress._();

  static String initialLocation({
    required bool hasFocusPriorities,
    required OnboardingStage stage,
  }) {
    if (!hasFocusPriorities) return '/onboarding/focus-filter';
    if (stage == OnboardingStage.quickies) return '/onboarding/quickies';
    if (stage == OnboardingStage.complete) return '/home';
    return '/onboarding/focus-filter';
  }

  static Future<void> saveStage(OnboardingStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOnboardingStagePrefKey, stage.name);
  }
}
