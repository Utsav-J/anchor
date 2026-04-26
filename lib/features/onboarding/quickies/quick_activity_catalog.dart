import 'dart:convert';

import '../../../shared/models/quick_activity_template.dart';

class QuickActivityCategory {
  const QuickActivityCategory({
    required this.name,
    required this.headline,
    required this.prompt,
    required this.options,
  });

  final String name;
  final String headline;
  final String prompt;
  final List<QuickActivityOption> options;
}

class QuickActivityOption {
  const QuickActivityOption({
    required this.id,
    required this.categoryName,
    required this.label,
    required this.emoji,
    required this.relatedIds,
  });

  final String id;
  final String categoryName;
  final String label;
  final String emoji;
  final List<String> relatedIds;

  QuickActivityTemplate toTemplate() => QuickActivityTemplate(
    id: 'quickies_${categoryName}_$id',
    categoryName: categoryName,
    activityName: label,
    emoji: emoji,
    fields: const {},
  );
}

class QuickActivityCatalog {
  QuickActivityCatalog._();

  static List<QuickActivityCategory> categoriesFor(List<String> names) {
    final all = _categories;
    return names
        .map((name) => all.firstWhere((category) => category.name == name))
        .toList(growable: false);
  }

  static QuickActivityOption optionById(String id) {
    return _allOptions.firstWhere((option) => option.id == id);
  }

  static List<QuickActivityOption> optionsForCategory(String categoryName) {
    return _categories
        .firstWhere((category) => category.name == categoryName)
        .options;
  }

  static List<QuickActivityOption> initialOptionsForCategory(
    String categoryName,
  ) {
    final hiddenUntilRelated = _relatedOnlyOptionIds[categoryName] ?? const {};
    return optionsForCategory(categoryName)
        .where((option) => !hiddenUntilRelated.contains(option.id))
        .take(10)
        .toList(growable: false);
  }

  static List<QuickActivityOption> relatedOptionsFor(String optionId) {
    final option = optionById(optionId);
    return option.relatedIds.map(optionById).toList(growable: false);
  }

  static List<QuickActivityOption> get _allOptions => _categories
      .expand((category) => category.options)
      .toList(growable: false);

  static final List<QuickActivityCategory> _categories = _decodeCatalog();

  static const _relatedOnlyOptionIds = {
    'Creative': {
      'creative_practice_guitar',
      'creative_compose_melody',
      'creative_record_riff',
    },
  };

  static List<QuickActivityCategory> _decodeCatalog() {
    final data = jsonDecode(_catalogJson) as List<dynamic>;
    return data
        .map((categoryJson) {
          final category = categoryJson as Map<String, dynamic>;
          final name = category['name'] as String;
          final optionsJson = category['options'] as List<dynamic>;

          return QuickActivityCategory(
            name: name,
            headline: category['headline'] as String,
            prompt: category['prompt'] as String,
            options: optionsJson
                .map((optionJson) {
                  final option = optionJson as Map<String, dynamic>;
                  return QuickActivityOption(
                    id: option['id'] as String,
                    categoryName: name,
                    label: option['label'] as String,
                    emoji: option['emoji'] as String,
                    relatedIds: (option['related'] as List<dynamic>)
                        .map((id) => id as String)
                        .toList(growable: false),
                  );
                })
                .toList(growable: false),
          );
        })
        .toList(growable: false);
  }
}

