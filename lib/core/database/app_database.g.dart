// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<HabitType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitType>($HabitsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<HabitColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitColor>($HabitsTable.$convertercolor);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<double> goal = GeneratedColumn<double>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<double> step = GeneratedColumn<double>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<QuantityUnit?, String> unit =
      GeneratedColumn<String>(
        'unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<QuantityUnit?>($HabitsTable.$converterunitn);
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleMode, String>
  scheduleMode = GeneratedColumn<String>(
    'schedule_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ScheduleMode>($HabitsTable.$converterscheduleMode);
  @override
  late final GeneratedColumnWithTypeConverter<Set<int>, int> activeDays =
      GeneratedColumn<int>(
        'active_days',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Set<int>>($HabitsTable.$converteractiveDays);
  static const VerificationMeta _timesPerWeekMeta = const VerificationMeta(
    'timesPerWeek',
  );
  @override
  late final GeneratedColumn<int> timesPerWeek = GeneratedColumn<int>(
    'times_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Moment, String> moment =
      GeneratedColumn<String>(
        'moment',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Moment>($HabitsTable.$convertermoment);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> reminders =
      GeneratedColumn<String>(
        'reminders',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($HabitsTable.$converterreminders);
  static const VerificationMeta _streakDangerAlertMeta = const VerificationMeta(
    'streakDangerAlert',
  );
  @override
  late final GeneratedColumn<bool> streakDangerAlert = GeneratedColumn<bool>(
    'streak_danger_alert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("streak_danger_alert" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, int> createdOn =
      GeneratedColumn<int>(
        'created_on',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Day>($HabitsTable.$convertercreatedOn);
  @override
  late final GeneratedColumnWithTypeConverter<Day?, int> archivedOn =
      GeneratedColumn<int>(
        'archived_on',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Day?>($HabitsTable.$converterarchivedOnn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    color,
    icon,
    goal,
    step,
    unit,
    scheduleMode,
    activeDays,
    timesPerWeek,
    moment,
    reminders,
    streakDangerAlert,
    createdOn,
    archivedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('times_per_week')) {
      context.handle(
        _timesPerWeekMeta,
        timesPerWeek.isAcceptableOrUnknown(
          data['times_per_week']!,
          _timesPerWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timesPerWeekMeta);
    }
    if (data.containsKey('streak_danger_alert')) {
      context.handle(
        _streakDangerAlertMeta,
        streakDangerAlert.isAcceptableOrUnknown(
          data['streak_danger_alert']!,
          _streakDangerAlertMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streakDangerAlertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $HabitsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      color: $HabitsTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}step'],
      )!,
      unit: $HabitsTable.$converterunitn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit'],
        ),
      ),
      scheduleMode: $HabitsTable.$converterscheduleMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_mode'],
        )!,
      ),
      activeDays: $HabitsTable.$converteractiveDays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}active_days'],
        )!,
      ),
      timesPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_week'],
      )!,
      moment: $HabitsTable.$convertermoment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}moment'],
        )!,
      ),
      reminders: $HabitsTable.$converterreminders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminders'],
        )!,
      ),
      streakDangerAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}streak_danger_alert'],
      )!,
      createdOn: $HabitsTable.$convertercreatedOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_on'],
        )!,
      ),
      archivedOn: $HabitsTable.$converterarchivedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_on'],
        ),
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitType, String, String> $convertertype =
      const EnumNameConverter<HabitType>(HabitType.values);
  static JsonTypeConverter2<HabitColor, String, String> $convertercolor =
      const EnumNameConverter<HabitColor>(HabitColor.values);
  static JsonTypeConverter2<QuantityUnit, String, String> $converterunit =
      const EnumNameConverter<QuantityUnit>(QuantityUnit.values);
  static JsonTypeConverter2<QuantityUnit?, String?, String?> $converterunitn =
      JsonTypeConverter2.asNullable($converterunit);
  static JsonTypeConverter2<ScheduleMode, String, String>
  $converterscheduleMode = const EnumNameConverter<ScheduleMode>(
    ScheduleMode.values,
  );
  static TypeConverter<Set<int>, int> $converteractiveDays =
      const WeekdaysConverter();
  static JsonTypeConverter2<Moment, String, String> $convertermoment =
      const EnumNameConverter<Moment>(Moment.values);
  static TypeConverter<List<int>, String> $converterreminders =
      const MinutesConverter();
  static TypeConverter<Day, int> $convertercreatedOn = const DayConverter();
  static TypeConverter<Day, int> $converterarchivedOn = const DayConverter();
  static TypeConverter<Day?, int?> $converterarchivedOnn =
      NullAwareTypeConverter.wrap($converterarchivedOn);
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final int id;
  final String name;
  final HabitType type;
  final HabitColor color;
  final String icon;
  final double goal;
  final double step;
  final QuantityUnit? unit;
  final ScheduleMode scheduleMode;
  final Set<int> activeDays;
  final int timesPerWeek;
  final Moment moment;
  final List<int> reminders;
  final bool streakDangerAlert;
  final Day createdOn;
  final Day? archivedOn;
  const HabitRow({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.goal,
    required this.step,
    this.unit,
    required this.scheduleMode,
    required this.activeDays,
    required this.timesPerWeek,
    required this.moment,
    required this.reminders,
    required this.streakDangerAlert,
    required this.createdOn,
    this.archivedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($HabitsTable.$convertertype.toSql(type));
    }
    {
      map['color'] = Variable<String>(
        $HabitsTable.$convertercolor.toSql(color),
      );
    }
    map['icon'] = Variable<String>(icon);
    map['goal'] = Variable<double>(goal);
    map['step'] = Variable<double>(step);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>($HabitsTable.$converterunitn.toSql(unit));
    }
    {
      map['schedule_mode'] = Variable<String>(
        $HabitsTable.$converterscheduleMode.toSql(scheduleMode),
      );
    }
    {
      map['active_days'] = Variable<int>(
        $HabitsTable.$converteractiveDays.toSql(activeDays),
      );
    }
    map['times_per_week'] = Variable<int>(timesPerWeek);
    {
      map['moment'] = Variable<String>(
        $HabitsTable.$convertermoment.toSql(moment),
      );
    }
    {
      map['reminders'] = Variable<String>(
        $HabitsTable.$converterreminders.toSql(reminders),
      );
    }
    map['streak_danger_alert'] = Variable<bool>(streakDangerAlert);
    {
      map['created_on'] = Variable<int>(
        $HabitsTable.$convertercreatedOn.toSql(createdOn),
      );
    }
    if (!nullToAbsent || archivedOn != null) {
      map['archived_on'] = Variable<int>(
        $HabitsTable.$converterarchivedOnn.toSql(archivedOn),
      );
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      color: Value(color),
      icon: Value(icon),
      goal: Value(goal),
      step: Value(step),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      scheduleMode: Value(scheduleMode),
      activeDays: Value(activeDays),
      timesPerWeek: Value(timesPerWeek),
      moment: Value(moment),
      reminders: Value(reminders),
      streakDangerAlert: Value(streakDangerAlert),
      createdOn: Value(createdOn),
      archivedOn: archivedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedOn),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $HabitsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      color: $HabitsTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
      icon: serializer.fromJson<String>(json['icon']),
      goal: serializer.fromJson<double>(json['goal']),
      step: serializer.fromJson<double>(json['step']),
      unit: $HabitsTable.$converterunitn.fromJson(
        serializer.fromJson<String?>(json['unit']),
      ),
      scheduleMode: $HabitsTable.$converterscheduleMode.fromJson(
        serializer.fromJson<String>(json['scheduleMode']),
      ),
      activeDays: serializer.fromJson<Set<int>>(json['activeDays']),
      timesPerWeek: serializer.fromJson<int>(json['timesPerWeek']),
      moment: $HabitsTable.$convertermoment.fromJson(
        serializer.fromJson<String>(json['moment']),
      ),
      reminders: serializer.fromJson<List<int>>(json['reminders']),
      streakDangerAlert: serializer.fromJson<bool>(json['streakDangerAlert']),
      createdOn: serializer.fromJson<Day>(json['createdOn']),
      archivedOn: serializer.fromJson<Day?>(json['archivedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $HabitsTable.$convertertype.toJson(type),
      ),
      'color': serializer.toJson<String>(
        $HabitsTable.$convertercolor.toJson(color),
      ),
      'icon': serializer.toJson<String>(icon),
      'goal': serializer.toJson<double>(goal),
      'step': serializer.toJson<double>(step),
      'unit': serializer.toJson<String?>(
        $HabitsTable.$converterunitn.toJson(unit),
      ),
      'scheduleMode': serializer.toJson<String>(
        $HabitsTable.$converterscheduleMode.toJson(scheduleMode),
      ),
      'activeDays': serializer.toJson<Set<int>>(activeDays),
      'timesPerWeek': serializer.toJson<int>(timesPerWeek),
      'moment': serializer.toJson<String>(
        $HabitsTable.$convertermoment.toJson(moment),
      ),
      'reminders': serializer.toJson<List<int>>(reminders),
      'streakDangerAlert': serializer.toJson<bool>(streakDangerAlert),
      'createdOn': serializer.toJson<Day>(createdOn),
      'archivedOn': serializer.toJson<Day?>(archivedOn),
    };
  }

  HabitRow copyWith({
    int? id,
    String? name,
    HabitType? type,
    HabitColor? color,
    String? icon,
    double? goal,
    double? step,
    Value<QuantityUnit?> unit = const Value.absent(),
    ScheduleMode? scheduleMode,
    Set<int>? activeDays,
    int? timesPerWeek,
    Moment? moment,
    List<int>? reminders,
    bool? streakDangerAlert,
    Day? createdOn,
    Value<Day?> archivedOn = const Value.absent(),
  }) => HabitRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    goal: goal ?? this.goal,
    step: step ?? this.step,
    unit: unit.present ? unit.value : this.unit,
    scheduleMode: scheduleMode ?? this.scheduleMode,
    activeDays: activeDays ?? this.activeDays,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    moment: moment ?? this.moment,
    reminders: reminders ?? this.reminders,
    streakDangerAlert: streakDangerAlert ?? this.streakDangerAlert,
    createdOn: createdOn ?? this.createdOn,
    archivedOn: archivedOn.present ? archivedOn.value : this.archivedOn,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      goal: data.goal.present ? data.goal.value : this.goal,
      step: data.step.present ? data.step.value : this.step,
      unit: data.unit.present ? data.unit.value : this.unit,
      scheduleMode: data.scheduleMode.present
          ? data.scheduleMode.value
          : this.scheduleMode,
      activeDays: data.activeDays.present
          ? data.activeDays.value
          : this.activeDays,
      timesPerWeek: data.timesPerWeek.present
          ? data.timesPerWeek.value
          : this.timesPerWeek,
      moment: data.moment.present ? data.moment.value : this.moment,
      reminders: data.reminders.present ? data.reminders.value : this.reminders,
      streakDangerAlert: data.streakDangerAlert.present
          ? data.streakDangerAlert.value
          : this.streakDangerAlert,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      archivedOn: data.archivedOn.present
          ? data.archivedOn.value
          : this.archivedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('goal: $goal, ')
          ..write('step: $step, ')
          ..write('unit: $unit, ')
          ..write('scheduleMode: $scheduleMode, ')
          ..write('activeDays: $activeDays, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('moment: $moment, ')
          ..write('reminders: $reminders, ')
          ..write('streakDangerAlert: $streakDangerAlert, ')
          ..write('createdOn: $createdOn, ')
          ..write('archivedOn: $archivedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    color,
    icon,
    goal,
    step,
    unit,
    scheduleMode,
    activeDays,
    timesPerWeek,
    moment,
    reminders,
    streakDangerAlert,
    createdOn,
    archivedOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.goal == this.goal &&
          other.step == this.step &&
          other.unit == this.unit &&
          other.scheduleMode == this.scheduleMode &&
          other.activeDays == this.activeDays &&
          other.timesPerWeek == this.timesPerWeek &&
          other.moment == this.moment &&
          other.reminders == this.reminders &&
          other.streakDangerAlert == this.streakDangerAlert &&
          other.createdOn == this.createdOn &&
          other.archivedOn == this.archivedOn);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<HabitType> type;
  final Value<HabitColor> color;
  final Value<String> icon;
  final Value<double> goal;
  final Value<double> step;
  final Value<QuantityUnit?> unit;
  final Value<ScheduleMode> scheduleMode;
  final Value<Set<int>> activeDays;
  final Value<int> timesPerWeek;
  final Value<Moment> moment;
  final Value<List<int>> reminders;
  final Value<bool> streakDangerAlert;
  final Value<Day> createdOn;
  final Value<Day?> archivedOn;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.goal = const Value.absent(),
    this.step = const Value.absent(),
    this.unit = const Value.absent(),
    this.scheduleMode = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.moment = const Value.absent(),
    this.reminders = const Value.absent(),
    this.streakDangerAlert = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.archivedOn = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required HabitType type,
    required HabitColor color,
    required String icon,
    required double goal,
    required double step,
    this.unit = const Value.absent(),
    required ScheduleMode scheduleMode,
    required Set<int> activeDays,
    required int timesPerWeek,
    required Moment moment,
    required List<int> reminders,
    required bool streakDangerAlert,
    required Day createdOn,
    this.archivedOn = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       color = Value(color),
       icon = Value(icon),
       goal = Value(goal),
       step = Value(step),
       scheduleMode = Value(scheduleMode),
       activeDays = Value(activeDays),
       timesPerWeek = Value(timesPerWeek),
       moment = Value(moment),
       reminders = Value(reminders),
       streakDangerAlert = Value(streakDangerAlert),
       createdOn = Value(createdOn);
  static Insertable<HabitRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<double>? goal,
    Expression<double>? step,
    Expression<String>? unit,
    Expression<String>? scheduleMode,
    Expression<int>? activeDays,
    Expression<int>? timesPerWeek,
    Expression<String>? moment,
    Expression<String>? reminders,
    Expression<bool>? streakDangerAlert,
    Expression<int>? createdOn,
    Expression<int>? archivedOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (goal != null) 'goal': goal,
      if (step != null) 'step': step,
      if (unit != null) 'unit': unit,
      if (scheduleMode != null) 'schedule_mode': scheduleMode,
      if (activeDays != null) 'active_days': activeDays,
      if (timesPerWeek != null) 'times_per_week': timesPerWeek,
      if (moment != null) 'moment': moment,
      if (reminders != null) 'reminders': reminders,
      if (streakDangerAlert != null) 'streak_danger_alert': streakDangerAlert,
      if (createdOn != null) 'created_on': createdOn,
      if (archivedOn != null) 'archived_on': archivedOn,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<HabitType>? type,
    Value<HabitColor>? color,
    Value<String>? icon,
    Value<double>? goal,
    Value<double>? step,
    Value<QuantityUnit?>? unit,
    Value<ScheduleMode>? scheduleMode,
    Value<Set<int>>? activeDays,
    Value<int>? timesPerWeek,
    Value<Moment>? moment,
    Value<List<int>>? reminders,
    Value<bool>? streakDangerAlert,
    Value<Day>? createdOn,
    Value<Day?>? archivedOn,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      goal: goal ?? this.goal,
      step: step ?? this.step,
      unit: unit ?? this.unit,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      activeDays: activeDays ?? this.activeDays,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      moment: moment ?? this.moment,
      reminders: reminders ?? this.reminders,
      streakDangerAlert: streakDangerAlert ?? this.streakDangerAlert,
      createdOn: createdOn ?? this.createdOn,
      archivedOn: archivedOn ?? this.archivedOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $HabitsTable.$convertertype.toSql(type.value),
      );
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $HabitsTable.$convertercolor.toSql(color.value),
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (goal.present) {
      map['goal'] = Variable<double>(goal.value);
    }
    if (step.present) {
      map['step'] = Variable<double>(step.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(
        $HabitsTable.$converterunitn.toSql(unit.value),
      );
    }
    if (scheduleMode.present) {
      map['schedule_mode'] = Variable<String>(
        $HabitsTable.$converterscheduleMode.toSql(scheduleMode.value),
      );
    }
    if (activeDays.present) {
      map['active_days'] = Variable<int>(
        $HabitsTable.$converteractiveDays.toSql(activeDays.value),
      );
    }
    if (timesPerWeek.present) {
      map['times_per_week'] = Variable<int>(timesPerWeek.value);
    }
    if (moment.present) {
      map['moment'] = Variable<String>(
        $HabitsTable.$convertermoment.toSql(moment.value),
      );
    }
    if (reminders.present) {
      map['reminders'] = Variable<String>(
        $HabitsTable.$converterreminders.toSql(reminders.value),
      );
    }
    if (streakDangerAlert.present) {
      map['streak_danger_alert'] = Variable<bool>(streakDangerAlert.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<int>(
        $HabitsTable.$convertercreatedOn.toSql(createdOn.value),
      );
    }
    if (archivedOn.present) {
      map['archived_on'] = Variable<int>(
        $HabitsTable.$converterarchivedOnn.toSql(archivedOn.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('goal: $goal, ')
          ..write('step: $step, ')
          ..write('unit: $unit, ')
          ..write('scheduleMode: $scheduleMode, ')
          ..write('activeDays: $activeDays, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('moment: $moment, ')
          ..write('reminders: $reminders, ')
          ..write('streakDangerAlert: $streakDangerAlert, ')
          ..write('createdOn: $createdOn, ')
          ..write('archivedOn: $archivedOn')
          ..write(')'))
        .toString();
  }
}

class $PausesTable extends Pauses with TableInfo<$PausesTable, PauseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, int> fromDay =
      GeneratedColumn<int>(
        'from_day',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Day>($PausesTable.$converterfromDay);
  @override
  late final GeneratedColumnWithTypeConverter<Day, int> toDay =
      GeneratedColumn<int>(
        'to_day',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Day>($PausesTable.$convertertoDay);
  @override
  List<GeneratedColumn> get $columns => [id, habitId, fromDay, toDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<PauseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PauseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PauseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      fromDay: $PausesTable.$converterfromDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}from_day'],
        )!,
      ),
      toDay: $PausesTable.$convertertoDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}to_day'],
        )!,
      ),
    );
  }

  @override
  $PausesTable createAlias(String alias) {
    return $PausesTable(attachedDatabase, alias);
  }

  static TypeConverter<Day, int> $converterfromDay = const DayConverter();
  static TypeConverter<Day, int> $convertertoDay = const DayConverter();
}

