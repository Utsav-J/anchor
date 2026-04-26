import 'package:anchor/features/onboarding/quickies/quickies_onboarding_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial category view hides related suggestions until selected', () {
    final notifier = QuickiesOnboardingNotifier();

    notifier.openCategory('Creative');

    final visibleLabels = notifier
        .visibleOptionsFor('Creative')
        .map((option) => option.label);

    expect(visibleLabels, contains('Practice an instrument'));
    expect(visibleLabels, isNot(contains('Practice guitar')));
    expect(visibleLabels, isNot(contains('Compose a melody')));
  });

  test('selecting an option exposes its related suggestions', () {
    final notifier = QuickiesOnboardingNotifier();

    notifier.openCategory('Creative');
    notifier.toggleOption('creative_practice_instrument');

    final visibleLabels = notifier
        .visibleOptionsFor('Creative')
        .map((option) => option.label);

    expect(visibleLabels, contains('Practice an instrument'));
    expect(visibleLabels, contains('Practice guitar'));
    expect(visibleLabels, contains('Compose a melody'));
  });

  test('saving a category selection closes it and shows reassurance', () {
    final notifier = QuickiesOnboardingNotifier();

    notifier.openCategory('Creative');
    notifier.toggleOption('creative_practice_instrument');
    notifier.saveOpenCategorySelection();

    expect(notifier.state.openCategoryName, isNull);
    expect(notifier.state.feedbackMessage, 'Great selection');
  });

  test('selected options convert to templates in tap order', () {
    final notifier = QuickiesOnboardingNotifier();

    notifier.toggleOption('creative_practice_instrument');
    notifier.toggleOption('creative_practice_guitar');

    final templates = notifier.selectedTemplates();

    expect(templates.map((template) => template.activityName), [
      'Practice an instrument',
      'Practice guitar',
    ]);
  });

  test('selected templates can be filtered to the open category', () {
    final notifier = QuickiesOnboardingNotifier();

    notifier.toggleOption('creative_practice_instrument');
    notifier.toggleOption('movement_walk_outside');

    final templates = notifier.selectedTemplatesForCategory('Creative');

    expect(templates, hasLength(1));
    expect(templates.single.activityName, 'Practice an instrument');
  });
}
