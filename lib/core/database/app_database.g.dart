// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivityLogEntriesTable extends ActivityLogEntries
    with TableInfo<$ActivityLogEntriesTable, ActivityLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityNameMeta = const VerificationMeta(
    'activityName',
  );
  @override
  late final GeneratedColumn<String> activityName = GeneratedColumn<String>(
    'activity_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postFieldsJsonMeta = const VerificationMeta(
    'postFieldsJson',
  );
  @override
  late final GeneratedColumn<String> postFieldsJson = GeneratedColumn<String>(
    'post_fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controlScoreMeta = const VerificationMeta(
    'controlScore',
  );
  @override
  late final GeneratedColumn<int> controlScore = GeneratedColumn<int>(
    'control_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    categoryName,
    activityName,
    emoji,
    loggedAt,
    postFieldsJson,
    controlScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('activity_name')) {
      context.handle(
        _activityNameMeta,
        activityName.isAcceptableOrUnknown(
          data['activity_name']!,
          _activityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityNameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('post_fields_json')) {
      context.handle(
        _postFieldsJsonMeta,
        postFieldsJson.isAcceptableOrUnknown(
          data['post_fields_json']!,
          _postFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postFieldsJsonMeta);
    }
    if (data.containsKey('control_score')) {
      context.handle(
        _controlScoreMeta,
        controlScore.isAcceptableOrUnknown(
          data['control_score']!,
          _controlScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_controlScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      activityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      postFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_fields_json'],
      )!,
      controlScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}control_score'],
      )!,
    );
  }

  @override
  $ActivityLogEntriesTable createAlias(String alias) {
    return $ActivityLogEntriesTable(attachedDatabase, alias);
  }
}

