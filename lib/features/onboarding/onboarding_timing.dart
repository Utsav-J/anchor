/// Centralized animation durations and delays for the entire onboarding flow.
///
/// Edit values here to experiment with pacing across all onboarding screens.
class OnboardingTiming {
  OnboardingTiming._();

  // ── Screen 0 — Opening Cinematic ──────────────────────────────────────────
  static const openingBlankHold = Duration(milliseconds: 600);
  static const openingLine1WordDelay = Duration(milliseconds: 120);
  static const openingLine1FadeIn = Duration(milliseconds: 500);
  static const openingPauseBetweenLines = Duration(milliseconds: 800);
  static const openingLine2FadeIn = Duration(milliseconds: 400);
  static const openingHold = Duration(milliseconds: 2000);
  static const openingFadeOut = Duration(milliseconds: 300);
  static const openingGradientCycle = Duration(milliseconds: 6000);

  // ── Screens 1–2 — Morning / Evening Input ─────────────────────────────────
  static const inputSlideUp = Duration(milliseconds: 400);
  static const inputPageTransition = Duration(milliseconds: 450);
  static const inputBackgroundShift = Duration(milliseconds: 600);
  static const inputDigitSwitch = Duration(milliseconds: 180);
  static const inputDotTransition = Duration(milliseconds: 300);
  static const inputSkipSwitch = Duration(milliseconds: 220);
  static const inputAmPmSwitch = Duration(milliseconds: 200);
  static const inputCardCompress = Duration(milliseconds: 120);

  // ── Screens 3–9 — Cinematic Math (Narrative) ─────────────────────────────
  static const narrativeBeatFade = Duration(milliseconds: 380);
  static const narrativeLineFadeIn = Duration(milliseconds: 350);
  static const narrativeLinePause = Duration(milliseconds: 600);
  static const narrativeLineHold = Duration(milliseconds: 1500);
  static const narrativeNumberScaleUp = Duration(milliseconds: 400);
  static const narrativeNumberTextDelay = Duration(milliseconds: 300);
  static const narrativeFlipDown = Duration(milliseconds: 300);
  static const narrativeFlipTextDelay = Duration(milliseconds: 300);

  // Beat hold durations (how long a beat stays before advancing)
  static const beatMorningContext = Duration(milliseconds: 2800);
  static const beatMorningWindow = Duration(milliseconds: 2200);
  static const beatMorningFlip = Duration(milliseconds: 2400);
  static const beatEveningContext = Duration(milliseconds: 2800);
  static const beatEveningWindow = Duration(milliseconds: 2200);
  static const beatEveningWork = Duration(milliseconds: 2000);
  static const beatEveningRoutine = Duration(milliseconds: 2400);

  // Beat 9 — The Total
  static const totalElementStagger = Duration(milliseconds: 250);
  static const totalEveryDayDelay = Duration(milliseconds: 800);
  static const totalWeeklyDelay = Duration(milliseconds: 1200);
  static const totalHold = Duration(milliseconds: 2500);
  static const beatTotal = Duration(milliseconds: 5500);

  // ── Screen 10 — The Mirror ────────────────────────────────────────────────
  static const mirrorDimOverlay = Duration(milliseconds: 500);
  static const mirrorLine1FadeIn = Duration(milliseconds: 400);
  static const mirrorPause = Duration(milliseconds: 1000);
  static const mirrorLine2FadeIn = Duration(milliseconds: 400);
  static const mirrorHold = Duration(milliseconds: 2000);
  static const mirrorPhoneDrift = Duration(milliseconds: 1200);
  static const beatMirror = Duration(milliseconds: 4500);

  // ── Screen 11 — The Turn ──────────────────────────────────────────────────
  static const turnWordDelay = Duration(milliseconds: 80);
  static const turnLineFadeIn = Duration(milliseconds: 400);
  static const turnLineStagger = Duration(milliseconds: 600);
  static const turnHoldBeforeCta = Duration(milliseconds: 2000);
  static const turnCtaFadeIn = Duration(milliseconds: 400);

  // ── Screen 12 — Focus Filter ──────────────────────────────────────────────
  static const focusViewSwitch = Duration(milliseconds: 300);
  static const focusPreNavDelay = Duration(milliseconds: 430);

  // ── Screen 13 — Bridge ────────────────────────────────────────────────────
  static const bridgeLine1FadeIn = Duration(milliseconds: 400);
  static const bridgeCategoryPulse = Duration(milliseconds: 400);
  static const bridgeLine2Delay = Duration(milliseconds: 600);
  static const bridgeLine2FadeIn = Duration(milliseconds: 400);
  static const bridgeHold = Duration(milliseconds: 1500);
  static const bridgeAutoAdvance = Duration(milliseconds: 3500);

  // ── Screen 14 — Quickie Selection ─────────────────────────────────────────
  static const quickiesFeedbackSwitch = Duration(milliseconds: 240);
  static const quickiesPanelReveal = Duration(milliseconds: 420);
  static const quickiesActivityBubble = Duration(milliseconds: 260);

  // ── Screen 15 — The Reveal ────────────────────────────────────────────────
  static const revealCircleDraw = Duration(milliseconds: 1800);
  static const revealItemFlyIn = Duration(milliseconds: 500);
  static const revealItemStagger = Duration(milliseconds: 400);
  static const revealTextDelay = Duration(milliseconds: 600);
  static const revealTextFadeIn = Duration(milliseconds: 400);
  static const revealAutoAdvance = Duration(milliseconds: 5000);

  // ── Screen 16 — Brand Arrival ─────────────────────────────────────────────
  static const arrivalAnchorFadeIn = Duration(milliseconds: 500);
  static const arrivalAnchorHold = Duration(milliseconds: 400);
  static const arrivalTaglineFadeIn = Duration(milliseconds: 400);
  static const arrivalTaglineHold = Duration(milliseconds: 800);
  static const arrivalCtaFadeIn = Duration(milliseconds: 400);
  static const arrivalGradientFade = Duration(milliseconds: 1200);
}
