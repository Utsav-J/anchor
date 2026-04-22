import 'dart:convert';

/// Stores the user's ordered category priorities from the onboarding focus filter.
///
/// [orderedCategories] is a list of category names in priority order —
/// index 0 is P1 (highest weight), index N-1 is the lowest.
///
/// Weight formula (linear decay): for priority index [i] out of [total] selected,
///   weight = (total - i) / (total * (total + 1) / 2)
/// so P1 carries the most ownership weight and each subsequent priority carries less.
class FocusPriorityConfig {
  const FocusPriorityConfig({
    required this.orderedCategories,
    required this.setAt,
  });

  final List<String> orderedCategories;
  final DateTime setAt;

  static const int minSelections = 3;

  /// Linear decay weight for priority at [index] (0-based) given [total] selected.
  /// Returns a value in (0, 1]. All weights across [total] items sum to 1.0.
  static double weightForIndex(int index, int total) {
    assert(total > 0 && index >= 0 && index < total);
    final raw = total - index; // P1 = total, P2 = total-1, ..., PN = 1
    final sum = total * (total + 1) / 2;
    return raw / sum;
  }

  FocusPriorityConfig copyWith({
    List<String>? orderedCategories,
    DateTime? setAt,
  }) =>
      FocusPriorityConfig(
        orderedCategories: orderedCategories ?? this.orderedCategories,
        setAt: setAt ?? this.setAt,
      );

  Map<String, dynamic> toJson() => {
        'orderedCategories': orderedCategories,
        'setAt': setAt.toIso8601String(),
      };

  factory FocusPriorityConfig.fromJson(Map<String, dynamic> json) =>
      FocusPriorityConfig(
        orderedCategories:
            List<String>.from(json['orderedCategories'] as List),
        setAt: DateTime.parse(json['setAt'] as String),
      );

  /// Returns null if [raw] is null or cannot be decoded.
  static FocusPriorityConfig? tryDecode(String? raw) {
    if (raw == null) return null;
    try {
      return FocusPriorityConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
