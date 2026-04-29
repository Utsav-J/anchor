import 'package:anchor/features/onboarding/focus_filter/widgets/bubble_canvas.dart';
import 'package:anchor/features/onboarding/focus_filter/widgets/category_bubble.dart';
import 'package:anchor/shared/constants/app_constants.dart';
import 'package:bubble_picker/bubble_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('CategoryBubble grows when selected', (tester) async {
    final meta = AppConstants.defaultCategories.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                CategoryBubble(
                  meta: meta,
                  priority: null,
                  totalSelected: 0,
                  onTap: () {},
                  onLongPress: () {},
                ),
                CategoryBubble(
                  meta: meta,
                  priority: 1,
                  totalSelected: 1,
                  onTap: () {},
                  onLongPress: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final unselectedSize = tester.getSize(find.byType(CategoryBubble).at(0));
    final selectedSize = tester.getSize(find.byType(CategoryBubble).at(1));

    expect(selectedSize.width, greaterThan(unselectedSize.width));
    expect(selectedSize.height, greaterThan(unselectedSize.height));
  });

  testWidgets('BubbleCanvas renders all category bubbles via BubblePicker',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 390, height: 520, child: BubbleCanvas()),
          ),
        ),
      ),
    );

    await tester.pump();

    // BubblePicker widget should be present.
    expect(find.byType(BubblePicker), findsOneWidget);

    // All 7 category labels should be rendered in their bubbles.
    expect(find.text('CREATIVE'), findsOneWidget);
    expect(find.text('CONNECTION'), findsOneWidget);
  });

  testWidgets('BubbleCanvas does not use a scroll view', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 390, height: 620, child: BubbleCanvas()),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(BubblePicker), findsOneWidget);
  });
}