const _catalogJson = '''
[
  {
    "name": "Creative",
    "headline": "Make something with your hands, voice, or imagination.",
    "prompt": "Choose the creative quickies you actually do.",
    "options": [
      {
        "id": "creative_practice_instrument",
        "label": "Practice an instrument",
        "emoji": "🎸",
        "related": [
          "creative_practice_guitar",
          "creative_compose_melody",
          "creative_record_riff"
        ]
      },
      {
        "id": "creative_practice_guitar",
        "label": "Practice guitar",
        "emoji": "🎸",
        "related": [
          "creative_practice_instrument",
          "creative_record_riff",
          "creative_compose_melody"
        ]
      },
      {
        "id": "creative_compose_melody",
        "label": "Compose a melody",
        "emoji": "🎼",
        "related": [
          "creative_record_riff",
          "creative_write_lyrics",
          "creative_practice_instrument"
        ]
      },
      {
        "id": "creative_record_riff",
        "label": "Record a riff",
        "emoji": "🎙️",
        "related": [
          "creative_compose_melody",
          "creative_practice_guitar",
          "creative_write_lyrics"
        ]
      },
      {
        "id": "creative_sketch_concept",
        "label": "Sketch a concept",
        "emoji": "✏️",
        "related": [
          "creative_paint_study",
          "creative_design_poster",
          "creative_write_scene"
        ]
      },
      {
        "id": "creative_paint_study",
        "label": "Paint a color study",
        "emoji": "🎨",
        "related": [
          "creative_sketch_concept",
          "creative_design_poster",
          "creative_make_photo_set"
        ]
      },
      {
        "id": "creative_write_scene",
        "label": "Write a short scene",
        "emoji": "📝",
        "related": [
          "creative_write_lyrics",
          "creative_sketch_concept",
          "creative_design_poster"
        ]
      },
      {
        "id": "creative_write_lyrics",
        "label": "Write lyrics",
        "emoji": "✍️",
        "related": [
          "creative_compose_melody",
          "creative_write_scene",
          "creative_record_riff"
        ]
      },
      {
        "id": "creative_design_poster",
        "label": "Design a poster",
        "emoji": "🖼️",
        "related": [
          "creative_sketch_concept",
          "creative_paint_study",
          "creative_make_photo_set"
        ]
      },
      {
        "id": "creative_make_photo_set",
        "label": "Make a photo set",
        "emoji": "📷",
        "related": [
          "creative_design_poster",
          "creative_paint_study",
          "creative_sketch_concept"
        ]
      }
    ]
  },
  {
    "name": "Movement",
    "headline": "Move energy through your body.",
    "prompt": "Pick movement quickies you can repeat often.",
    "options": [
      {
        "id": "movement_strength_circuit",
        "label": "Do a strength circuit",
        "emoji": "🏋️",
        "related": [
          "movement_pushup_set",
          "movement_core_flow",
          "movement_mobility_drill"
        ]
      },
      {
        "id": "movement_pushup_set",
        "label": "Complete a push-up set",
        "emoji": "💪",
        "related": [
          "movement_strength_circuit",
          "movement_core_flow",
          "movement_sprint_intervals"
        ]
      },
      {
        "id": "movement_mobility_drill",
        "label": "Run a mobility drill",
        "emoji": "🤸",
        "related": [
          "movement_yoga_sequence",
          "movement_core_flow",
          "movement_walk_outside"
        ]
      },
      {
        "id": "movement_yoga_sequence",
        "label": "Practice a yoga sequence",
        "emoji": "🧘",
        "related": [
          "movement_mobility_drill",
          "movement_breath_walk",
          "movement_core_flow"
        ]
      },
      {
        "id": "movement_sprint_intervals",
        "label": "Run sprint intervals",
        "emoji": "🏃",
        "related": [
          "movement_walk_outside",
          "movement_cycle_ride",
          "movement_pushup_set"
        ]
      },
      {
        "id": "movement_walk_outside",
        "label": "Walk outside",
        "emoji": "🚶",
        "related": [
          "movement_breath_walk",
          "movement_sprint_intervals",
          "movement_mobility_drill"
        ]
      },
      {
        "id": "movement_cycle_ride",
        "label": "Take a cycle ride",
        "emoji": "🚴",
        "related": [
          "movement_sprint_intervals",
          "movement_walk_outside",
          "movement_strength_circuit"
        ]
      },
      {
        "id": "movement_core_flow",
        "label": "Do a core flow",
        "emoji": "🔥",
        "related": [
          "movement_strength_circuit",
          "movement_pushup_set",
          "movement_yoga_sequence"
        ]
      },
      {
        "id": "movement_breath_walk",
        "label": "Do a breath walk",
        "emoji": "🌬️",
        "related": [
          "movement_walk_outside",
          "movement_yoga_sequence",
          "movement_mobility_drill"
        ]
      }
    ]
  },
  {
    "name": "Reflective",
    "headline": "Turn attention into clarity.",
    "prompt": "Choose reflective practices that produce insight.",
    "options": [
      {
        "id": "reflective_journal_prompt",
        "label": "Answer a journal prompt",
        "emoji": "📓",
        "related": [
          "reflective_review_day",
          "reflective_write_gratitude",
          "reflective_map_feeling"
        ]
      },
      {
        "id": "reflective_review_day",
        "label": "Review the day",
        "emoji": "🧭",
        "related": [
          "reflective_journal_prompt",
          "reflective_plan_intention",
          "reflective_name_lesson"
        ]
      },
      {
        "id": "reflective_plan_intention",
        "label": "Set an intention",
        "emoji": "🎯",
        "related": [
          "reflective_review_day",
          "reflective_focus_breath",
          "reflective_name_lesson"
        ]
      },
      {
        "id": "reflective_write_gratitude",
        "label": "Write gratitude notes",
        "emoji": "🙏",
        "related": [
          "reflective_journal_prompt",
          "reflective_map_feeling",
          "reflective_name_lesson"
        ]
      },
      {
        "id": "reflective_map_feeling",
        "label": "Map a feeling",
        "emoji": "🪞",
        "related": [
          "reflective_journal_prompt",
          "reflective_focus_breath",
          "reflective_write_gratitude"
        ]
      },
      {
        "id": "reflective_focus_breath",
        "label": "Practice focused breathing",
        "emoji": "🌿",
        "related": [
          "reflective_plan_intention",
          "reflective_map_feeling",
          "reflective_review_day"
        ]
      },
      {
        "id": "reflective_name_lesson",
        "label": "Name one lesson",
        "emoji": "💡",
        "related": [
          "reflective_review_day",
          "reflective_journal_prompt",
          "reflective_plan_intention"
        ]
      }
    ]
  },
  {
    "name": "Skill-Building",
    "headline": "Build ability in small reps.",
    "prompt": "Pick active learning reps, not passive consumption.",
    "options": [
      {
        "id": "skill_code_drill",
        "label": "Complete a coding drill",
        "emoji": "💻",
        "related": [
          "skill_build_project_slice",
          "skill_debug_problem",
          "skill_write_flashcards"
        ]
      },
      {
        "id": "skill_build_project_slice",
        "label": "Build a project slice",
        "emoji": "🧩",
        "related": [
          "skill_code_drill",
          "skill_debug_problem",
          "skill_practice_tutorial_task"
        ]
      },
      {
        "id": "skill_debug_problem",
        "label": "Debug one problem",
        "emoji": "🛠️",
        "related": [
          "skill_code_drill",
          "skill_build_project_slice",
          "skill_explain_concept"
        ]
      },
      {
        "id": "skill_practice_language",
        "label": "Practice a language drill",
        "emoji": "🗣️",
        "related": [
          "skill_write_flashcards",
          "skill_explain_concept",
          "skill_solve_exercise"
        ]
      },
      {
        "id": "skill_write_flashcards",
        "label": "Write flashcards",
        "emoji": "🃏",
        "related": [
          "skill_practice_language",
          "skill_explain_concept",
          "skill_solve_exercise"
        ]
      },
      {
        "id": "skill_solve_exercise",
        "label": "Solve practice exercises",
        "emoji": "📚",
        "related": [
          "skill_practice_language",
          "skill_write_flashcards",
          "skill_code_drill"
        ]
      },
      {
        "id": "skill_explain_concept",
        "label": "Explain a concept aloud",
        "emoji": "🎙️",
        "related": [
          "skill_debug_problem",
          "skill_write_flashcards",
          "skill_solve_exercise"
        ]
      },
      {
        "id": "skill_practice_tutorial_task",
        "label": "Rebuild a tutorial step",
        "emoji": "🎯",
        "related": [
          "skill_build_project_slice",
          "skill_code_drill",
          "skill_solve_exercise"
        ]
      }
    ]
  },
  {
    "name": "Environment-Shaping",
    "headline": "Change the space so action gets easier.",
    "prompt": "Select the shaping reps that reset your surroundings.",
    "options": [
      {
        "id": "environment_clear_surface",
        "label": "Clear one surface",
        "emoji": "🧹",
        "related": [
          "environment_reset_desk",
          "environment_prepare_workstation",
          "environment_sort_drawer"
        ]
      },
      {
        "id": "environment_reset_desk",
        "label": "Reset your desk",
        "emoji": "🖥️",
        "related": [
          "environment_clear_surface",
          "environment_prepare_workstation",
          "environment_remove_distraction"
        ]
      },
      {
        "id": "environment_prepare_workstation",
        "label": "Prepare a workstation",
        "emoji": "⚙️",
        "related": [
          "environment_reset_desk",
          "environment_stage_tomorrow",
          "environment_remove_distraction"
        ]
      },
      {
        "id": "environment_stage_tomorrow",
        "label": "Stage tomorrow's setup",
        "emoji": "🌅",
        "related": [
          "environment_prepare_workstation",
          "environment_pack_bag",
          "environment_reset_desk"
        ]
      },
      {
        "id": "environment_pack_bag",
        "label": "Pack a go bag",
        "emoji": "🎒",
        "related": [
          "environment_stage_tomorrow",
          "environment_sort_drawer",
          "environment_prepare_workstation"
        ]
      },
      {
        "id": "environment_sort_drawer",
        "label": "Sort a drawer",
        "emoji": "🗂️",
        "related": [
          "environment_clear_surface",
          "environment_pack_bag",
          "environment_reset_desk"
        ]
      },
      {
        "id": "environment_remove_distraction",
        "label": "Remove a distraction",
        "emoji": "📵",
        "related": [
          "environment_reset_desk",
          "environment_prepare_workstation",
          "environment_clear_surface"
        ]
      }
    ]
  },
  {
    "name": "Future-Oriented",
    "headline": "Turn the future into the next visible move.",
    "prompt": "Choose planning actions that create momentum.",
    "options": [
      {
        "id": "future_define_next_step",
        "label": "Define the next step",
        "emoji": "➡️",
        "related": [
          "future_plan_week",
          "future_map_goal",
          "future_schedule_block"
        ]
      },
      {
        "id": "future_plan_week",
        "label": "Plan the week",
        "emoji": "🗓️",
        "related": [
          "future_define_next_step",
          "future_schedule_block",
          "future_review_goal"
        ]
      },
      {
        "id": "future_schedule_block",
        "label": "Schedule a focus block",
        "emoji": "⏱️",
        "related": [
          "future_plan_week",
          "future_define_next_step",
          "future_prepare_pitch"
        ]
      },
      {
        "id": "future_map_goal",
        "label": "Map a goal path",
        "emoji": "🗺️",
        "related": [
          "future_define_next_step",
          "future_review_goal",
          "future_prepare_pitch"
        ]
      },
      {
        "id": "future_review_goal",
        "label": "Review one goal",
        "emoji": "🔭",
        "related": [
          "future_map_goal",
          "future_plan_week",
          "future_define_next_step"
        ]
      },
      {
        "id": "future_prepare_pitch",
        "label": "Prepare a pitch",
        "emoji": "🚀",
        "related": [
          "future_map_goal",
          "future_schedule_block",
          "future_define_next_step"
        ]
      }
    ]
  },
  {
    "name": "Connection",
    "headline": "Make contact, repair, and contribute.",
    "prompt": "Pick active connection quickies.",
    "options": [
      {
        "id": "connection_send_checkin",
        "label": "Send a check-in",
        "emoji": "💬",
        "related": [
          "connection_call_friend",
          "connection_write_thank_you",
          "connection_plan_meetup"
        ]
      },
      {
        "id": "connection_call_friend",
        "label": "Call a friend",
        "emoji": "📞",
        "related": [
          "connection_send_checkin",
          "connection_plan_meetup",
          "connection_offer_help"
        ]
      },
      {
        "id": "connection_write_thank_you",
        "label": "Write a thank-you note",
        "emoji": "💛",
        "related": [
          "connection_send_checkin",
          "connection_offer_help",
          "connection_repair_message"
        ]
      },
      {
        "id": "connection_plan_meetup",
        "label": "Plan a meetup",
        "emoji": "🤝",
        "related": [
          "connection_call_friend",
          "connection_send_checkin",
          "connection_host_small_gathering"
        ]
      },
      {
        "id": "connection_offer_help",
        "label": "Offer concrete help",
        "emoji": "🙌",
        "related": [
          "connection_write_thank_you",
          "connection_call_friend",
          "connection_repair_message"
        ]
      },
      {
        "id": "connection_repair_message",
        "label": "Send a repair message",
        "emoji": "🕊️",
        "related": [
          "connection_write_thank_you",
          "connection_offer_help",
          "connection_call_friend"
        ]
      },
      {
        "id": "connection_host_small_gathering",
        "label": "Host a small gathering",
        "emoji": "🏡",
        "related": [
          "connection_plan_meetup",
          "connection_offer_help",
          "connection_send_checkin"
        ]
      }
    ]
  }
]
''';
