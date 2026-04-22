import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/focus_priority.dart';

const _kFocusPrefKey = 'anchor.focus_priorities';

enum FocusViewMode { bubble, list }

class FocusFilterState {
  const FocusFilterState({
    this.selected = const [],
    this.viewMode = FocusViewMode.bubble,
  });

  /// Category names ordered by priority — index 0 is P1.
  final List<String> selected;
  final FocusViewMode viewMode;

  bool get canContinue => selected.length >= FocusPriorityConfig.minSelections;

  /// Returns the 1-based priority of [name], or null if not selected.
  int? priorityOf(String name) {
    final i = selected.indexOf(name);
    return i == -1 ? null : i + 1;
  }

  FocusFilterState copyWith({
    List<String>? selected,
    FocusViewMode? viewMode,
  }) =>
      FocusFilterState(
        selected: selected ?? this.selected,
        viewMode: viewMode ?? this.viewMode,
      );
}

class FocusFilterNotifier extends StateNotifier<FocusFilterState> {
  FocusFilterNotifier() : super(const FocusFilterState());

  void select(String name) {
    if (state.selected.contains(name)) return;
    state = state.copyWith(selected: [...state.selected, name]);
  }

  void deselect(String name) {
    state = state.copyWith(
      selected: state.selected.where((n) => n != name).toList(),
    );
  }

  void reset() => state = state.copyWith(selected: []);

  void setViewMode(FocusViewMode mode) =>
      state = state.copyWith(viewMode: mode);

  /// Moves item at [oldIndex] to [newIndex] in the selected list.
  void reorder(int oldIndex, int newIndex) {
    final list = List<String>.from(state.selected);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(selected: list);
  }

  /// Persists the selection and returns the saved config.
  Future<FocusPriorityConfig> saveAndComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final config = FocusPriorityConfig(
      orderedCategories: List.unmodifiable(state.selected),
      setAt: DateTime.now(),
    );
    await prefs.setString(_kFocusPrefKey, jsonEncode(config.toJson()));
    return config;
  }
}

final focusFilterProvider =
    StateNotifierProvider<FocusFilterNotifier, FocusFilterState>(
  (ref) => FocusFilterNotifier(),
);

/// The currently active focus priority config, shared across the app.
/// Overridden at startup in main.dart from SharedPreferences.
/// Updated when onboarding completes or the user edits their focus in Me tab.
final activeFocusPriorityProvider =
    StateProvider<FocusPriorityConfig?>((ref) => null);

/// Reads any saved [FocusPriorityConfig] from SharedPreferences.
final savedFocusPriorityProvider =
    FutureProvider<FocusPriorityConfig?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return FocusPriorityConfig.tryDecode(prefs.getString(_kFocusPrefKey));
});
