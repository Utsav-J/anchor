/// SVG assets for focus categories (from design export in content.txt).
abstract final class FocusFilterCategoryIcons {
  static String svgPath(String categoryName) {
    const paths = {
      'Creative': 'assets/focus_filter/creative.svg',
      'Movement': 'assets/focus_filter/movement.svg',
      'Reflective': 'assets/focus_filter/reflective.svg',
      'Skill-Building': 'assets/focus_filter/skill_building.svg',
      'Environment-Shaping': 'assets/focus_filter/environment_shaping.svg',
      'Future-Oriented': 'assets/focus_filter/future_oriented.svg',
      'Connection': 'assets/focus_filter/connection.svg',
    };
    return paths[categoryName] ?? paths['Creative']!;
  }
}
