import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/models/quick_activity_template.dart';
import 'quick_activity_catalog.dart';

class QuickiesOnboardingState {
  const QuickiesOnboardingState({
    this.openCategoryName,
    this.feedbackMessage,
    this.selectedOptionIds = const [],
  });

  final String? openCategoryName;
  final String? feedbackMessage;
  final List<String> selectedOptionIds;

  bool isSelected(String optionId) => selectedOptionIds.contains(optionId);

  QuickiesOnboardingState copyWith({
    String? openCategoryName,
    String? feedbackMessage,
    List<String>? selectedOptionIds,
  }) => QuickiesOnboardingState(
    openCategoryName: openCategoryName ?? this.openCategoryName,
    feedbackMessage: feedbackMessage ?? this.feedbackMessage,
    selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
  );
}

class QuickiesOnboardingNotifier
    extends StateNotifier<QuickiesOnboardingState> {
  QuickiesOnboardingNotifier() : super(const QuickiesOnboardingState());

  void openCategory(String categoryName) {
    state = QuickiesOnboardingState(
      openCategoryName: categoryName,
      selectedOptionIds: state.selectedOptionIds,
    );
  }

  void closeCategory() {
    state = QuickiesOnboardingState(selectedOptionIds: state.selectedOptionIds);
  }

  void saveOpenCategorySelection() {
    final selectedInOpenCategory = state.openCategoryName == null
        ? 0
        : state.selectedOptionIds
              .where((id) => id.startsWith(_prefixFor(state.openCategoryName!)))
              .length;

    state = QuickiesOnboardingState(
      feedbackMessage: selectedInOpenCategory > 1
          ? 'Way to go'
          : 'Great selection',
      selectedOptionIds: state.selectedOptionIds,
    );
  }

  void toggleOption(String optionId) {
    final selected = state.selectedOptionIds;
    state = state.copyWith(
      selectedOptionIds: selected.contains(optionId)
          ? selected.where((id) => id != optionId).toList(growable: false)
          : [...selected, optionId],
    );
  }

  List<QuickActivityOption> visibleOptionsFor(String categoryName) {
    final baseOptions = QuickActivityCatalog.initialOptionsForCategory(
      categoryName,
    );
    final relatedIds = state.selectedOptionIds
        .where((id) => id.startsWith(_prefixFor(categoryName)))
        .expand((id) => QuickActivityCatalog.optionById(id).relatedIds);

    final byId = <String, QuickActivityOption>{
      for (final option in baseOptions) option.id: option,
      for (final id in relatedIds) id: QuickActivityCatalog.optionById(id),
    };

    return byId.values.toList(growable: false);
  }

  List<QuickActivityTemplate> selectedTemplates() {
    return state.selectedOptionIds
        .map(QuickActivityCatalog.optionById)
        .map((option) => option.toTemplate())
        .toList(growable: false);
  }

  List<QuickActivityTemplate> selectedTemplatesForCategory(
    String categoryName,
  ) {
    return state.selectedOptionIds
        .map(QuickActivityCatalog.optionById)
        .where((option) => option.categoryName == categoryName)
        .map((option) => option.toTemplate())
        .toList(growable: false);
  }

  static String _prefixFor(String categoryName) {
    return categoryName.toLowerCase().split('-').first;
  }
}

final quickiesOnboardingProvider =
    StateNotifierProvider<QuickiesOnboardingNotifier, QuickiesOnboardingState>(
      (ref) => QuickiesOnboardingNotifier(),
    );

final onboardingQuickTemplatesProvider =
    StateProvider<List<QuickActivityTemplate>>((ref) => const []);
