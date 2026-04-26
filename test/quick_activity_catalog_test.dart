import 'package:anchor/features/onboarding/quickies/quick_activity_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns only selected focus categories in priority order', () {
    final categories = QuickActivityCatalog.categoriesFor([
      'Creative',
      'Movement',
      'Connection',
    ]);

    expect(categories.map((category) => category.name), [
      'Creative',
      'Movement',
      'Connection',
    ]);
  });

  test('creative instrument selection reveals related active suggestions', () {
    final related = QuickActivityCatalog.relatedOptionsFor(
      'creative_practice_instrument',
    );

    expect(related.map((option) => option.label), contains('Practice guitar'));
    expect(related.map((option) => option.label), contains('Compose a melody'));
    expect(
      related.map((option) => option.label),
      isNot(contains('Listen to music')),
    );
  });

  test('activity options convert to quick activity templates', () {
    final option = QuickActivityCatalog.optionById(
      'creative_practice_instrument',
    );

    final template = option.toTemplate();

    expect(template.categoryName, 'Creative');
    expect(template.activityName, 'Practice an instrument');
    expect(template.id, startsWith('quickies_Creative_'));
  });
}