class PauseRow extends DataClass implements Insertable<PauseRow> {
  final int id;
  final int habitId;
  final Day fromDay;
  final Day toDay;
  const PauseRow({
    required this.id,
    required this.habitId,
    required this.fromDay,
    required this.toDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    {
      map['from_day'] = Variable<int>(
        $PausesTable.$converterfromDay.toSql(fromDay),
      );
    }
    {
      map['to_day'] = Variable<int>($PausesTable.$convertertoDay.toSql(toDay));
    }
    return map;
  }

  PausesCompanion toCompanion(bool nullToAbsent) {
    return PausesCompanion(
      id: Value(id),
      habitId: Value(habitId),
      fromDay: Value(fromDay),
      toDay: Value(toDay),
    );
  }

  factory PauseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PauseRow(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      fromDay: serializer.fromJson<Day>(json['fromDay']),
      toDay: serializer.fromJson<Day>(json['toDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'fromDay': serializer.toJson<Day>(fromDay),
      'toDay': serializer.toJson<Day>(toDay),
    };
  }

  PauseRow copyWith({int? id, int? habitId, Day? fromDay, Day? toDay}) =>
      PauseRow(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        fromDay: fromDay ?? this.fromDay,
        toDay: toDay ?? this.toDay,
      );
  PauseRow copyWithCompanion(PausesCompanion data) {
    return PauseRow(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      fromDay: data.fromDay.present ? data.fromDay.value : this.fromDay,
      toDay: data.toDay.present ? data.toDay.value : this.toDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PauseRow(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('fromDay: $fromDay, ')
          ..write('toDay: $toDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, fromDay, toDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PauseRow &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.fromDay == this.fromDay &&
          other.toDay == this.toDay);
}

class PausesCompanion extends UpdateCompanion<PauseRow> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<Day> fromDay;
  final Value<Day> toDay;
  const PausesCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.fromDay = const Value.absent(),
    this.toDay = const Value.absent(),
  });
  PausesCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required Day fromDay,
    required Day toDay,
  }) : habitId = Value(habitId),
       fromDay = Value(fromDay),
       toDay = Value(toDay);
  static Insertable<PauseRow> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<int>? fromDay,
    Expression<int>? toDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (fromDay != null) 'from_day': fromDay,
      if (toDay != null) 'to_day': toDay,
    });
  }

  PausesCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<Day>? fromDay,
    Value<Day>? toDay,
  }) {
    return PausesCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      fromDay: fromDay ?? this.fromDay,
      toDay: toDay ?? this.toDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (fromDay.present) {
      map['from_day'] = Variable<int>(
        $PausesTable.$converterfromDay.toSql(fromDay.value),
      );
    }
    if (toDay.present) {
      map['to_day'] = Variable<int>(
        $PausesTable.$convertertoDay.toSql(toDay.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PausesCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('fromDay: $fromDay, ')
          ..write('toDay: $toDay')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, int> day =
      GeneratedColumn<int>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Day>($EntriesTable.$converterday);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, day, value, note, mood];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, day};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      day: $EntriesTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}day'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Day, int> $converterday = const DayConverter();
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final int habitId;
  final Day day;
  final double value;
  final String? note;
  final int? mood;
  const EntryRow({
    required this.habitId,
    required this.day,
    required this.value,
    this.note,
    this.mood,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<int>(habitId);
    {
      map['day'] = Variable<int>($EntriesTable.$converterday.toSql(day));
    }
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      habitId: Value(habitId),
      day: Value(day),
      value: Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      habitId: serializer.fromJson<int>(json['habitId']),
      day: serializer.fromJson<Day>(json['day']),
      value: serializer.fromJson<double>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
      mood: serializer.fromJson<int?>(json['mood']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<int>(habitId),
      'day': serializer.toJson<Day>(day),
      'value': serializer.toJson<double>(value),
      'note': serializer.toJson<String?>(note),
      'mood': serializer.toJson<int?>(mood),
    };
  }

  EntryRow copyWith({
    int? habitId,
    Day? day,
    double? value,
    Value<String?> note = const Value.absent(),
    Value<int?> mood = const Value.absent(),
  }) => EntryRow(
    habitId: habitId ?? this.habitId,
    day: day ?? this.day,
    value: value ?? this.value,
    note: note.present ? note.value : this.note,
    mood: mood.present ? mood.value : this.mood,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      day: data.day.present ? data.day.value : this.day,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
      mood: data.mood.present ? data.mood.value : this.mood,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('mood: $mood')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, day, value, note, mood);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.habitId == this.habitId &&
          other.day == this.day &&
          other.value == this.value &&
          other.note == this.note &&
          other.mood == this.mood);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<int> habitId;
  final Value<Day> day;
  final Value<double> value;
  final Value<String?> note;
  final Value<int?> mood;
  final Value<int> rowid;
  const EntriesCompanion({
    this.habitId = const Value.absent(),
    this.day = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.mood = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required int habitId,
    required Day day,
    required double value,
    this.note = const Value.absent(),
    this.mood = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       day = Value(day),
       value = Value(value);
  static Insertable<EntryRow> custom({
    Expression<int>? habitId,
    Expression<int>? day,
    Expression<double>? value,
    Expression<String>? note,
    Expression<int>? mood,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (day != null) 'day': day,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (mood != null) 'mood': mood,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? habitId,
    Value<Day>? day,
    Value<double>? value,
    Value<String?>? note,
    Value<int?>? mood,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      habitId: habitId ?? this.habitId,
      day: day ?? this.day,
      value: value ?? this.value,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (day.present) {
      map['day'] = Variable<int>($EntriesTable.$converterday.toSql(day.value));
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('mood: $mood, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JokerDaysTable extends JokerDays
    with TableInfo<$JokerDaysTable, JokerDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JokerDaysTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Day, int> day =
      GeneratedColumn<int>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Day>($JokerDaysTable.$converterday);
  @override
  List<GeneratedColumn> get $columns => [day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'joker_days';
  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  JokerDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JokerDayRow(
      day: $JokerDaysTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}day'],
        )!,
      ),
    );
  }

  @override
  $JokerDaysTable createAlias(String alias) {
    return $JokerDaysTable(attachedDatabase, alias);
  }

  static TypeConverter<Day, int> $converterday = const DayConverter();
}

class JokerDayRow extends DataClass implements Insertable<JokerDayRow> {
  final Day day;
  const JokerDayRow({required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['day'] = Variable<int>($JokerDaysTable.$converterday.toSql(day));
    }
    return map;
  }

  JokerDaysCompanion toCompanion(bool nullToAbsent) {
    return JokerDaysCompanion(day: Value(day));
  }

  factory JokerDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JokerDayRow(day: serializer.fromJson<Day>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<Day>(day)};
  }

  JokerDayRow copyWith({Day? day}) => JokerDayRow(day: day ?? this.day);
  JokerDayRow copyWithCompanion(JokerDaysCompanion data) {
    return JokerDayRow(day: data.day.present ? data.day.value : this.day);
  }

  @override
  String toString() {
    return (StringBuffer('JokerDayRow(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => day.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JokerDayRow && other.day == this.day);
}

class JokerDaysCompanion extends UpdateCompanion<JokerDayRow> {
  final Value<Day> day;
  const JokerDaysCompanion({this.day = const Value.absent()});
  JokerDaysCompanion.insert({this.day = const Value.absent()});
  static Insertable<JokerDayRow> custom({Expression<int>? day}) {
    return RawValuesInsertable({if (day != null) 'day': day});
  }

  JokerDaysCompanion copyWith({Value<Day>? day}) {
    return JokerDaysCompanion(day: day ?? this.day);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(
        $JokerDaysTable.$converterday.toSql(day.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JokerDaysCompanion(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $PausesTable pauses = $PausesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $JokerDaysTable jokerDays = $JokerDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    pauses,
    entries,
    jokerDays,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pauses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  required String name,
  required HabitType type,
  required HabitColor color,
  required String icon,
  required double goal,
  required double step,
  Value<QuantityUnit?> unit,
  required ScheduleMode scheduleMode,
  required Set<int> activeDays,
  required int timesPerWeek,
  required Moment moment,
  required List<int> reminders,
  required bool streakDangerAlert,
  required Day createdOn,
  Value<Day?> archivedOn,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<HabitType> type,
  Value<HabitColor> color,
  Value<String> icon,
  Value<double> goal,
  Value<double> step,
  Value<QuantityUnit?> unit,
  Value<ScheduleMode> scheduleMode,
  Value<Set<int>> activeDays,
  Value<int> timesPerWeek,
  Value<Moment> moment,
  Value<List<int>> reminders,
  Value<bool> streakDangerAlert,
  Value<Day> createdOn,
  Value<Day?> archivedOn,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitRow> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PausesTable, List<PauseRow>> _pausesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pauses,
    aliasName: 'habits__id__pauses__habit_id',
  );

  $$PausesTableProcessedTableManager get pausesRefs {
    final manager = $$PausesTableTableManager(
      $_db,
      $_db.pauses,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pausesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'habits__id__entries__habit_id',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitType, HabitType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<HabitColor, HabitColor, String> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QuantityUnit?, QuantityUnit, String>
  get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleMode, ScheduleMode, String>
  get scheduleMode => $composableBuilder(
    column: $table.scheduleMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<int>, Set<int>, int> get activeDays =>
      $composableBuilder(
        column: $table.activeDays,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Moment, Moment, String> get moment =>
      $composableBuilder(
        column: $table.moment,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get reminders =>
      $composableBuilder(
        column: $table.reminders,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get streakDangerAlert => $composableBuilder(
    column: $table.streakDangerAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, int> get createdOn =>
      $composableBuilder(
        column: $table.createdOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day?, Day, int> get archivedOn =>
      $composableBuilder(
        column: $table.archivedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> pausesRefs(
    Expression<bool> Function($$PausesTableFilterComposer f) f,
  ) {
    final $$PausesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PausesTableFilterComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleMode => $composableBuilder(
    column: $table.scheduleMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moment => $composableBuilder(
    column: $table.moment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminders => $composableBuilder(
    column: $table.reminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streakDangerAlert => $composableBuilder(
    column: $table.streakDangerAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedOn => $composableBuilder(
    column: $table.archivedOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<double> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<double> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QuantityUnit?, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleMode, String> get scheduleMode =>
      $composableBuilder(
        column: $table.scheduleMode,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Set<int>, int> get activeDays =>
      $composableBuilder(
        column: $table.activeDays,
        builder: (column) => column,
      );

  GeneratedColumn<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Moment, String> get moment =>
      $composableBuilder(column: $table.moment, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => column);

  GeneratedColumn<bool> get streakDangerAlert => $composableBuilder(
    column: $table.streakDangerAlert,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Day, int> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day?, int> get archivedOn =>
      $composableBuilder(
        column: $table.archivedOn,
        builder: (column) => column,
      );

  Expression<T> pausesRefs<T extends Object>(
    Expression<T> Function($$PausesTableAnnotationComposer a) f,
  ) {
    final $$PausesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauses,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PausesTableAnnotationComposer(
            $db: $db,
            $table: $db.pauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, $$HabitsTableReferences),
          HabitRow,
          PrefetchHooks Function({bool pausesRefs, bool entriesRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<HabitType> type = const Value.absent(),
                Value<HabitColor> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<double> goal = const Value.absent(),
                Value<double> step = const Value.absent(),
                Value<QuantityUnit?> unit = const Value.absent(),
                Value<ScheduleMode> scheduleMode = const Value.absent(),
                Value<Set<int>> activeDays = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<Moment> moment = const Value.absent(),
                Value<List<int>> reminders = const Value.absent(),
                Value<bool> streakDangerAlert = const Value.absent(),
                Value<Day> createdOn = const Value.absent(),
                Value<Day?> archivedOn = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                type: type,
                color: color,
                icon: icon,
                goal: goal,
                step: step,
                unit: unit,
                scheduleMode: scheduleMode,
                activeDays: activeDays,
                timesPerWeek: timesPerWeek,
                moment: moment,
                reminders: reminders,
                streakDangerAlert: streakDangerAlert,
                createdOn: createdOn,
                archivedOn: archivedOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required HabitType type,
                required HabitColor color,
                required String icon,
                required double goal,
                required double step,
                Value<QuantityUnit?> unit = const Value.absent(),
                required ScheduleMode scheduleMode,
                required Set<int> activeDays,
                required int timesPerWeek,
                required Moment moment,
                required List<int> reminders,
                required bool streakDangerAlert,
                required Day createdOn,
                Value<Day?> archivedOn = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                type: type,
                color: color,
                icon: icon,
                goal: goal,
                step: step,
                unit: unit,
                scheduleMode: scheduleMode,
                activeDays: activeDays,
                timesPerWeek: timesPerWeek,
                moment: moment,
                reminders: reminders,
                streakDangerAlert: streakDangerAlert,
                createdOn: createdOn,
                archivedOn: archivedOn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, HabitRow>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pausesRefs = false, entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pausesRefs) db.pauses,
                if (entriesRefs) db.entries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pausesRefs)
                    await $_getPrefetchedData<HabitRow, $HabitsTable, PauseRow>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences._pausesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).pausesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                  if (entriesRefs)
                    await $_getPrefetchedData<HabitRow, $HabitsTable, EntryRow>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, $$HabitsTableReferences),
      HabitRow,
      PrefetchHooks Function({bool pausesRefs, bool entriesRefs})
    >;
typedef $$PausesTableCreateCompanionBuilder = PausesCompanion Function({
  Value<int> id,
  required int habitId,
  required Day fromDay,
  required Day toDay,
});
typedef $$PausesTableUpdateCompanionBuilder = PausesCompanion Function({
  Value<int> id,
  Value<int> habitId,
  Value<Day> fromDay,
  Value<Day> toDay,
});

final class $$PausesTableReferences
    extends BaseReferences<_$AppDatabase, $PausesTable, PauseRow> {
  $$PausesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('pauses__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PausesTableFilterComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, int> get fromDay =>
      $composableBuilder(
        column: $table.fromDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day, Day, int> get toDay => $composableBuilder(
    column: $table.toDay,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableOrderingComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromDay => $composableBuilder(
    column: $table.fromDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toDay => $composableBuilder(
    column: $table.toDay,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day, int> get fromDay =>
      $composableBuilder(column: $table.fromDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day, int> get toDay =>
      $composableBuilder(column: $table.toDay, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PausesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PausesTable,
          PauseRow,
          $$PausesTableFilterComposer,
          $$PausesTableOrderingComposer,
          $$PausesTableAnnotationComposer,
          $$PausesTableCreateCompanionBuilder,
          $$PausesTableUpdateCompanionBuilder,
          (PauseRow, $$PausesTableReferences),
          PauseRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$PausesTableTableManager(_$AppDatabase db, $PausesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<Day> fromDay = const Value.absent(),
                Value<Day> toDay = const Value.absent(),
              }) => PausesCompanion(
                id: id,
                habitId: habitId,
                fromDay: fromDay,
                toDay: toDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required Day fromDay,
                required Day toDay,
              }) => PausesCompanion.insert(
                id: id,
                habitId: habitId,
                fromDay: fromDay,
                toDay: toDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PausesTable, PauseRow>(table),
                  $$PausesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$PausesTableReferences._habitIdTable(
                          db,
                        ),
                        referencedColumn: $$PausesTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PausesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PausesTable,
      PauseRow,
      $$PausesTableFilterComposer,
      $$PausesTableOrderingComposer,
      $$PausesTableAnnotationComposer,
      $$PausesTableCreateCompanionBuilder,
      $$PausesTableUpdateCompanionBuilder,
      (PauseRow, $$PausesTableReferences),
      PauseRow,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required int habitId,
  required Day day,
  required double value,
  Value<String?> note,
  Value<int?> mood,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<int> habitId,
  Value<Day> day,
  Value<double> value,
  Value<String?> note,
  Value<int?> mood,
  Value<int> rowid,
});

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, EntryRow> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('entries__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Day, Day, int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Day, int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, $$EntriesTableReferences),
          EntryRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> habitId = const Value.absent(),
                Value<Day> day = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                habitId: habitId,
                day: day,
                value: value,
                note: note,
                mood: mood,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int habitId,
                required Day day,
                required double value,
                Value<String?> note = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                habitId: habitId,
                day: day,
                value: value,
                note: note,
                mood: mood,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$EntriesTableReferences._habitIdTable(
                          db,
                        ),
                        referencedColumn: $$EntriesTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, $$EntriesTableReferences),
      EntryRow,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$JokerDaysTableCreateCompanionBuilder = JokerDaysCompanion Function({
  Value<Day> day,
});
typedef $$JokerDaysTableUpdateCompanionBuilder = JokerDaysCompanion Function({
  Value<Day> day,
});

class $$JokerDaysTableFilterComposer
    extends Composer<_$AppDatabase, $JokerDaysTable> {
  $$JokerDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Day, Day, int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$JokerDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $JokerDaysTable> {
  $$JokerDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JokerDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $JokerDaysTable> {
  $$JokerDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Day, int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$JokerDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JokerDaysTable,
          JokerDayRow,
          $$JokerDaysTableFilterComposer,
          $$JokerDaysTableOrderingComposer,
          $$JokerDaysTableAnnotationComposer,
          $$JokerDaysTableCreateCompanionBuilder,
          $$JokerDaysTableUpdateCompanionBuilder,
          (
            JokerDayRow,
            BaseReferences<_$AppDatabase, $JokerDaysTable, JokerDayRow>,
          ),
          JokerDayRow,
          PrefetchHooks Function()
        > {
  $$JokerDaysTableTableManager(_$AppDatabase db, $JokerDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JokerDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JokerDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JokerDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<Day> day = const Value.absent()}) =>
              JokerDaysCompanion(day: day),
          createCompanionCallback: ({Value<Day> day = const Value.absent()}) =>
              JokerDaysCompanion.insert(day: day),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JokerDaysTable, JokerDayRow>(table),
                  BaseReferences<_$AppDatabase, $JokerDaysTable, JokerDayRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JokerDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JokerDaysTable,
      JokerDayRow,
      $$JokerDaysTableFilterComposer,
      $$JokerDaysTableOrderingComposer,
      $$JokerDaysTableAnnotationComposer,
      $$JokerDaysTableCreateCompanionBuilder,
      $$JokerDaysTableUpdateCompanionBuilder,
      (
        JokerDayRow,
        BaseReferences<_$AppDatabase, $JokerDaysTable, JokerDayRow>,
      ),
      JokerDayRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$PausesTableTableManager get pauses =>
      $$PausesTableTableManager(_db, _db.pauses);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$JokerDaysTableTableManager get jokerDays =>
      $$JokerDaysTableTableManager(_db, _db.jokerDays);
}
