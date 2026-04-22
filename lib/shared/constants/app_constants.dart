import 'package:flutter/material.dart';

class CategoryMeta {
  const CategoryMeta({
    required this.name,
    required this.subtitle,
    required this.defaultEmoji,
    required this.quickEmojis,
    required this.icon,
  });

  final String name;
  final String subtitle;
  final String defaultEmoji;
  final List<String> quickEmojis;
  final IconData icon;
}

class AppConstants {
  AppConstants._();

  static const List<CategoryMeta> defaultCategories = [
    CategoryMeta(
      name: 'Creative',
      subtitle: 'Expression and making',
      defaultEmoji: '🎨',
      quickEmojis: ['🎨', '✏️', '🖌️', '💡', '🎭'],
      icon: Icons.palette_outlined,
    ),
    CategoryMeta(
      name: 'Movement',
      subtitle: 'Body and energy',
      defaultEmoji: '🏃',
      quickEmojis: ['🏃', '🧘', '🚴', '🏊', '🤸'],
      icon: Icons.directions_run_outlined,
    ),
    CategoryMeta(
      name: 'Reflective',
      subtitle: 'Stillness and clarity',
      defaultEmoji: '🪞',
      quickEmojis: ['🪞', '📓', '🤔', '🧠', '🌿'],
      icon: Icons.self_improvement_outlined,
    ),
    CategoryMeta(
      name: 'Skill-Building',
      subtitle: 'Learning and growth',
      defaultEmoji: '📚',
      quickEmojis: ['📚', '💻', '🛠️', '📈', '🎯'],
      icon: Icons.school_outlined,
    ),
    CategoryMeta(
      name: 'Environment-Shaping',
      subtitle: 'Space and systems',
      defaultEmoji: '🌱',
      quickEmojis: ['🌱', '🏡', '🧹', '✨', '🪴'],
      icon: Icons.eco_outlined,
    ),
    CategoryMeta(
      name: 'Future-Oriented',
      subtitle: 'Vision and planning',
      defaultEmoji: '🔭',
      quickEmojis: ['🔭', '🗺️', '🎯', '💭', '🚀'],
      icon: Icons.explore_outlined,
    ),
    CategoryMeta(
      name: 'Connection',
      subtitle: 'People and presence',
      defaultEmoji: '💛',
      quickEmojis: ['💛', '🤝', '📞', '👥', '❤️'],
      icon: Icons.people_outline,
    ),
  ];

  static const String footerQuote =
      '"The secret of your future is hidden in your daily routine."';
}
