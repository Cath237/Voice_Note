// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MeetingsTable extends Meetings with TableInfo<$MeetingsTable, Meeting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Réunion professionnelle'),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recording'),
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    category,
    location,
    date,
    durationMs,
    language,
    status,
    summaryJson,
    deletedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meeting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meeting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meeting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MeetingsTable createAlias(String alias) {
    return $MeetingsTable(attachedDatabase, alias);
  }
}

class Meeting extends DataClass implements Insertable<Meeting> {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final int durationMs;
  final String language;
  final String status;
  final String? summaryJson;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.durationMs,
    required this.language,
    required this.status,
    this.summaryJson,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['location'] = Variable<String>(location);
    map['date'] = Variable<DateTime>(date);
    map['duration_ms'] = Variable<int>(durationMs);
    map['language'] = Variable<String>(language);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || summaryJson != null) {
      map['summary_json'] = Variable<String>(summaryJson);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeetingsCompanion toCompanion(bool nullToAbsent) {
    return MeetingsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      category: Value(category),
      location: Value(location),
      date: Value(date),
      durationMs: Value(durationMs),
      language: Value(language),
      status: Value(status),
      summaryJson: summaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryJson),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Meeting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meeting(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      location: serializer.fromJson<String>(json['location']),
      date: serializer.fromJson<DateTime>(json['date']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      language: serializer.fromJson<String>(json['language']),
      status: serializer.fromJson<String>(json['status']),
      summaryJson: serializer.fromJson<String?>(json['summaryJson']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'location': serializer.toJson<String>(location),
      'date': serializer.toJson<DateTime>(date),
      'durationMs': serializer.toJson<int>(durationMs),
      'language': serializer.toJson<String>(language),
      'status': serializer.toJson<String>(status),
      'summaryJson': serializer.toJson<String?>(summaryJson),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Meeting copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? date,
    int? durationMs,
    String? language,
    String? status,
    Value<String?> summaryJson = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Meeting(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    location: location ?? this.location,
    date: date ?? this.date,
    durationMs: durationMs ?? this.durationMs,
    language: language ?? this.language,
    status: status ?? this.status,
    summaryJson: summaryJson.present ? summaryJson.value : this.summaryJson,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Meeting copyWithCompanion(MeetingsCompanion data) {
    return Meeting(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      date: data.date.present ? data.date.value : this.date,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      language: data.language.present ? data.language.value : this.language,
      status: data.status.present ? data.status.value : this.status,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meeting(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('durationMs: $durationMs, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    location,
    date,
    durationMs,
    language,
    status,
    summaryJson,
    deletedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meeting &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.location == this.location &&
          other.date == this.date &&
          other.durationMs == this.durationMs &&
          other.language == this.language &&
          other.status == this.status &&
          other.summaryJson == this.summaryJson &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MeetingsCompanion extends UpdateCompanion<Meeting> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> category;
  final Value<String> location;
  final Value<DateTime> date;
  final Value<int> durationMs;
  final Value<String> language;
  final Value<String> status;
  final Value<String?> summaryJson;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeetingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.date = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeetingsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime date,
    this.durationMs = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Meeting> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? location,
    Expression<DateTime>? date,
    Expression<int>? durationMs,
    Expression<String>? language,
    Expression<String>? status,
    Expression<String>? summaryJson,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (date != null) 'date': date,
      if (durationMs != null) 'duration_ms': durationMs,
      if (language != null) 'language': language,
      if (status != null) 'status': status,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeetingsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? category,
    Value<String>? location,
    Value<DateTime>? date,
    Value<int>? durationMs,
    Value<String>? language,
    Value<String>? status,
    Value<String?>? summaryJson,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MeetingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      durationMs: durationMs ?? this.durationMs,
      language: language ?? this.language,
      status: status ?? this.status,
      summaryJson: summaryJson ?? this.summaryJson,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('date: $date, ')
          ..write('durationMs: $durationMs, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerIdentifierMeta = const VerificationMeta(
    'speakerIdentifier',
  );
  @override
  late final GeneratedColumn<String> speakerIdentifier =
      GeneratedColumn<String>(
        'speaker_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    name,
    speakerIdentifier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Participant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('speaker_identifier')) {
      context.handle(
        _speakerIdentifierMeta,
        speakerIdentifier.isAcceptableOrUnknown(
          data['speaker_identifier']!,
          _speakerIdentifierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      speakerIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker_identifier'],
      ),
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final String id;
  final String meetingId;
  final String name;
  final String? speakerIdentifier;
  const Participant({
    required this.id,
    required this.meetingId,
    required this.name,
    this.speakerIdentifier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meeting_id'] = Variable<String>(meetingId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || speakerIdentifier != null) {
      map['speaker_identifier'] = Variable<String>(speakerIdentifier);
    }
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      meetingId: Value(meetingId),
      name: Value(name),
      speakerIdentifier: speakerIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerIdentifier),
    );
  }

  factory Participant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<String>(json['id']),
      meetingId: serializer.fromJson<String>(json['meetingId']),
      name: serializer.fromJson<String>(json['name']),
      speakerIdentifier: serializer.fromJson<String?>(
        json['speakerIdentifier'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'meetingId': serializer.toJson<String>(meetingId),
      'name': serializer.toJson<String>(name),
      'speakerIdentifier': serializer.toJson<String?>(speakerIdentifier),
    };
  }

  Participant copyWith({
    String? id,
    String? meetingId,
    String? name,
    Value<String?> speakerIdentifier = const Value.absent(),
  }) => Participant(
    id: id ?? this.id,
    meetingId: meetingId ?? this.meetingId,
    name: name ?? this.name,
    speakerIdentifier: speakerIdentifier.present
        ? speakerIdentifier.value
        : this.speakerIdentifier,
  );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      name: data.name.present ? data.name.value : this.name,
      speakerIdentifier: data.speakerIdentifier.present
          ? data.speakerIdentifier.value
          : this.speakerIdentifier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('name: $name, ')
          ..write('speakerIdentifier: $speakerIdentifier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, meetingId, name, speakerIdentifier);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.name == this.name &&
          other.speakerIdentifier == this.speakerIdentifier);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<String> id;
  final Value<String> meetingId;
  final Value<String> name;
  final Value<String?> speakerIdentifier;
  final Value<int> rowid;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.name = const Value.absent(),
    this.speakerIdentifier = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    required String id,
    required String meetingId,
    required String name,
    this.speakerIdentifier = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       meetingId = Value(meetingId),
       name = Value(name);
  static Insertable<Participant> custom({
    Expression<String>? id,
    Expression<String>? meetingId,
    Expression<String>? name,
    Expression<String>? speakerIdentifier,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (name != null) 'name': name,
      if (speakerIdentifier != null) 'speaker_identifier': speakerIdentifier,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantsCompanion copyWith({
    Value<String>? id,
    Value<String>? meetingId,
    Value<String>? name,
    Value<String?>? speakerIdentifier,
    Value<int>? rowid,
  }) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      name: name ?? this.name,
      speakerIdentifier: speakerIdentifier ?? this.speakerIdentifier,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (speakerIdentifier.present) {
      map['speaker_identifier'] = Variable<String>(speakerIdentifier.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('name: $name, ')
          ..write('speakerIdentifier: $speakerIdentifier, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioSegmentsTable extends AudioSegments
    with TableInfo<$AudioSegmentsTable, AudioSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentNumberMeta = const VerificationMeta(
    'segmentNumber',
  );
  @override
  late final GeneratedColumn<int> segmentNumber = GeneratedColumn<int>(
    'segment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    segmentNumber,
    startMs,
    endMs,
    filePath,
    status,
    retryCount,
    errorMessage,
    lastAttempt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('segment_number')) {
      context.handle(
        _segmentNumberMeta,
        segmentNumber.isAcceptableOrUnknown(
          data['segment_number']!,
          _segmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentNumberMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      segmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_number'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt'],
      ),
    );
  }

  @override
  $AudioSegmentsTable createAlias(String alias) {
    return $AudioSegmentsTable(attachedDatabase, alias);
  }
}

class AudioSegment extends DataClass implements Insertable<AudioSegment> {
  final String id;
  final String meetingId;
  final int segmentNumber;
  final int startMs;
  final int endMs;
  final String filePath;
  final String status;
  final int retryCount;
  final String? errorMessage;
  final DateTime? lastAttempt;
  const AudioSegment({
    required this.id,
    required this.meetingId,
    required this.segmentNumber,
    required this.startMs,
    required this.endMs,
    required this.filePath,
    required this.status,
    required this.retryCount,
    this.errorMessage,
    this.lastAttempt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meeting_id'] = Variable<String>(meetingId);
    map['segment_number'] = Variable<int>(segmentNumber);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['file_path'] = Variable<String>(filePath);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    return map;
  }

  AudioSegmentsCompanion toCompanion(bool nullToAbsent) {
    return AudioSegmentsCompanion(
      id: Value(id),
      meetingId: Value(meetingId),
      segmentNumber: Value(segmentNumber),
      startMs: Value(startMs),
      endMs: Value(endMs),
      filePath: Value(filePath),
      status: Value(status),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
    );
  }

  factory AudioSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioSegment(
      id: serializer.fromJson<String>(json['id']),
      meetingId: serializer.fromJson<String>(json['meetingId']),
      segmentNumber: serializer.fromJson<int>(json['segmentNumber']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      filePath: serializer.fromJson<String>(json['filePath']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'meetingId': serializer.toJson<String>(meetingId),
      'segmentNumber': serializer.toJson<int>(segmentNumber),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'filePath': serializer.toJson<String>(filePath),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
    };
  }

  AudioSegment copyWith({
    String? id,
    String? meetingId,
    int? segmentNumber,
    int? startMs,
    int? endMs,
    String? filePath,
    String? status,
    int? retryCount,
    Value<String?> errorMessage = const Value.absent(),
    Value<DateTime?> lastAttempt = const Value.absent(),
  }) => AudioSegment(
    id: id ?? this.id,
    meetingId: meetingId ?? this.meetingId,
    segmentNumber: segmentNumber ?? this.segmentNumber,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    filePath: filePath ?? this.filePath,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
  );
  AudioSegment copyWithCompanion(AudioSegmentsCompanion data) {
    return AudioSegment(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      segmentNumber: data.segmentNumber.present
          ? data.segmentNumber.value
          : this.segmentNumber,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioSegment(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('segmentNumber: $segmentNumber, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('lastAttempt: $lastAttempt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    meetingId,
    segmentNumber,
    startMs,
    endMs,
    filePath,
    status,
    retryCount,
    errorMessage,
    lastAttempt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioSegment &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.segmentNumber == this.segmentNumber &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.filePath == this.filePath &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.lastAttempt == this.lastAttempt);
}

class AudioSegmentsCompanion extends UpdateCompanion<AudioSegment> {
  final Value<String> id;
  final Value<String> meetingId;
  final Value<int> segmentNumber;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> filePath;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<DateTime?> lastAttempt;
  final Value<int> rowid;
  const AudioSegmentsCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.segmentNumber = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.filePath = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioSegmentsCompanion.insert({
    required String id,
    required String meetingId,
    required int segmentNumber,
    required int startMs,
    required int endMs,
    required String filePath,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       meetingId = Value(meetingId),
       segmentNumber = Value(segmentNumber),
       startMs = Value(startMs),
       endMs = Value(endMs),
       filePath = Value(filePath);
  static Insertable<AudioSegment> custom({
    Expression<String>? id,
    Expression<String>? meetingId,
    Expression<int>? segmentNumber,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? filePath,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<DateTime>? lastAttempt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (segmentNumber != null) 'segment_number': segmentNumber,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (filePath != null) 'file_path': filePath,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? meetingId,
    Value<int>? segmentNumber,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? filePath,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? errorMessage,
    Value<DateTime?>? lastAttempt,
    Value<int>? rowid,
  }) {
    return AudioSegmentsCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      segmentNumber: segmentNumber ?? this.segmentNumber,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (segmentNumber.present) {
      map['segment_number'] = Variable<int>(segmentNumber.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('segmentNumber: $segmentNumber, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptSegmentsTable extends TranscriptSegments
    with TableInfo<$TranscriptSegmentsTable, TranscriptSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioSegmentIdMeta = const VerificationMeta(
    'audioSegmentId',
  );
  @override
  late final GeneratedColumn<String> audioSegmentId = GeneratedColumn<String>(
    'audio_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerIdMeta = const VerificationMeta(
    'speakerId',
  );
  @override
  late final GeneratedColumn<String> speakerId = GeneratedColumn<String>(
    'speaker_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
    'edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    audioSegmentId,
    speakerId,
    startMs,
    endMs,
    language,
    content,
    edited,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('audio_segment_id')) {
      context.handle(
        _audioSegmentIdMeta,
        audioSegmentId.isAcceptableOrUnknown(
          data['audio_segment_id']!,
          _audioSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioSegmentIdMeta);
    }
    if (data.containsKey('speaker_id')) {
      context.handle(
        _speakerIdMeta,
        speakerId.isAcceptableOrUnknown(data['speaker_id']!, _speakerIdMeta),
      );
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('edited')) {
      context.handle(
        _editedMeta,
        edited.isAcceptableOrUnknown(data['edited']!, _editedMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranscriptSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      audioSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_segment_id'],
      )!,
      speakerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker_id'],
      ),
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      edited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}edited'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
    );
  }

  @override
  $TranscriptSegmentsTable createAlias(String alias) {
    return $TranscriptSegmentsTable(attachedDatabase, alias);
  }
}

class TranscriptSegment extends DataClass
    implements Insertable<TranscriptSegment> {
  final String id;
  final String meetingId;
  final String audioSegmentId;
  final String? speakerId;
  final int startMs;
  final int endMs;
  final String language;
  final String content;
  final bool edited;
  final double? confidence;
  const TranscriptSegment({
    required this.id,
    required this.meetingId,
    required this.audioSegmentId,
    this.speakerId,
    required this.startMs,
    required this.endMs,
    required this.language,
    required this.content,
    required this.edited,
    this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meeting_id'] = Variable<String>(meetingId);
    map['audio_segment_id'] = Variable<String>(audioSegmentId);
    if (!nullToAbsent || speakerId != null) {
      map['speaker_id'] = Variable<String>(speakerId);
    }
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['language'] = Variable<String>(language);
    map['content'] = Variable<String>(content);
    map['edited'] = Variable<bool>(edited);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    return map;
  }

  TranscriptSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptSegmentsCompanion(
      id: Value(id),
      meetingId: Value(meetingId),
      audioSegmentId: Value(audioSegmentId),
      speakerId: speakerId == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      language: Value(language),
      content: Value(content),
      edited: Value(edited),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
    );
  }

  factory TranscriptSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptSegment(
      id: serializer.fromJson<String>(json['id']),
      meetingId: serializer.fromJson<String>(json['meetingId']),
      audioSegmentId: serializer.fromJson<String>(json['audioSegmentId']),
      speakerId: serializer.fromJson<String?>(json['speakerId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      language: serializer.fromJson<String>(json['language']),
      content: serializer.fromJson<String>(json['content']),
      edited: serializer.fromJson<bool>(json['edited']),
      confidence: serializer.fromJson<double?>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'meetingId': serializer.toJson<String>(meetingId),
      'audioSegmentId': serializer.toJson<String>(audioSegmentId),
      'speakerId': serializer.toJson<String?>(speakerId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'language': serializer.toJson<String>(language),
      'content': serializer.toJson<String>(content),
      'edited': serializer.toJson<bool>(edited),
      'confidence': serializer.toJson<double?>(confidence),
    };
  }

  TranscriptSegment copyWith({
    String? id,
    String? meetingId,
    String? audioSegmentId,
    Value<String?> speakerId = const Value.absent(),
    int? startMs,
    int? endMs,
    String? language,
    String? content,
    bool? edited,
    Value<double?> confidence = const Value.absent(),
  }) => TranscriptSegment(
    id: id ?? this.id,
    meetingId: meetingId ?? this.meetingId,
    audioSegmentId: audioSegmentId ?? this.audioSegmentId,
    speakerId: speakerId.present ? speakerId.value : this.speakerId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    language: language ?? this.language,
    content: content ?? this.content,
    edited: edited ?? this.edited,
    confidence: confidence.present ? confidence.value : this.confidence,
  );
  TranscriptSegment copyWithCompanion(TranscriptSegmentsCompanion data) {
    return TranscriptSegment(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      audioSegmentId: data.audioSegmentId.present
          ? data.audioSegmentId.value
          : this.audioSegmentId,
      speakerId: data.speakerId.present ? data.speakerId.value : this.speakerId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      language: data.language.present ? data.language.value : this.language,
      content: data.content.present ? data.content.value : this.content,
      edited: data.edited.present ? data.edited.value : this.edited,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegment(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('audioSegmentId: $audioSegmentId, ')
          ..write('speakerId: $speakerId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('language: $language, ')
          ..write('content: $content, ')
          ..write('edited: $edited, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    meetingId,
    audioSegmentId,
    speakerId,
    startMs,
    endMs,
    language,
    content,
    edited,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptSegment &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.audioSegmentId == this.audioSegmentId &&
          other.speakerId == this.speakerId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.language == this.language &&
          other.content == this.content &&
          other.edited == this.edited &&
          other.confidence == this.confidence);
}

class TranscriptSegmentsCompanion extends UpdateCompanion<TranscriptSegment> {
  final Value<String> id;
  final Value<String> meetingId;
  final Value<String> audioSegmentId;
  final Value<String?> speakerId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> language;
  final Value<String> content;
  final Value<bool> edited;
  final Value<double?> confidence;
  final Value<int> rowid;
  const TranscriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.audioSegmentId = const Value.absent(),
    this.speakerId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.language = const Value.absent(),
    this.content = const Value.absent(),
    this.edited = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptSegmentsCompanion.insert({
    required String id,
    required String meetingId,
    required String audioSegmentId,
    this.speakerId = const Value.absent(),
    required int startMs,
    required int endMs,
    this.language = const Value.absent(),
    required String content,
    this.edited = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       meetingId = Value(meetingId),
       audioSegmentId = Value(audioSegmentId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       content = Value(content);
  static Insertable<TranscriptSegment> custom({
    Expression<String>? id,
    Expression<String>? meetingId,
    Expression<String>? audioSegmentId,
    Expression<String>? speakerId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? language,
    Expression<String>? content,
    Expression<bool>? edited,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (audioSegmentId != null) 'audio_segment_id': audioSegmentId,
      if (speakerId != null) 'speaker_id': speakerId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (language != null) 'language': language,
      if (content != null) 'content': content,
      if (edited != null) 'edited': edited,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? meetingId,
    Value<String>? audioSegmentId,
    Value<String?>? speakerId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? language,
    Value<String>? content,
    Value<bool>? edited,
    Value<double?>? confidence,
    Value<int>? rowid,
  }) {
    return TranscriptSegmentsCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      audioSegmentId: audioSegmentId ?? this.audioSegmentId,
      speakerId: speakerId ?? this.speakerId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      language: language ?? this.language,
      content: content ?? this.content,
      edited: edited ?? this.edited,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (audioSegmentId.present) {
      map['audio_segment_id'] = Variable<String>(audioSegmentId.value);
    }
    if (speakerId.present) {
      map['speaker_id'] = Variable<String>(speakerId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('audioSegmentId: $audioSegmentId, ')
          ..write('speakerId: $speakerId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('language: $language, ')
          ..write('content: $content, ')
          ..write('edited: $edited, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeetingContextsTable extends MeetingContexts
    with TableInfo<$MeetingContextsTable, MeetingContext> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dictionaryJsonMeta = const VerificationMeta(
    'dictionaryJson',
  );
  @override
  late final GeneratedColumn<String> dictionaryJson = GeneratedColumn<String>(
    'dictionary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _entitiesJsonMeta = const VerificationMeta(
    'entitiesJson',
  );
  @override
  late final GeneratedColumn<String> entitiesJson = GeneratedColumn<String>(
    'entities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _topicsJsonMeta = const VerificationMeta(
    'topicsJson',
  );
  @override
  late final GeneratedColumn<String> topicsJson = GeneratedColumn<String>(
    'topics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _decisionsJsonMeta = const VerificationMeta(
    'decisionsJson',
  );
  @override
  late final GeneratedColumn<String> decisionsJson = GeneratedColumn<String>(
    'decisions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _actionsJsonMeta = const VerificationMeta(
    'actionsJson',
  );
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
    'actions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _contextSummaryMeta = const VerificationMeta(
    'contextSummary',
  );
  @override
  late final GeneratedColumn<String> contextSummary = GeneratedColumn<String>(
    'context_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    meetingId,
    dictionaryJson,
    entitiesJson,
    topicsJson,
    decisionsJson,
    actionsJson,
    contextSummary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meeting_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeetingContext> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('dictionary_json')) {
      context.handle(
        _dictionaryJsonMeta,
        dictionaryJson.isAcceptableOrUnknown(
          data['dictionary_json']!,
          _dictionaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('entities_json')) {
      context.handle(
        _entitiesJsonMeta,
        entitiesJson.isAcceptableOrUnknown(
          data['entities_json']!,
          _entitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('topics_json')) {
      context.handle(
        _topicsJsonMeta,
        topicsJson.isAcceptableOrUnknown(data['topics_json']!, _topicsJsonMeta),
      );
    }
    if (data.containsKey('decisions_json')) {
      context.handle(
        _decisionsJsonMeta,
        decisionsJson.isAcceptableOrUnknown(
          data['decisions_json']!,
          _decisionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('actions_json')) {
      context.handle(
        _actionsJsonMeta,
        actionsJson.isAcceptableOrUnknown(
          data['actions_json']!,
          _actionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('context_summary')) {
      context.handle(
        _contextSummaryMeta,
        contextSummary.isAcceptableOrUnknown(
          data['context_summary']!,
          _contextSummaryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meetingId};
  @override
  MeetingContext map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeetingContext(
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      dictionaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dictionary_json'],
      )!,
      entitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entities_json'],
      )!,
      topicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics_json'],
      )!,
      decisionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decisions_json'],
      )!,
      actionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions_json'],
      )!,
      contextSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_summary'],
      )!,
    );
  }

  @override
  $MeetingContextsTable createAlias(String alias) {
    return $MeetingContextsTable(attachedDatabase, alias);
  }
}

class MeetingContext extends DataClass implements Insertable<MeetingContext> {
  final String meetingId;
  final String dictionaryJson;
  final String entitiesJson;
  final String topicsJson;
  final String decisionsJson;
  final String actionsJson;
  final String contextSummary;
  const MeetingContext({
    required this.meetingId,
    required this.dictionaryJson,
    required this.entitiesJson,
    required this.topicsJson,
    required this.decisionsJson,
    required this.actionsJson,
    required this.contextSummary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meeting_id'] = Variable<String>(meetingId);
    map['dictionary_json'] = Variable<String>(dictionaryJson);
    map['entities_json'] = Variable<String>(entitiesJson);
    map['topics_json'] = Variable<String>(topicsJson);
    map['decisions_json'] = Variable<String>(decisionsJson);
    map['actions_json'] = Variable<String>(actionsJson);
    map['context_summary'] = Variable<String>(contextSummary);
    return map;
  }

  MeetingContextsCompanion toCompanion(bool nullToAbsent) {
    return MeetingContextsCompanion(
      meetingId: Value(meetingId),
      dictionaryJson: Value(dictionaryJson),
      entitiesJson: Value(entitiesJson),
      topicsJson: Value(topicsJson),
      decisionsJson: Value(decisionsJson),
      actionsJson: Value(actionsJson),
      contextSummary: Value(contextSummary),
    );
  }

  factory MeetingContext.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeetingContext(
      meetingId: serializer.fromJson<String>(json['meetingId']),
      dictionaryJson: serializer.fromJson<String>(json['dictionaryJson']),
      entitiesJson: serializer.fromJson<String>(json['entitiesJson']),
      topicsJson: serializer.fromJson<String>(json['topicsJson']),
      decisionsJson: serializer.fromJson<String>(json['decisionsJson']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      contextSummary: serializer.fromJson<String>(json['contextSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meetingId': serializer.toJson<String>(meetingId),
      'dictionaryJson': serializer.toJson<String>(dictionaryJson),
      'entitiesJson': serializer.toJson<String>(entitiesJson),
      'topicsJson': serializer.toJson<String>(topicsJson),
      'decisionsJson': serializer.toJson<String>(decisionsJson),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'contextSummary': serializer.toJson<String>(contextSummary),
    };
  }

  MeetingContext copyWith({
    String? meetingId,
    String? dictionaryJson,
    String? entitiesJson,
    String? topicsJson,
    String? decisionsJson,
    String? actionsJson,
    String? contextSummary,
  }) => MeetingContext(
    meetingId: meetingId ?? this.meetingId,
    dictionaryJson: dictionaryJson ?? this.dictionaryJson,
    entitiesJson: entitiesJson ?? this.entitiesJson,
    topicsJson: topicsJson ?? this.topicsJson,
    decisionsJson: decisionsJson ?? this.decisionsJson,
    actionsJson: actionsJson ?? this.actionsJson,
    contextSummary: contextSummary ?? this.contextSummary,
  );
  MeetingContext copyWithCompanion(MeetingContextsCompanion data) {
    return MeetingContext(
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      dictionaryJson: data.dictionaryJson.present
          ? data.dictionaryJson.value
          : this.dictionaryJson,
      entitiesJson: data.entitiesJson.present
          ? data.entitiesJson.value
          : this.entitiesJson,
      topicsJson: data.topicsJson.present
          ? data.topicsJson.value
          : this.topicsJson,
      decisionsJson: data.decisionsJson.present
          ? data.decisionsJson.value
          : this.decisionsJson,
      actionsJson: data.actionsJson.present
          ? data.actionsJson.value
          : this.actionsJson,
      contextSummary: data.contextSummary.present
          ? data.contextSummary.value
          : this.contextSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeetingContext(')
          ..write('meetingId: $meetingId, ')
          ..write('dictionaryJson: $dictionaryJson, ')
          ..write('entitiesJson: $entitiesJson, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('decisionsJson: $decisionsJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('contextSummary: $contextSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    meetingId,
    dictionaryJson,
    entitiesJson,
    topicsJson,
    decisionsJson,
    actionsJson,
    contextSummary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeetingContext &&
          other.meetingId == this.meetingId &&
          other.dictionaryJson == this.dictionaryJson &&
          other.entitiesJson == this.entitiesJson &&
          other.topicsJson == this.topicsJson &&
          other.decisionsJson == this.decisionsJson &&
          other.actionsJson == this.actionsJson &&
          other.contextSummary == this.contextSummary);
}

class MeetingContextsCompanion extends UpdateCompanion<MeetingContext> {
  final Value<String> meetingId;
  final Value<String> dictionaryJson;
  final Value<String> entitiesJson;
  final Value<String> topicsJson;
  final Value<String> decisionsJson;
  final Value<String> actionsJson;
  final Value<String> contextSummary;
  final Value<int> rowid;
  const MeetingContextsCompanion({
    this.meetingId = const Value.absent(),
    this.dictionaryJson = const Value.absent(),
    this.entitiesJson = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.decisionsJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.contextSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeetingContextsCompanion.insert({
    required String meetingId,
    this.dictionaryJson = const Value.absent(),
    this.entitiesJson = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.decisionsJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.contextSummary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : meetingId = Value(meetingId);
  static Insertable<MeetingContext> custom({
    Expression<String>? meetingId,
    Expression<String>? dictionaryJson,
    Expression<String>? entitiesJson,
    Expression<String>? topicsJson,
    Expression<String>? decisionsJson,
    Expression<String>? actionsJson,
    Expression<String>? contextSummary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meetingId != null) 'meeting_id': meetingId,
      if (dictionaryJson != null) 'dictionary_json': dictionaryJson,
      if (entitiesJson != null) 'entities_json': entitiesJson,
      if (topicsJson != null) 'topics_json': topicsJson,
      if (decisionsJson != null) 'decisions_json': decisionsJson,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (contextSummary != null) 'context_summary': contextSummary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeetingContextsCompanion copyWith({
    Value<String>? meetingId,
    Value<String>? dictionaryJson,
    Value<String>? entitiesJson,
    Value<String>? topicsJson,
    Value<String>? decisionsJson,
    Value<String>? actionsJson,
    Value<String>? contextSummary,
    Value<int>? rowid,
  }) {
    return MeetingContextsCompanion(
      meetingId: meetingId ?? this.meetingId,
      dictionaryJson: dictionaryJson ?? this.dictionaryJson,
      entitiesJson: entitiesJson ?? this.entitiesJson,
      topicsJson: topicsJson ?? this.topicsJson,
      decisionsJson: decisionsJson ?? this.decisionsJson,
      actionsJson: actionsJson ?? this.actionsJson,
      contextSummary: contextSummary ?? this.contextSummary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (dictionaryJson.present) {
      map['dictionary_json'] = Variable<String>(dictionaryJson.value);
    }
    if (entitiesJson.present) {
      map['entities_json'] = Variable<String>(entitiesJson.value);
    }
    if (topicsJson.present) {
      map['topics_json'] = Variable<String>(topicsJson.value);
    }
    if (decisionsJson.present) {
      map['decisions_json'] = Variable<String>(decisionsJson.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (contextSummary.present) {
      map['context_summary'] = Variable<String>(contextSummary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingContextsCompanion(')
          ..write('meetingId: $meetingId, ')
          ..write('dictionaryJson: $dictionaryJson, ')
          ..write('entitiesJson: $entitiesJson, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('decisionsJson: $decisionsJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('contextSummary: $contextSummary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeetingNotesTable extends MeetingNotes
    with TableInfo<$MeetingNotesTable, MeetingNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<String> meetingId = GeneratedColumn<String>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('note'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    timestampMs,
    content,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meeting_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeetingNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeetingNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeetingNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_id'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $MeetingNotesTable createAlias(String alias) {
    return $MeetingNotesTable(attachedDatabase, alias);
  }
}

class MeetingNote extends DataClass implements Insertable<MeetingNote> {
  final String id;
  final String meetingId;
  final int timestampMs;
  final String content;
  final String type;
  const MeetingNote({
    required this.id,
    required this.meetingId,
    required this.timestampMs,
    required this.content,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meeting_id'] = Variable<String>(meetingId);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    return map;
  }

  MeetingNotesCompanion toCompanion(bool nullToAbsent) {
    return MeetingNotesCompanion(
      id: Value(id),
      meetingId: Value(meetingId),
      timestampMs: Value(timestampMs),
      content: Value(content),
      type: Value(type),
    );
  }

  factory MeetingNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeetingNote(
      id: serializer.fromJson<String>(json['id']),
      meetingId: serializer.fromJson<String>(json['meetingId']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'meetingId': serializer.toJson<String>(meetingId),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
    };
  }

  MeetingNote copyWith({
    String? id,
    String? meetingId,
    int? timestampMs,
    String? content,
    String? type,
  }) => MeetingNote(
    id: id ?? this.id,
    meetingId: meetingId ?? this.meetingId,
    timestampMs: timestampMs ?? this.timestampMs,
    content: content ?? this.content,
    type: type ?? this.type,
  );
  MeetingNote copyWithCompanion(MeetingNotesCompanion data) {
    return MeetingNote(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeetingNote(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('content: $content, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, meetingId, timestampMs, content, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeetingNote &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.timestampMs == this.timestampMs &&
          other.content == this.content &&
          other.type == this.type);
}

class MeetingNotesCompanion extends UpdateCompanion<MeetingNote> {
  final Value<String> id;
  final Value<String> meetingId;
  final Value<int> timestampMs;
  final Value<String> content;
  final Value<String> type;
  final Value<int> rowid;
  const MeetingNotesCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeetingNotesCompanion.insert({
    required String id,
    required String meetingId,
    required int timestampMs,
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       meetingId = Value(meetingId),
       timestampMs = Value(timestampMs);
  static Insertable<MeetingNote> custom({
    Expression<String>? id,
    Expression<String>? meetingId,
    Expression<int>? timestampMs,
    Expression<String>? content,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeetingNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? meetingId,
    Value<int>? timestampMs,
    Value<String>? content,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return MeetingNotesCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      timestampMs: timestampMs ?? this.timestampMs,
      content: content ?? this.content,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<String>(meetingId.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingNotesCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MeetingsTable meetings = $MeetingsTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $AudioSegmentsTable audioSegments = $AudioSegmentsTable(this);
  late final $TranscriptSegmentsTable transcriptSegments =
      $TranscriptSegmentsTable(this);
  late final $MeetingContextsTable meetingContexts = $MeetingContextsTable(
    this,
  );
  late final $MeetingNotesTable meetingNotes = $MeetingNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meetings,
    participants,
    audioSegments,
    transcriptSegments,
    meetingContexts,
    meetingNotes,
  ];
}

typedef $$MeetingsTableCreateCompanionBuilder =
    MeetingsCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      Value<String> category,
      Value<String> location,
      required DateTime date,
      Value<int> durationMs,
      Value<String> language,
      Value<String> status,
      Value<String?> summaryJson,
      Value<DateTime?> deletedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MeetingsTableUpdateCompanionBuilder =
    MeetingsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> category,
      Value<String> location,
      Value<DateTime> date,
      Value<int> durationMs,
      Value<String> language,
      Value<String> status,
      Value<String?> summaryJson,
      Value<DateTime?> deletedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MeetingsTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeetingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeetingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MeetingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingsTable,
          Meeting,
          $$MeetingsTableFilterComposer,
          $$MeetingsTableOrderingComposer,
          $$MeetingsTableAnnotationComposer,
          $$MeetingsTableCreateCompanionBuilder,
          $$MeetingsTableUpdateCompanionBuilder,
          (Meeting, BaseReferences<_$AppDatabase, $MeetingsTable, Meeting>),
          Meeting,
          PrefetchHooks Function()
        > {
  $$MeetingsTableTableManager(_$AppDatabase db, $MeetingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingsCompanion(
                id: id,
                title: title,
                description: description,
                category: category,
                location: location,
                date: date,
                durationMs: durationMs,
                language: language,
                status: status,
                summaryJson: summaryJson,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> location = const Value.absent(),
                required DateTime date,
                Value<int> durationMs = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MeetingsCompanion.insert(
                id: id,
                title: title,
                description: description,
                category: category,
                location: location,
                date: date,
                durationMs: durationMs,
                language: language,
                status: status,
                summaryJson: summaryJson,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingsTable,
      Meeting,
      $$MeetingsTableFilterComposer,
      $$MeetingsTableOrderingComposer,
      $$MeetingsTableAnnotationComposer,
      $$MeetingsTableCreateCompanionBuilder,
      $$MeetingsTableUpdateCompanionBuilder,
      (Meeting, BaseReferences<_$AppDatabase, $MeetingsTable, Meeting>),
      Meeting,
      PrefetchHooks Function()
    >;
typedef $$ParticipantsTableCreateCompanionBuilder =
    ParticipantsCompanion Function({
      required String id,
      required String meetingId,
      required String name,
      Value<String?> speakerIdentifier,
      Value<int> rowid,
    });
typedef $$ParticipantsTableUpdateCompanionBuilder =
    ParticipantsCompanion Function({
      Value<String> id,
      Value<String> meetingId,
      Value<String> name,
      Value<String?> speakerIdentifier,
      Value<int> rowid,
    });

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
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

  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speakerIdentifier => $composableBuilder(
    column: $table.speakerIdentifier,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
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

  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speakerIdentifier => $composableBuilder(
    column: $table.speakerIdentifier,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get speakerIdentifier => $composableBuilder(
    column: $table.speakerIdentifier,
    builder: (column) => column,
  );
}

class $$ParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParticipantsTable,
          Participant,
          $$ParticipantsTableFilterComposer,
          $$ParticipantsTableOrderingComposer,
          $$ParticipantsTableAnnotationComposer,
          $$ParticipantsTableCreateCompanionBuilder,
          $$ParticipantsTableUpdateCompanionBuilder,
          (
            Participant,
            BaseReferences<_$AppDatabase, $ParticipantsTable, Participant>,
          ),
          Participant,
          PrefetchHooks Function()
        > {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> meetingId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> speakerIdentifier = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParticipantsCompanion(
                id: id,
                meetingId: meetingId,
                name: name,
                speakerIdentifier: speakerIdentifier,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String meetingId,
                required String name,
                Value<String?> speakerIdentifier = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParticipantsCompanion.insert(
                id: id,
                meetingId: meetingId,
                name: name,
                speakerIdentifier: speakerIdentifier,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParticipantsTable,
      Participant,
      $$ParticipantsTableFilterComposer,
      $$ParticipantsTableOrderingComposer,
      $$ParticipantsTableAnnotationComposer,
      $$ParticipantsTableCreateCompanionBuilder,
      $$ParticipantsTableUpdateCompanionBuilder,
      (
        Participant,
        BaseReferences<_$AppDatabase, $ParticipantsTable, Participant>,
      ),
      Participant,
      PrefetchHooks Function()
    >;
typedef $$AudioSegmentsTableCreateCompanionBuilder =
    AudioSegmentsCompanion Function({
      required String id,
      required String meetingId,
      required int segmentNumber,
      required int startMs,
      required int endMs,
      required String filePath,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> errorMessage,
      Value<DateTime?> lastAttempt,
      Value<int> rowid,
    });
typedef $$AudioSegmentsTableUpdateCompanionBuilder =
    AudioSegmentsCompanion Function({
      Value<String> id,
      Value<String> meetingId,
      Value<int> segmentNumber,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> filePath,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> errorMessage,
      Value<DateTime?> lastAttempt,
      Value<int> rowid,
    });

class $$AudioSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioSegmentsTable> {
  $$AudioSegmentsTableFilterComposer({
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

  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentNumber => $composableBuilder(
    column: $table.segmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioSegmentsTable> {
  $$AudioSegmentsTableOrderingComposer({
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

  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentNumber => $composableBuilder(
    column: $table.segmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioSegmentsTable> {
  $$AudioSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<int> get segmentNumber => $composableBuilder(
    column: $table.segmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );
}

class $$AudioSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioSegmentsTable,
          AudioSegment,
          $$AudioSegmentsTableFilterComposer,
          $$AudioSegmentsTableOrderingComposer,
          $$AudioSegmentsTableAnnotationComposer,
          $$AudioSegmentsTableCreateCompanionBuilder,
          $$AudioSegmentsTableUpdateCompanionBuilder,
          (
            AudioSegment,
            BaseReferences<_$AppDatabase, $AudioSegmentsTable, AudioSegment>,
          ),
          AudioSegment,
          PrefetchHooks Function()
        > {
  $$AudioSegmentsTableTableManager(_$AppDatabase db, $AudioSegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> meetingId = const Value.absent(),
                Value<int> segmentNumber = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioSegmentsCompanion(
                id: id,
                meetingId: meetingId,
                segmentNumber: segmentNumber,
                startMs: startMs,
                endMs: endMs,
                filePath: filePath,
                status: status,
                retryCount: retryCount,
                errorMessage: errorMessage,
                lastAttempt: lastAttempt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String meetingId,
                required int segmentNumber,
                required int startMs,
                required int endMs,
                required String filePath,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioSegmentsCompanion.insert(
                id: id,
                meetingId: meetingId,
                segmentNumber: segmentNumber,
                startMs: startMs,
                endMs: endMs,
                filePath: filePath,
                status: status,
                retryCount: retryCount,
                errorMessage: errorMessage,
                lastAttempt: lastAttempt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioSegmentsTable,
      AudioSegment,
      $$AudioSegmentsTableFilterComposer,
      $$AudioSegmentsTableOrderingComposer,
      $$AudioSegmentsTableAnnotationComposer,
      $$AudioSegmentsTableCreateCompanionBuilder,
      $$AudioSegmentsTableUpdateCompanionBuilder,
      (
        AudioSegment,
        BaseReferences<_$AppDatabase, $AudioSegmentsTable, AudioSegment>,
      ),
      AudioSegment,
      PrefetchHooks Function()
    >;
typedef $$TranscriptSegmentsTableCreateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      required String id,
      required String meetingId,
      required String audioSegmentId,
      Value<String?> speakerId,
      required int startMs,
      required int endMs,
      Value<String> language,
      required String content,
      Value<bool> edited,
      Value<double?> confidence,
      Value<int> rowid,
    });
typedef $$TranscriptSegmentsTableUpdateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<String> id,
      Value<String> meetingId,
      Value<String> audioSegmentId,
      Value<String?> speakerId,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> language,
      Value<String> content,
      Value<bool> edited,
      Value<double?> confidence,
      Value<int> rowid,
    });

class $$TranscriptSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableFilterComposer({
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

  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSegmentId => $composableBuilder(
    column: $table.audioSegmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speakerId => $composableBuilder(
    column: $table.speakerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableOrderingComposer({
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

  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSegmentId => $composableBuilder(
    column: $table.audioSegmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speakerId => $composableBuilder(
    column: $table.speakerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get audioSegmentId => $composableBuilder(
    column: $table.audioSegmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speakerId =>
      $composableBuilder(column: $table.speakerId, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );
}

class $$TranscriptSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptSegmentsTable,
          TranscriptSegment,
          $$TranscriptSegmentsTableFilterComposer,
          $$TranscriptSegmentsTableOrderingComposer,
          $$TranscriptSegmentsTableAnnotationComposer,
          $$TranscriptSegmentsTableCreateCompanionBuilder,
          $$TranscriptSegmentsTableUpdateCompanionBuilder,
          (
            TranscriptSegment,
            BaseReferences<
              _$AppDatabase,
              $TranscriptSegmentsTable,
              TranscriptSegment
            >,
          ),
          TranscriptSegment,
          PrefetchHooks Function()
        > {
  $$TranscriptSegmentsTableTableManager(
    _$AppDatabase db,
    $TranscriptSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptSegmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> meetingId = const Value.absent(),
                Value<String> audioSegmentId = const Value.absent(),
                Value<String?> speakerId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> edited = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptSegmentsCompanion(
                id: id,
                meetingId: meetingId,
                audioSegmentId: audioSegmentId,
                speakerId: speakerId,
                startMs: startMs,
                endMs: endMs,
                language: language,
                content: content,
                edited: edited,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String meetingId,
                required String audioSegmentId,
                Value<String?> speakerId = const Value.absent(),
                required int startMs,
                required int endMs,
                Value<String> language = const Value.absent(),
                required String content,
                Value<bool> edited = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptSegmentsCompanion.insert(
                id: id,
                meetingId: meetingId,
                audioSegmentId: audioSegmentId,
                speakerId: speakerId,
                startMs: startMs,
                endMs: endMs,
                language: language,
                content: content,
                edited: edited,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptSegmentsTable,
      TranscriptSegment,
      $$TranscriptSegmentsTableFilterComposer,
      $$TranscriptSegmentsTableOrderingComposer,
      $$TranscriptSegmentsTableAnnotationComposer,
      $$TranscriptSegmentsTableCreateCompanionBuilder,
      $$TranscriptSegmentsTableUpdateCompanionBuilder,
      (
        TranscriptSegment,
        BaseReferences<
          _$AppDatabase,
          $TranscriptSegmentsTable,
          TranscriptSegment
        >,
      ),
      TranscriptSegment,
      PrefetchHooks Function()
    >;
typedef $$MeetingContextsTableCreateCompanionBuilder =
    MeetingContextsCompanion Function({
      required String meetingId,
      Value<String> dictionaryJson,
      Value<String> entitiesJson,
      Value<String> topicsJson,
      Value<String> decisionsJson,
      Value<String> actionsJson,
      Value<String> contextSummary,
      Value<int> rowid,
    });
typedef $$MeetingContextsTableUpdateCompanionBuilder =
    MeetingContextsCompanion Function({
      Value<String> meetingId,
      Value<String> dictionaryJson,
      Value<String> entitiesJson,
      Value<String> topicsJson,
      Value<String> decisionsJson,
      Value<String> actionsJson,
      Value<String> contextSummary,
      Value<int> rowid,
    });

class $$MeetingContextsTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingContextsTable> {
  $$MeetingContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dictionaryJson => $composableBuilder(
    column: $table.dictionaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionsJson => $composableBuilder(
    column: $table.decisionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeetingContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingContextsTable> {
  $$MeetingContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dictionaryJson => $composableBuilder(
    column: $table.dictionaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionsJson => $composableBuilder(
    column: $table.decisionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeetingContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingContextsTable> {
  $$MeetingContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<String> get dictionaryJson => $composableBuilder(
    column: $table.dictionaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionsJson => $composableBuilder(
    column: $table.decisionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionsJson => $composableBuilder(
    column: $table.actionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => column,
  );
}

class $$MeetingContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingContextsTable,
          MeetingContext,
          $$MeetingContextsTableFilterComposer,
          $$MeetingContextsTableOrderingComposer,
          $$MeetingContextsTableAnnotationComposer,
          $$MeetingContextsTableCreateCompanionBuilder,
          $$MeetingContextsTableUpdateCompanionBuilder,
          (
            MeetingContext,
            BaseReferences<
              _$AppDatabase,
              $MeetingContextsTable,
              MeetingContext
            >,
          ),
          MeetingContext,
          PrefetchHooks Function()
        > {
  $$MeetingContextsTableTableManager(
    _$AppDatabase db,
    $MeetingContextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> meetingId = const Value.absent(),
                Value<String> dictionaryJson = const Value.absent(),
                Value<String> entitiesJson = const Value.absent(),
                Value<String> topicsJson = const Value.absent(),
                Value<String> decisionsJson = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<String> contextSummary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingContextsCompanion(
                meetingId: meetingId,
                dictionaryJson: dictionaryJson,
                entitiesJson: entitiesJson,
                topicsJson: topicsJson,
                decisionsJson: decisionsJson,
                actionsJson: actionsJson,
                contextSummary: contextSummary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String meetingId,
                Value<String> dictionaryJson = const Value.absent(),
                Value<String> entitiesJson = const Value.absent(),
                Value<String> topicsJson = const Value.absent(),
                Value<String> decisionsJson = const Value.absent(),
                Value<String> actionsJson = const Value.absent(),
                Value<String> contextSummary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingContextsCompanion.insert(
                meetingId: meetingId,
                dictionaryJson: dictionaryJson,
                entitiesJson: entitiesJson,
                topicsJson: topicsJson,
                decisionsJson: decisionsJson,
                actionsJson: actionsJson,
                contextSummary: contextSummary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeetingContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingContextsTable,
      MeetingContext,
      $$MeetingContextsTableFilterComposer,
      $$MeetingContextsTableOrderingComposer,
      $$MeetingContextsTableAnnotationComposer,
      $$MeetingContextsTableCreateCompanionBuilder,
      $$MeetingContextsTableUpdateCompanionBuilder,
      (
        MeetingContext,
        BaseReferences<_$AppDatabase, $MeetingContextsTable, MeetingContext>,
      ),
      MeetingContext,
      PrefetchHooks Function()
    >;
typedef $$MeetingNotesTableCreateCompanionBuilder =
    MeetingNotesCompanion Function({
      required String id,
      required String meetingId,
      required int timestampMs,
      Value<String> content,
      Value<String> type,
      Value<int> rowid,
    });
typedef $$MeetingNotesTableUpdateCompanionBuilder =
    MeetingNotesCompanion Function({
      Value<String> id,
      Value<String> meetingId,
      Value<int> timestampMs,
      Value<String> content,
      Value<String> type,
      Value<int> rowid,
    });

class $$MeetingNotesTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingNotesTable> {
  $$MeetingNotesTableFilterComposer({
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

  ColumnFilters<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeetingNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingNotesTable> {
  $$MeetingNotesTableOrderingComposer({
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

  ColumnOrderings<String> get meetingId => $composableBuilder(
    column: $table.meetingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeetingNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingNotesTable> {
  $$MeetingNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingId =>
      $composableBuilder(column: $table.meetingId, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$MeetingNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingNotesTable,
          MeetingNote,
          $$MeetingNotesTableFilterComposer,
          $$MeetingNotesTableOrderingComposer,
          $$MeetingNotesTableAnnotationComposer,
          $$MeetingNotesTableCreateCompanionBuilder,
          $$MeetingNotesTableUpdateCompanionBuilder,
          (
            MeetingNote,
            BaseReferences<_$AppDatabase, $MeetingNotesTable, MeetingNote>,
          ),
          MeetingNote,
          PrefetchHooks Function()
        > {
  $$MeetingNotesTableTableManager(_$AppDatabase db, $MeetingNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> meetingId = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingNotesCompanion(
                id: id,
                meetingId: meetingId,
                timestampMs: timestampMs,
                content: content,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String meetingId,
                required int timestampMs,
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingNotesCompanion.insert(
                id: id,
                meetingId: meetingId,
                timestampMs: timestampMs,
                content: content,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeetingNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingNotesTable,
      MeetingNote,
      $$MeetingNotesTableFilterComposer,
      $$MeetingNotesTableOrderingComposer,
      $$MeetingNotesTableAnnotationComposer,
      $$MeetingNotesTableCreateCompanionBuilder,
      $$MeetingNotesTableUpdateCompanionBuilder,
      (
        MeetingNote,
        BaseReferences<_$AppDatabase, $MeetingNotesTable, MeetingNote>,
      ),
      MeetingNote,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeetingsTableTableManager get meetings =>
      $$MeetingsTableTableManager(_db, _db.meetings);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$AudioSegmentsTableTableManager get audioSegments =>
      $$AudioSegmentsTableTableManager(_db, _db.audioSegments);
  $$TranscriptSegmentsTableTableManager get transcriptSegments =>
      $$TranscriptSegmentsTableTableManager(_db, _db.transcriptSegments);
  $$MeetingContextsTableTableManager get meetingContexts =>
      $$MeetingContextsTableTableManager(_db, _db.meetingContexts);
  $$MeetingNotesTableTableManager get meetingNotes =>
      $$MeetingNotesTableTableManager(_db, _db.meetingNotes);
}