class ActivityLogEntry extends DataClass
    implements Insertable<ActivityLogEntry> {
  final String id;
  final String templateId;
  final String categoryName;
  final String activityName;
  final String emoji;
  final DateTime loggedAt;
  final String postFieldsJson;
  final int controlScore;
  const ActivityLogEntry({
    required this.id,
    required this.templateId,
    required this.categoryName,
    required this.activityName,
    required this.emoji,
    required this.loggedAt,
    required this.postFieldsJson,
    required this.controlScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['category_name'] = Variable<String>(categoryName);
    map['activity_name'] = Variable<String>(activityName);
    map['emoji'] = Variable<String>(emoji);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['post_fields_json'] = Variable<String>(postFieldsJson);
    map['control_score'] = Variable<int>(controlScore);
    return map;
  }

  ActivityLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogEntriesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      categoryName: Value(categoryName),
      activityName: Value(activityName),
      emoji: Value(emoji),
      loggedAt: Value(loggedAt),
      postFieldsJson: Value(postFieldsJson),
      controlScore: Value(controlScore),
    );
  }

  factory ActivityLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogEntry(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      activityName: serializer.fromJson<String>(json['activityName']),
      emoji: serializer.fromJson<String>(json['emoji']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      postFieldsJson: serializer.fromJson<String>(json['postFieldsJson']),
      controlScore: serializer.fromJson<int>(json['controlScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'categoryName': serializer.toJson<String>(categoryName),
      'activityName': serializer.toJson<String>(activityName),
      'emoji': serializer.toJson<String>(emoji),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'postFieldsJson': serializer.toJson<String>(postFieldsJson),
      'controlScore': serializer.toJson<int>(controlScore),
    };
  }

  ActivityLogEntry copyWith({
    String? id,
    String? templateId,
    String? categoryName,
    String? activityName,
    String? emoji,
    DateTime? loggedAt,
    String? postFieldsJson,
    int? controlScore,
  }) => ActivityLogEntry(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    categoryName: categoryName ?? this.categoryName,
    activityName: activityName ?? this.activityName,
    emoji: emoji ?? this.emoji,
    loggedAt: loggedAt ?? this.loggedAt,
    postFieldsJson: postFieldsJson ?? this.postFieldsJson,
    controlScore: controlScore ?? this.controlScore,
  );
  ActivityLogEntry copyWithCompanion(ActivityLogEntriesCompanion data) {
    return ActivityLogEntry(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      activityName: data.activityName.present
          ? data.activityName.value
          : this.activityName,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      postFieldsJson: data.postFieldsJson.present
          ? data.postFieldsJson.value
          : this.postFieldsJson,
      controlScore: data.controlScore.present
          ? data.controlScore.value
          : this.controlScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogEntry(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('activityName: $activityName, ')
          ..write('emoji: $emoji, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('postFieldsJson: $postFieldsJson, ')
          ..write('controlScore: $controlScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    categoryName,
    activityName,
    emoji,
    loggedAt,
    postFieldsJson,
    controlScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogEntry &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.categoryName == this.categoryName &&
          other.activityName == this.activityName &&
          other.emoji == this.emoji &&
          other.loggedAt == this.loggedAt &&
          other.postFieldsJson == this.postFieldsJson &&
          other.controlScore == this.controlScore);
}

class ActivityLogEntriesCompanion extends UpdateCompanion<ActivityLogEntry> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> categoryName;
  final Value<String> activityName;
  final Value<String> emoji;
  final Value<DateTime> loggedAt;
  final Value<String> postFieldsJson;
  final Value<int> controlScore;
  final Value<int> rowid;
  const ActivityLogEntriesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.activityName = const Value.absent(),
    this.emoji = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.postFieldsJson = const Value.absent(),
    this.controlScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityLogEntriesCompanion.insert({
    required String id,
    required String templateId,
    required String categoryName,
    required String activityName,
    required String emoji,
    required DateTime loggedAt,
    required String postFieldsJson,
    required int controlScore,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       categoryName = Value(categoryName),
       activityName = Value(activityName),
       emoji = Value(emoji),
       loggedAt = Value(loggedAt),
       postFieldsJson = Value(postFieldsJson),
       controlScore = Value(controlScore);
  static Insertable<ActivityLogEntry> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? categoryName,
    Expression<String>? activityName,
    Expression<String>? emoji,
    Expression<DateTime>? loggedAt,
    Expression<String>? postFieldsJson,
    Expression<int>? controlScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (categoryName != null) 'category_name': categoryName,
      if (activityName != null) 'activity_name': activityName,
      if (emoji != null) 'emoji': emoji,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (postFieldsJson != null) 'post_fields_json': postFieldsJson,
      if (controlScore != null) 'control_score': controlScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityLogEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? categoryName,
    Value<String>? activityName,
    Value<String>? emoji,
    Value<DateTime>? loggedAt,
    Value<String>? postFieldsJson,
    Value<int>? controlScore,
    Value<int>? rowid,
  }) {
    return ActivityLogEntriesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      categoryName: categoryName ?? this.categoryName,
      activityName: activityName ?? this.activityName,
      emoji: emoji ?? this.emoji,
      loggedAt: loggedAt ?? this.loggedAt,
      postFieldsJson: postFieldsJson ?? this.postFieldsJson,
      controlScore: controlScore ?? this.controlScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (activityName.present) {
      map['activity_name'] = Variable<String>(activityName.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (postFieldsJson.present) {
      map['post_fields_json'] = Variable<String>(postFieldsJson.value);
    }
    if (controlScore.present) {
      map['control_score'] = Variable<int>(controlScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('activityName: $activityName, ')
          ..write('emoji: $emoji, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('postFieldsJson: $postFieldsJson, ')
          ..write('controlScore: $controlScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickTemplateEntriesTable extends QuickTemplateEntries
    with TableInfo<$QuickTemplateEntriesTable, QuickTemplateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickTemplateEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityNameMeta = const VerificationMeta(
    'activityName',
  );
  @override
  late final GeneratedColumn<String> activityName = GeneratedColumn<String>(
    'activity_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryName,
    activityName,
    emoji,
    fieldsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_template_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickTemplateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('activity_name')) {
      context.handle(
        _activityNameMeta,
        activityName.isAcceptableOrUnknown(
          data['activity_name']!,
          _activityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityNameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickTemplateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickTemplateEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      activityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
    );
  }

  @override
  $QuickTemplateEntriesTable createAlias(String alias) {
    return $QuickTemplateEntriesTable(attachedDatabase, alias);
  }
}

class QuickTemplateEntry extends DataClass
    implements Insertable<QuickTemplateEntry> {
  final String id;
  final String categoryName;
  final String activityName;
  final String emoji;
  final String fieldsJson;
  const QuickTemplateEntry({
    required this.id,
    required this.categoryName,
    required this.activityName,
    required this.emoji,
    required this.fieldsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_name'] = Variable<String>(categoryName);
    map['activity_name'] = Variable<String>(activityName);
    map['emoji'] = Variable<String>(emoji);
    map['fields_json'] = Variable<String>(fieldsJson);
    return map;
  }

  QuickTemplateEntriesCompanion toCompanion(bool nullToAbsent) {
    return QuickTemplateEntriesCompanion(
      id: Value(id),
      categoryName: Value(categoryName),
      activityName: Value(activityName),
      emoji: Value(emoji),
      fieldsJson: Value(fieldsJson),
    );
  }

  factory QuickTemplateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickTemplateEntry(
      id: serializer.fromJson<String>(json['id']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      activityName: serializer.fromJson<String>(json['activityName']),
      emoji: serializer.fromJson<String>(json['emoji']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryName': serializer.toJson<String>(categoryName),
      'activityName': serializer.toJson<String>(activityName),
      'emoji': serializer.toJson<String>(emoji),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
    };
  }

  QuickTemplateEntry copyWith({
    String? id,
    String? categoryName,
    String? activityName,
    String? emoji,
    String? fieldsJson,
  }) => QuickTemplateEntry(
    id: id ?? this.id,
    categoryName: categoryName ?? this.categoryName,
    activityName: activityName ?? this.activityName,
    emoji: emoji ?? this.emoji,
    fieldsJson: fieldsJson ?? this.fieldsJson,
  );
  QuickTemplateEntry copyWithCompanion(QuickTemplateEntriesCompanion data) {
    return QuickTemplateEntry(
      id: data.id.present ? data.id.value : this.id,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      activityName: data.activityName.present
          ? data.activityName.value
          : this.activityName,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickTemplateEntry(')
          ..write('id: $id, ')
          ..write('categoryName: $categoryName, ')
          ..write('activityName: $activityName, ')
          ..write('emoji: $emoji, ')
          ..write('fieldsJson: $fieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryName, activityName, emoji, fieldsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickTemplateEntry &&
          other.id == this.id &&
          other.categoryName == this.categoryName &&
          other.activityName == this.activityName &&
          other.emoji == this.emoji &&
          other.fieldsJson == this.fieldsJson);
}

class QuickTemplateEntriesCompanion
    extends UpdateCompanion<QuickTemplateEntry> {
  final Value<String> id;
  final Value<String> categoryName;
  final Value<String> activityName;
  final Value<String> emoji;
  final Value<String> fieldsJson;
  final Value<int> rowid;
  const QuickTemplateEntriesCompanion({
    this.id = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.activityName = const Value.absent(),
    this.emoji = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuickTemplateEntriesCompanion.insert({
    required String id,
    required String categoryName,
    required String activityName,
    required String emoji,
    required String fieldsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryName = Value(categoryName),
       activityName = Value(activityName),
       emoji = Value(emoji),
       fieldsJson = Value(fieldsJson);
  static Insertable<QuickTemplateEntry> custom({
    Expression<String>? id,
    Expression<String>? categoryName,
    Expression<String>? activityName,
    Expression<String>? emoji,
    Expression<String>? fieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryName != null) 'category_name': categoryName,
      if (activityName != null) 'activity_name': activityName,
      if (emoji != null) 'emoji': emoji,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuickTemplateEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryName,
    Value<String>? activityName,
    Value<String>? emoji,
    Value<String>? fieldsJson,
    Value<int>? rowid,
  }) {
    return QuickTemplateEntriesCompanion(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      activityName: activityName ?? this.activityName,
      emoji: emoji ?? this.emoji,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (activityName.present) {
      map['activity_name'] = Variable<String>(activityName.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickTemplateEntriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryName: $categoryName, ')
          ..write('activityName: $activityName, ')
          ..write('emoji: $emoji, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekSummaryEntriesTable extends WeekSummaryEntries
    with TableInfo<$WeekSummaryEntriesTable, WeekSummaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekSummaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownershipRatioMeta = const VerificationMeta(
    'ownershipRatio',
  );
  @override
  late final GeneratedColumn<double> ownershipRatio = GeneratedColumn<double>(
    'ownership_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriesLoggedMeta = const VerificationMeta(
    'categoriesLogged',
  );
  @override
  late final GeneratedColumn<int> categoriesLogged = GeneratedColumn<int>(
    'categories_logged',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageControlScoreMeta =
      const VerificationMeta('averageControlScore');
  @override
  late final GeneratedColumn<double> averageControlScore =
      GeneratedColumn<double>(
        'average_control_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    weekStart,
    ownershipRatio,
    categoriesLogged,
    averageControlScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_summary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekSummaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('ownership_ratio')) {
      context.handle(
        _ownershipRatioMeta,
        ownershipRatio.isAcceptableOrUnknown(
          data['ownership_ratio']!,
          _ownershipRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownershipRatioMeta);
    }
    if (data.containsKey('categories_logged')) {
      context.handle(
        _categoriesLoggedMeta,
        categoriesLogged.isAcceptableOrUnknown(
          data['categories_logged']!,
          _categoriesLoggedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriesLoggedMeta);
    }
    if (data.containsKey('average_control_score')) {
      context.handle(
        _averageControlScoreMeta,
        averageControlScore.isAcceptableOrUnknown(
          data['average_control_score']!,
          _averageControlScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageControlScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  WeekSummaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekSummaryEntry(
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      ownershipRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ownership_ratio'],
      )!,
      categoriesLogged: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categories_logged'],
      )!,
      averageControlScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_control_score'],
      )!,
    );
  }

  @override
  $WeekSummaryEntriesTable createAlias(String alias) {
    return $WeekSummaryEntriesTable(attachedDatabase, alias);
  }
}

class WeekSummaryEntry extends DataClass
    implements Insertable<WeekSummaryEntry> {
  final DateTime weekStart;
  final double ownershipRatio;
  final int categoriesLogged;
  final double averageControlScore;
  const WeekSummaryEntry({
    required this.weekStart,
    required this.ownershipRatio,
    required this.categoriesLogged,
    required this.averageControlScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['week_start'] = Variable<DateTime>(weekStart);
    map['ownership_ratio'] = Variable<double>(ownershipRatio);
    map['categories_logged'] = Variable<int>(categoriesLogged);
    map['average_control_score'] = Variable<double>(averageControlScore);
    return map;
  }

  WeekSummaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeekSummaryEntriesCompanion(
      weekStart: Value(weekStart),
      ownershipRatio: Value(ownershipRatio),
      categoriesLogged: Value(categoriesLogged),
      averageControlScore: Value(averageControlScore),
    );
  }

  factory WeekSummaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekSummaryEntry(
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      ownershipRatio: serializer.fromJson<double>(json['ownershipRatio']),
      categoriesLogged: serializer.fromJson<int>(json['categoriesLogged']),
      averageControlScore: serializer.fromJson<double>(
        json['averageControlScore'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'ownershipRatio': serializer.toJson<double>(ownershipRatio),
      'categoriesLogged': serializer.toJson<int>(categoriesLogged),
      'averageControlScore': serializer.toJson<double>(averageControlScore),
    };
  }

  WeekSummaryEntry copyWith({
    DateTime? weekStart,
    double? ownershipRatio,
    int? categoriesLogged,
    double? averageControlScore,
  }) => WeekSummaryEntry(
    weekStart: weekStart ?? this.weekStart,
    ownershipRatio: ownershipRatio ?? this.ownershipRatio,
    categoriesLogged: categoriesLogged ?? this.categoriesLogged,
    averageControlScore: averageControlScore ?? this.averageControlScore,
  );
  WeekSummaryEntry copyWithCompanion(WeekSummaryEntriesCompanion data) {
    return WeekSummaryEntry(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      ownershipRatio: data.ownershipRatio.present
          ? data.ownershipRatio.value
          : this.ownershipRatio,
      categoriesLogged: data.categoriesLogged.present
          ? data.categoriesLogged.value
          : this.categoriesLogged,
      averageControlScore: data.averageControlScore.present
          ? data.averageControlScore.value
          : this.averageControlScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekSummaryEntry(')
          ..write('weekStart: $weekStart, ')
          ..write('ownershipRatio: $ownershipRatio, ')
          ..write('categoriesLogged: $categoriesLogged, ')
          ..write('averageControlScore: $averageControlScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    weekStart,
    ownershipRatio,
    categoriesLogged,
    averageControlScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekSummaryEntry &&
          other.weekStart == this.weekStart &&
          other.ownershipRatio == this.ownershipRatio &&
          other.categoriesLogged == this.categoriesLogged &&
          other.averageControlScore == this.averageControlScore);
}

class WeekSummaryEntriesCompanion extends UpdateCompanion<WeekSummaryEntry> {
  final Value<DateTime> weekStart;
  final Value<double> ownershipRatio;
  final Value<int> categoriesLogged;
  final Value<double> averageControlScore;
  final Value<int> rowid;
  const WeekSummaryEntriesCompanion({
    this.weekStart = const Value.absent(),
    this.ownershipRatio = const Value.absent(),
    this.categoriesLogged = const Value.absent(),
    this.averageControlScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekSummaryEntriesCompanion.insert({
    required DateTime weekStart,
    required double ownershipRatio,
    required int categoriesLogged,
    required double averageControlScore,
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       ownershipRatio = Value(ownershipRatio),
       categoriesLogged = Value(categoriesLogged),
       averageControlScore = Value(averageControlScore);
  static Insertable<WeekSummaryEntry> custom({
    Expression<DateTime>? weekStart,
    Expression<double>? ownershipRatio,
    Expression<int>? categoriesLogged,
    Expression<double>? averageControlScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (ownershipRatio != null) 'ownership_ratio': ownershipRatio,
      if (categoriesLogged != null) 'categories_logged': categoriesLogged,
      if (averageControlScore != null)
        'average_control_score': averageControlScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekSummaryEntriesCompanion copyWith({
    Value<DateTime>? weekStart,
    Value<double>? ownershipRatio,
    Value<int>? categoriesLogged,
    Value<double>? averageControlScore,
    Value<int>? rowid,
  }) {
    return WeekSummaryEntriesCompanion(
      weekStart: weekStart ?? this.weekStart,
      ownershipRatio: ownershipRatio ?? this.ownershipRatio,
      categoriesLogged: categoriesLogged ?? this.categoriesLogged,
      averageControlScore: averageControlScore ?? this.averageControlScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (ownershipRatio.present) {
      map['ownership_ratio'] = Variable<double>(ownershipRatio.value);
    }
    if (categoriesLogged.present) {
      map['categories_logged'] = Variable<int>(categoriesLogged.value);
    }
    if (averageControlScore.present) {
      map['average_control_score'] = Variable<double>(
        averageControlScore.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekSummaryEntriesCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('ownershipRatio: $ownershipRatio, ')
          ..write('categoriesLogged: $categoriesLogged, ')
          ..write('averageControlScore: $averageControlScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivityLogEntriesTable activityLogEntries =
      $ActivityLogEntriesTable(this);
  late final $QuickTemplateEntriesTable quickTemplateEntries =
      $QuickTemplateEntriesTable(this);
  late final $WeekSummaryEntriesTable weekSummaryEntries =
      $WeekSummaryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activityLogEntries,
    quickTemplateEntries,
    weekSummaryEntries,
  ];
}

typedef $$ActivityLogEntriesTableCreateCompanionBuilder =
    ActivityLogEntriesCompanion Function({
      required String id,
      required String templateId,
      required String categoryName,
      required String activityName,
      required String emoji,
      required DateTime loggedAt,
      required String postFieldsJson,
      required int controlScore,
      Value<int> rowid,
    });
typedef $$ActivityLogEntriesTableUpdateCompanionBuilder =
    ActivityLogEntriesCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> categoryName,
      Value<String> activityName,
      Value<String> emoji,
      Value<DateTime> loggedAt,
      Value<String> postFieldsJson,
      Value<int> controlScore,
      Value<int> rowid,
    });

class $$ActivityLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postFieldsJson => $composableBuilder(
    column: $table.postFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get controlScore => $composableBuilder(
    column: $table.controlScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postFieldsJson => $composableBuilder(
    column: $table.postFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get controlScore => $composableBuilder(
    column: $table.controlScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get postFieldsJson => $composableBuilder(
    column: $table.postFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get controlScore => $composableBuilder(
    column: $table.controlScore,
    builder: (column) => column,
  );
}

class $$ActivityLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogEntriesTable,
          ActivityLogEntry,
          $$ActivityLogEntriesTableFilterComposer,
          $$ActivityLogEntriesTableOrderingComposer,
          $$ActivityLogEntriesTableAnnotationComposer,
          $$ActivityLogEntriesTableCreateCompanionBuilder,
          $$ActivityLogEntriesTableUpdateCompanionBuilder,
          (
            ActivityLogEntry,
            BaseReferences<
              _$AppDatabase,
              $ActivityLogEntriesTable,
              ActivityLogEntry
            >,
          ),
          ActivityLogEntry,
          PrefetchHooks Function()
        > {
  $$ActivityLogEntriesTableTableManager(
    _$AppDatabase db,
    $ActivityLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> activityName = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<String> postFieldsJson = const Value.absent(),
                Value<int> controlScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogEntriesCompanion(
                id: id,
                templateId: templateId,
                categoryName: categoryName,
                activityName: activityName,
                emoji: emoji,
                loggedAt: loggedAt,
                postFieldsJson: postFieldsJson,
                controlScore: controlScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String categoryName,
                required String activityName,
                required String emoji,
                required DateTime loggedAt,
                required String postFieldsJson,
                required int controlScore,
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogEntriesCompanion.insert(
                id: id,
                templateId: templateId,
                categoryName: categoryName,
                activityName: activityName,
                emoji: emoji,
                loggedAt: loggedAt,
                postFieldsJson: postFieldsJson,
                controlScore: controlScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogEntriesTable,
      ActivityLogEntry,
      $$ActivityLogEntriesTableFilterComposer,
      $$ActivityLogEntriesTableOrderingComposer,
      $$ActivityLogEntriesTableAnnotationComposer,
      $$ActivityLogEntriesTableCreateCompanionBuilder,
      $$ActivityLogEntriesTableUpdateCompanionBuilder,
      (
        ActivityLogEntry,
        BaseReferences<
          _$AppDatabase,
          $ActivityLogEntriesTable,
          ActivityLogEntry
        >,
      ),
      ActivityLogEntry,
      PrefetchHooks Function()
    >;
typedef $$QuickTemplateEntriesTableCreateCompanionBuilder =
    QuickTemplateEntriesCompanion Function({
      required String id,
      required String categoryName,
      required String activityName,
      required String emoji,
      required String fieldsJson,
      Value<int> rowid,
    });
typedef $$QuickTemplateEntriesTableUpdateCompanionBuilder =
    QuickTemplateEntriesCompanion Function({
      Value<String> id,
      Value<String> categoryName,
      Value<String> activityName,
      Value<String> emoji,
      Value<String> fieldsJson,
      Value<int> rowid,
    });

class $$QuickTemplateEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuickTemplateEntriesTable> {
  $$QuickTemplateEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuickTemplateEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuickTemplateEntriesTable> {
  $$QuickTemplateEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuickTemplateEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuickTemplateEntriesTable> {
  $$QuickTemplateEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityName => $composableBuilder(
    column: $table.activityName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );
}

class $$QuickTemplateEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuickTemplateEntriesTable,
          QuickTemplateEntry,
          $$QuickTemplateEntriesTableFilterComposer,
          $$QuickTemplateEntriesTableOrderingComposer,
          $$QuickTemplateEntriesTableAnnotationComposer,
          $$QuickTemplateEntriesTableCreateCompanionBuilder,
          $$QuickTemplateEntriesTableUpdateCompanionBuilder,
          (
            QuickTemplateEntry,
            BaseReferences<
              _$AppDatabase,
              $QuickTemplateEntriesTable,
              QuickTemplateEntry
            >,
          ),
          QuickTemplateEntry,
          PrefetchHooks Function()
        > {
  $$QuickTemplateEntriesTableTableManager(
    _$AppDatabase db,
    $QuickTemplateEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickTemplateEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickTemplateEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuickTemplateEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> activityName = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuickTemplateEntriesCompanion(
                id: id,
                categoryName: categoryName,
                activityName: activityName,
                emoji: emoji,
                fieldsJson: fieldsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryName,
                required String activityName,
                required String emoji,
                required String fieldsJson,
                Value<int> rowid = const Value.absent(),
              }) => QuickTemplateEntriesCompanion.insert(
                id: id,
                categoryName: categoryName,
                activityName: activityName,
                emoji: emoji,
                fieldsJson: fieldsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuickTemplateEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuickTemplateEntriesTable,
      QuickTemplateEntry,
      $$QuickTemplateEntriesTableFilterComposer,
      $$QuickTemplateEntriesTableOrderingComposer,
      $$QuickTemplateEntriesTableAnnotationComposer,
      $$QuickTemplateEntriesTableCreateCompanionBuilder,
      $$QuickTemplateEntriesTableUpdateCompanionBuilder,
      (
        QuickTemplateEntry,
        BaseReferences<
          _$AppDatabase,
          $QuickTemplateEntriesTable,
          QuickTemplateEntry
        >,
      ),
      QuickTemplateEntry,
      PrefetchHooks Function()
    >;
typedef $$WeekSummaryEntriesTableCreateCompanionBuilder =
    WeekSummaryEntriesCompanion Function({
      required DateTime weekStart,
      required double ownershipRatio,
      required int categoriesLogged,
      required double averageControlScore,
      Value<int> rowid,
    });
typedef $$WeekSummaryEntriesTableUpdateCompanionBuilder =
    WeekSummaryEntriesCompanion Function({
      Value<DateTime> weekStart,
      Value<double> ownershipRatio,
      Value<int> categoriesLogged,
      Value<double> averageControlScore,
      Value<int> rowid,
    });

class $$WeekSummaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeekSummaryEntriesTable> {
  $$WeekSummaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ownershipRatio => $composableBuilder(
    column: $table.ownershipRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriesLogged => $composableBuilder(
    column: $table.categoriesLogged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageControlScore => $composableBuilder(
    column: $table.averageControlScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeekSummaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekSummaryEntriesTable> {
  $$WeekSummaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ownershipRatio => $composableBuilder(
    column: $table.ownershipRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriesLogged => $composableBuilder(
    column: $table.categoriesLogged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageControlScore => $composableBuilder(
    column: $table.averageControlScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeekSummaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekSummaryEntriesTable> {
  $$WeekSummaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<double> get ownershipRatio => $composableBuilder(
    column: $table.ownershipRatio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoriesLogged => $composableBuilder(
    column: $table.categoriesLogged,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageControlScore => $composableBuilder(
    column: $table.averageControlScore,
    builder: (column) => column,
  );
}

class $$WeekSummaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeekSummaryEntriesTable,
          WeekSummaryEntry,
          $$WeekSummaryEntriesTableFilterComposer,
          $$WeekSummaryEntriesTableOrderingComposer,
          $$WeekSummaryEntriesTableAnnotationComposer,
          $$WeekSummaryEntriesTableCreateCompanionBuilder,
          $$WeekSummaryEntriesTableUpdateCompanionBuilder,
          (
            WeekSummaryEntry,
            BaseReferences<
              _$AppDatabase,
              $WeekSummaryEntriesTable,
              WeekSummaryEntry
            >,
          ),
          WeekSummaryEntry,
          PrefetchHooks Function()
        > {
  $$WeekSummaryEntriesTableTableManager(
    _$AppDatabase db,
    $WeekSummaryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekSummaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekSummaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekSummaryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> weekStart = const Value.absent(),
                Value<double> ownershipRatio = const Value.absent(),
                Value<int> categoriesLogged = const Value.absent(),
                Value<double> averageControlScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekSummaryEntriesCompanion(
                weekStart: weekStart,
                ownershipRatio: ownershipRatio,
                categoriesLogged: categoriesLogged,
                averageControlScore: averageControlScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime weekStart,
                required double ownershipRatio,
                required int categoriesLogged,
                required double averageControlScore,
                Value<int> rowid = const Value.absent(),
              }) => WeekSummaryEntriesCompanion.insert(
                weekStart: weekStart,
                ownershipRatio: ownershipRatio,
                categoriesLogged: categoriesLogged,
                averageControlScore: averageControlScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeekSummaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeekSummaryEntriesTable,
      WeekSummaryEntry,
      $$WeekSummaryEntriesTableFilterComposer,
      $$WeekSummaryEntriesTableOrderingComposer,
      $$WeekSummaryEntriesTableAnnotationComposer,
      $$WeekSummaryEntriesTableCreateCompanionBuilder,
      $$WeekSummaryEntriesTableUpdateCompanionBuilder,
      (
        WeekSummaryEntry,
        BaseReferences<
          _$AppDatabase,
          $WeekSummaryEntriesTable,
          WeekSummaryEntry
        >,
      ),
      WeekSummaryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivityLogEntriesTableTableManager get activityLogEntries =>
      $$ActivityLogEntriesTableTableManager(_db, _db.activityLogEntries);
  $$QuickTemplateEntriesTableTableManager get quickTemplateEntries =>
      $$QuickTemplateEntriesTableTableManager(_db, _db.quickTemplateEntries);
  $$WeekSummaryEntriesTableTableManager get weekSummaryEntries =>
      $$WeekSummaryEntriesTableTableManager(_db, _db.weekSummaryEntries);
}
