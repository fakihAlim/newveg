// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dietPreferenceMeta = const VerificationMeta(
    'dietPreference',
  );
  @override
  late final GeneratedColumn<String> dietPreference = GeneratedColumn<String>(
    'diet_preference',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttmStageMeta = const VerificationMeta(
    'ttmStage',
  );
  @override
  late final GeneratedColumn<String> ttmStage = GeneratedColumn<String>(
    'ttm_stage',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPointsMeta = const VerificationMeta(
    'totalPoints',
  );
  @override
  late final GeneratedColumn<int> totalPoints = GeneratedColumn<int>(
    'total_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPremiumMeta = const VerificationMeta(
    'isPremium',
  );
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
    'is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyScanCountMeta = const VerificationMeta(
    'dailyScanCount',
  );
  @override
  late final GeneratedColumn<int> dailyScanCount = GeneratedColumn<int>(
    'daily_scan_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastScanDateMeta = const VerificationMeta(
    'lastScanDate',
  );
  @override
  late final GeneratedColumn<String> lastScanDate = GeneratedColumn<String>(
    'last_scan_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gender,
    age,
    height,
    weight,
    avatarPath,
    dietPreference,
    ttmStage,
    totalPoints,
    isPremium,
    dailyScanCount,
    lastScanDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarPathMeta);
    }
    if (data.containsKey('diet_preference')) {
      context.handle(
        _dietPreferenceMeta,
        dietPreference.isAcceptableOrUnknown(
          data['diet_preference']!,
          _dietPreferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dietPreferenceMeta);
    }
    if (data.containsKey('ttm_stage')) {
      context.handle(
        _ttmStageMeta,
        ttmStage.isAcceptableOrUnknown(data['ttm_stage']!, _ttmStageMeta),
      );
    } else if (isInserting) {
      context.missing(_ttmStageMeta);
    }
    if (data.containsKey('total_points')) {
      context.handle(
        _totalPointsMeta,
        totalPoints.isAcceptableOrUnknown(
          data['total_points']!,
          _totalPointsMeta,
        ),
      );
    }
    if (data.containsKey('is_premium')) {
      context.handle(
        _isPremiumMeta,
        isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta),
      );
    }
    if (data.containsKey('daily_scan_count')) {
      context.handle(
        _dailyScanCountMeta,
        dailyScanCount.isAcceptableOrUnknown(
          data['daily_scan_count']!,
          _dailyScanCountMeta,
        ),
      );
    }
    if (data.containsKey('last_scan_date')) {
      context.handle(
        _lastScanDateMeta,
        lastScanDate.isAcceptableOrUnknown(
          data['last_scan_date']!,
          _lastScanDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      )!,
      dietPreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diet_preference'],
      )!,
      ttmStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ttm_stage'],
      )!,
      totalPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_points'],
      )!,
      isPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_premium'],
      )!,
      dailyScanCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_scan_count'],
      )!,
      lastScanDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_scan_date'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String avatarPath;
  final String dietPreference;
  final String ttmStage;
  final int totalPoints;
  final bool isPremium;
  final int dailyScanCount;
  final String lastScanDate;
  const UserProfile({
    required this.id,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.avatarPath,
    required this.dietPreference,
    required this.ttmStage,
    required this.totalPoints,
    required this.isPremium,
    required this.dailyScanCount,
    required this.lastScanDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['gender'] = Variable<String>(gender);
    map['age'] = Variable<int>(age);
    map['height'] = Variable<double>(height);
    map['weight'] = Variable<double>(weight);
    map['avatar_path'] = Variable<String>(avatarPath);
    map['diet_preference'] = Variable<String>(dietPreference);
    map['ttm_stage'] = Variable<String>(ttmStage);
    map['total_points'] = Variable<int>(totalPoints);
    map['is_premium'] = Variable<bool>(isPremium);
    map['daily_scan_count'] = Variable<int>(dailyScanCount);
    map['last_scan_date'] = Variable<String>(lastScanDate);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      gender: Value(gender),
      age: Value(age),
      height: Value(height),
      weight: Value(weight),
      avatarPath: Value(avatarPath),
      dietPreference: Value(dietPreference),
      ttmStage: Value(ttmStage),
      totalPoints: Value(totalPoints),
      isPremium: Value(isPremium),
      dailyScanCount: Value(dailyScanCount),
      lastScanDate: Value(lastScanDate),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      gender: serializer.fromJson<String>(json['gender']),
      age: serializer.fromJson<int>(json['age']),
      height: serializer.fromJson<double>(json['height']),
      weight: serializer.fromJson<double>(json['weight']),
      avatarPath: serializer.fromJson<String>(json['avatarPath']),
      dietPreference: serializer.fromJson<String>(json['dietPreference']),
      ttmStage: serializer.fromJson<String>(json['ttmStage']),
      totalPoints: serializer.fromJson<int>(json['totalPoints']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      dailyScanCount: serializer.fromJson<int>(json['dailyScanCount']),
      lastScanDate: serializer.fromJson<String>(json['lastScanDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gender': serializer.toJson<String>(gender),
      'age': serializer.toJson<int>(age),
      'height': serializer.toJson<double>(height),
      'weight': serializer.toJson<double>(weight),
      'avatarPath': serializer.toJson<String>(avatarPath),
      'dietPreference': serializer.toJson<String>(dietPreference),
      'ttmStage': serializer.toJson<String>(ttmStage),
      'totalPoints': serializer.toJson<int>(totalPoints),
      'isPremium': serializer.toJson<bool>(isPremium),
      'dailyScanCount': serializer.toJson<int>(dailyScanCount),
      'lastScanDate': serializer.toJson<String>(lastScanDate),
    };
  }

  UserProfile copyWith({
    int? id,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? avatarPath,
    String? dietPreference,
    String? ttmStage,
    int? totalPoints,
    bool? isPremium,
    int? dailyScanCount,
    String? lastScanDate,
  }) => UserProfile(
    id: id ?? this.id,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    avatarPath: avatarPath ?? this.avatarPath,
    dietPreference: dietPreference ?? this.dietPreference,
    ttmStage: ttmStage ?? this.ttmStage,
    totalPoints: totalPoints ?? this.totalPoints,
    isPremium: isPremium ?? this.isPremium,
    dailyScanCount: dailyScanCount ?? this.dailyScanCount,
    lastScanDate: lastScanDate ?? this.lastScanDate,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      gender: data.gender.present ? data.gender.value : this.gender,
      age: data.age.present ? data.age.value : this.age,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      dietPreference: data.dietPreference.present
          ? data.dietPreference.value
          : this.dietPreference,
      ttmStage: data.ttmStage.present ? data.ttmStage.value : this.ttmStage,
      totalPoints: data.totalPoints.present
          ? data.totalPoints.value
          : this.totalPoints,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      dailyScanCount: data.dailyScanCount.present
          ? data.dailyScanCount.value
          : this.dailyScanCount,
      lastScanDate: data.lastScanDate.present
          ? data.lastScanDate.value
          : this.lastScanDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('dietPreference: $dietPreference, ')
          ..write('ttmStage: $ttmStage, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('isPremium: $isPremium, ')
          ..write('dailyScanCount: $dailyScanCount, ')
          ..write('lastScanDate: $lastScanDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gender,
    age,
    height,
    weight,
    avatarPath,
    dietPreference,
    ttmStage,
    totalPoints,
    isPremium,
    dailyScanCount,
    lastScanDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.gender == this.gender &&
          other.age == this.age &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.avatarPath == this.avatarPath &&
          other.dietPreference == this.dietPreference &&
          other.ttmStage == this.ttmStage &&
          other.totalPoints == this.totalPoints &&
          other.isPremium == this.isPremium &&
          other.dailyScanCount == this.dailyScanCount &&
          other.lastScanDate == this.lastScanDate);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> gender;
  final Value<int> age;
  final Value<double> height;
  final Value<double> weight;
  final Value<String> avatarPath;
  final Value<String> dietPreference;
  final Value<String> ttmStage;
  final Value<int> totalPoints;
  final Value<bool> isPremium;
  final Value<int> dailyScanCount;
  final Value<String> lastScanDate;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.dietPreference = const Value.absent(),
    this.ttmStage = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.dailyScanCount = const Value.absent(),
    this.lastScanDate = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String avatarPath,
    required String dietPreference,
    required String ttmStage,
    this.totalPoints = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.dailyScanCount = const Value.absent(),
    this.lastScanDate = const Value.absent(),
  }) : gender = Value(gender),
       age = Value(age),
       height = Value(height),
       weight = Value(weight),
       avatarPath = Value(avatarPath),
       dietPreference = Value(dietPreference),
       ttmStage = Value(ttmStage);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? gender,
    Expression<int>? age,
    Expression<double>? height,
    Expression<double>? weight,
    Expression<String>? avatarPath,
    Expression<String>? dietPreference,
    Expression<String>? ttmStage,
    Expression<int>? totalPoints,
    Expression<bool>? isPremium,
    Expression<int>? dailyScanCount,
    Expression<String>? lastScanDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (dietPreference != null) 'diet_preference': dietPreference,
      if (ttmStage != null) 'ttm_stage': ttmStage,
      if (totalPoints != null) 'total_points': totalPoints,
      if (isPremium != null) 'is_premium': isPremium,
      if (dailyScanCount != null) 'daily_scan_count': dailyScanCount,
      if (lastScanDate != null) 'last_scan_date': lastScanDate,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? gender,
    Value<int>? age,
    Value<double>? height,
    Value<double>? weight,
    Value<String>? avatarPath,
    Value<String>? dietPreference,
    Value<String>? ttmStage,
    Value<int>? totalPoints,
    Value<bool>? isPremium,
    Value<int>? dailyScanCount,
    Value<String>? lastScanDate,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      avatarPath: avatarPath ?? this.avatarPath,
      dietPreference: dietPreference ?? this.dietPreference,
      ttmStage: ttmStage ?? this.ttmStage,
      totalPoints: totalPoints ?? this.totalPoints,
      isPremium: isPremium ?? this.isPremium,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      lastScanDate: lastScanDate ?? this.lastScanDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (dietPreference.present) {
      map['diet_preference'] = Variable<String>(dietPreference.value);
    }
    if (ttmStage.present) {
      map['ttm_stage'] = Variable<String>(ttmStage.value);
    }
    if (totalPoints.present) {
      map['total_points'] = Variable<int>(totalPoints.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (dailyScanCount.present) {
      map['daily_scan_count'] = Variable<int>(dailyScanCount.value);
    }
    if (lastScanDate.present) {
      map['last_scan_date'] = Variable<String>(lastScanDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('dietPreference: $dietPreference, ')
          ..write('ttmStage: $ttmStage, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('isPremium: $isPremium, ')
          ..write('dailyScanCount: $dailyScanCount, ')
          ..write('lastScanDate: $lastScanDate')
          ..write(')'))
        .toString();
  }
}

class $FoodLogsTable extends FoodLogs with TableInfo<$FoodLogsTable, FoodLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
    'fats',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlantBasedMeta = const VerificationMeta(
    'isPlantBased',
  );
  @override
  late final GeneratedColumn<bool> isPlantBased = GeneratedColumn<bool>(
    'is_plant_based',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_plant_based" IN (0, 1))',
    ),
  );
  static const VerificationMeta _pointsEarnedMeta = const VerificationMeta(
    'pointsEarned',
  );
  @override
  late final GeneratedColumn<int> pointsEarned = GeneratedColumn<int>(
    'points_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    foodName,
    imagePath,
    calories,
    carbs,
    fats,
    protein,
    isPlantBased,
    pointsEarned,
    mealType,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fats')) {
      context.handle(
        _fatsMeta,
        fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatsMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('is_plant_based')) {
      context.handle(
        _isPlantBasedMeta,
        isPlantBased.isAcceptableOrUnknown(
          data['is_plant_based']!,
          _isPlantBasedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isPlantBasedMeta);
    }
    if (data.containsKey('points_earned')) {
      context.handle(
        _pointsEarnedMeta,
        pointsEarned.isAcceptableOrUnknown(
          data['points_earned']!,
          _pointsEarnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsEarnedMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      fats: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fats'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      isPlantBased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_plant_based'],
      )!,
      pointsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_earned'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $FoodLogsTable createAlias(String alias) {
    return $FoodLogsTable(attachedDatabase, alias);
  }
}

class FoodLog extends DataClass implements Insertable<FoodLog> {
  final int id;
  final String foodName;
  final String imagePath;
  final double calories;
  final double carbs;
  final double fats;
  final double protein;
  final bool isPlantBased;
  final int pointsEarned;
  final String mealType;
  final DateTime createdAt;
  final bool isSynced;
  const FoodLog({
    required this.id,
    required this.foodName,
    required this.imagePath,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.protein,
    required this.isPlantBased,
    required this.pointsEarned,
    required this.mealType,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['food_name'] = Variable<String>(foodName);
    map['image_path'] = Variable<String>(imagePath);
    map['calories'] = Variable<double>(calories);
    map['carbs'] = Variable<double>(carbs);
    map['fats'] = Variable<double>(fats);
    map['protein'] = Variable<double>(protein);
    map['is_plant_based'] = Variable<bool>(isPlantBased);
    map['points_earned'] = Variable<int>(pointsEarned);
    map['meal_type'] = Variable<String>(mealType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  FoodLogsCompanion toCompanion(bool nullToAbsent) {
    return FoodLogsCompanion(
      id: Value(id),
      foodName: Value(foodName),
      imagePath: Value(imagePath),
      calories: Value(calories),
      carbs: Value(carbs),
      fats: Value(fats),
      protein: Value(protein),
      isPlantBased: Value(isPlantBased),
      pointsEarned: Value(pointsEarned),
      mealType: Value(mealType),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory FoodLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLog(
      id: serializer.fromJson<int>(json['id']),
      foodName: serializer.fromJson<String>(json['foodName']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      calories: serializer.fromJson<double>(json['calories']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fats: serializer.fromJson<double>(json['fats']),
      protein: serializer.fromJson<double>(json['protein']),
      isPlantBased: serializer.fromJson<bool>(json['isPlantBased']),
      pointsEarned: serializer.fromJson<int>(json['pointsEarned']),
      mealType: serializer.fromJson<String>(json['mealType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'foodName': serializer.toJson<String>(foodName),
      'imagePath': serializer.toJson<String>(imagePath),
      'calories': serializer.toJson<double>(calories),
      'carbs': serializer.toJson<double>(carbs),
      'fats': serializer.toJson<double>(fats),
      'protein': serializer.toJson<double>(protein),
      'isPlantBased': serializer.toJson<bool>(isPlantBased),
      'pointsEarned': serializer.toJson<int>(pointsEarned),
      'mealType': serializer.toJson<String>(mealType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  FoodLog copyWith({
    int? id,
    String? foodName,
    String? imagePath,
    double? calories,
    double? carbs,
    double? fats,
    double? protein,
    bool? isPlantBased,
    int? pointsEarned,
    String? mealType,
    DateTime? createdAt,
    bool? isSynced,
  }) => FoodLog(
    id: id ?? this.id,
    foodName: foodName ?? this.foodName,
    imagePath: imagePath ?? this.imagePath,
    calories: calories ?? this.calories,
    carbs: carbs ?? this.carbs,
    fats: fats ?? this.fats,
    protein: protein ?? this.protein,
    isPlantBased: isPlantBased ?? this.isPlantBased,
    pointsEarned: pointsEarned ?? this.pointsEarned,
    mealType: mealType ?? this.mealType,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  FoodLog copyWithCompanion(FoodLogsCompanion data) {
    return FoodLog(
      id: data.id.present ? data.id.value : this.id,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      calories: data.calories.present ? data.calories.value : this.calories,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fats: data.fats.present ? data.fats.value : this.fats,
      protein: data.protein.present ? data.protein.value : this.protein,
      isPlantBased: data.isPlantBased.present
          ? data.isPlantBased.value
          : this.isPlantBased,
      pointsEarned: data.pointsEarned.present
          ? data.pointsEarned.value
          : this.pointsEarned,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLog(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('imagePath: $imagePath, ')
          ..write('calories: $calories, ')
          ..write('carbs: $carbs, ')
          ..write('fats: $fats, ')
          ..write('protein: $protein, ')
          ..write('isPlantBased: $isPlantBased, ')
          ..write('pointsEarned: $pointsEarned, ')
          ..write('mealType: $mealType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    foodName,
    imagePath,
    calories,
    carbs,
    fats,
    protein,
    isPlantBased,
    pointsEarned,
    mealType,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLog &&
          other.id == this.id &&
          other.foodName == this.foodName &&
          other.imagePath == this.imagePath &&
          other.calories == this.calories &&
          other.carbs == this.carbs &&
          other.fats == this.fats &&
          other.protein == this.protein &&
          other.isPlantBased == this.isPlantBased &&
          other.pointsEarned == this.pointsEarned &&
          other.mealType == this.mealType &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class FoodLogsCompanion extends UpdateCompanion<FoodLog> {
  final Value<int> id;
  final Value<String> foodName;
  final Value<String> imagePath;
  final Value<double> calories;
  final Value<double> carbs;
  final Value<double> fats;
  final Value<double> protein;
  final Value<bool> isPlantBased;
  final Value<int> pointsEarned;
  final Value<String> mealType;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const FoodLogsCompanion({
    this.id = const Value.absent(),
    this.foodName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.calories = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fats = const Value.absent(),
    this.protein = const Value.absent(),
    this.isPlantBased = const Value.absent(),
    this.pointsEarned = const Value.absent(),
    this.mealType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  FoodLogsCompanion.insert({
    this.id = const Value.absent(),
    required String foodName,
    required String imagePath,
    required double calories,
    required double carbs,
    required double fats,
    required double protein,
    required bool isPlantBased,
    required int pointsEarned,
    required String mealType,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : foodName = Value(foodName),
       imagePath = Value(imagePath),
       calories = Value(calories),
       carbs = Value(carbs),
       fats = Value(fats),
       protein = Value(protein),
       isPlantBased = Value(isPlantBased),
       pointsEarned = Value(pointsEarned),
       mealType = Value(mealType),
       createdAt = Value(createdAt);
  static Insertable<FoodLog> custom({
    Expression<int>? id,
    Expression<String>? foodName,
    Expression<String>? imagePath,
    Expression<double>? calories,
    Expression<double>? carbs,
    Expression<double>? fats,
    Expression<double>? protein,
    Expression<bool>? isPlantBased,
    Expression<int>? pointsEarned,
    Expression<String>? mealType,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodName != null) 'food_name': foodName,
      if (imagePath != null) 'image_path': imagePath,
      if (calories != null) 'calories': calories,
      if (carbs != null) 'carbs': carbs,
      if (fats != null) 'fats': fats,
      if (protein != null) 'protein': protein,
      if (isPlantBased != null) 'is_plant_based': isPlantBased,
      if (pointsEarned != null) 'points_earned': pointsEarned,
      if (mealType != null) 'meal_type': mealType,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  FoodLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? foodName,
    Value<String>? imagePath,
    Value<double>? calories,
    Value<double>? carbs,
    Value<double>? fats,
    Value<double>? protein,
    Value<bool>? isPlantBased,
    Value<int>? pointsEarned,
    Value<String>? mealType,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return FoodLogsCompanion(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      imagePath: imagePath ?? this.imagePath,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      protein: protein ?? this.protein,
      isPlantBased: isPlantBased ?? this.isPlantBased,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (isPlantBased.present) {
      map['is_plant_based'] = Variable<bool>(isPlantBased.value);
    }
    if (pointsEarned.present) {
      map['points_earned'] = Variable<int>(pointsEarned.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogsCompanion(')
          ..write('id: $id, ')
          ..write('foodName: $foodName, ')
          ..write('imagePath: $imagePath, ')
          ..write('calories: $calories, ')
          ..write('carbs: $carbs, ')
          ..write('fats: $fats, ')
          ..write('protein: $protein, ')
          ..write('isPlantBased: $isPlantBased, ')
          ..write('pointsEarned: $pointsEarned, ')
          ..write('mealType: $mealType, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $BookmarkedRecipesTable extends BookmarkedRecipes
    with TableInfo<$BookmarkedRecipesTable, BookmarkedRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkedRecipesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prepTimeMeta = const VerificationMeta(
    'prepTime',
  );
  @override
  late final GeneratedColumn<int> prepTime = GeneratedColumn<int>(
    'prep_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    title,
    imageUrl,
    calories,
    prepTime,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarked_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkedRecipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('prep_time')) {
      context.handle(
        _prepTimeMeta,
        prepTime.isAcceptableOrUnknown(data['prep_time']!, _prepTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_prepTimeMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkedRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkedRecipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      prepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $BookmarkedRecipesTable createAlias(String alias) {
    return $BookmarkedRecipesTable(attachedDatabase, alias);
  }
}

class BookmarkedRecipe extends DataClass
    implements Insertable<BookmarkedRecipe> {
  final int id;
  final String recipeId;
  final String title;
  final String imageUrl;
  final int calories;
  final int prepTime;
  final DateTime savedAt;
  const BookmarkedRecipe({
    required this.id,
    required this.recipeId,
    required this.title,
    required this.imageUrl,
    required this.calories,
    required this.prepTime,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['title'] = Variable<String>(title);
    map['image_url'] = Variable<String>(imageUrl);
    map['calories'] = Variable<int>(calories);
    map['prep_time'] = Variable<int>(prepTime);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  BookmarkedRecipesCompanion toCompanion(bool nullToAbsent) {
    return BookmarkedRecipesCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      title: Value(title),
      imageUrl: Value(imageUrl),
      calories: Value(calories),
      prepTime: Value(prepTime),
      savedAt: Value(savedAt),
    );
  }

  factory BookmarkedRecipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkedRecipe(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      title: serializer.fromJson<String>(json['title']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      calories: serializer.fromJson<int>(json['calories']),
      prepTime: serializer.fromJson<int>(json['prepTime']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'title': serializer.toJson<String>(title),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'calories': serializer.toJson<int>(calories),
      'prepTime': serializer.toJson<int>(prepTime),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  BookmarkedRecipe copyWith({
    int? id,
    String? recipeId,
    String? title,
    String? imageUrl,
    int? calories,
    int? prepTime,
    DateTime? savedAt,
  }) => BookmarkedRecipe(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    title: title ?? this.title,
    imageUrl: imageUrl ?? this.imageUrl,
    calories: calories ?? this.calories,
    prepTime: prepTime ?? this.prepTime,
    savedAt: savedAt ?? this.savedAt,
  );
  BookmarkedRecipe copyWithCompanion(BookmarkedRecipesCompanion data) {
    return BookmarkedRecipe(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      title: data.title.present ? data.title.value : this.title,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      calories: data.calories.present ? data.calories.value : this.calories,
      prepTime: data.prepTime.present ? data.prepTime.value : this.prepTime,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedRecipe(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('title: $title, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('calories: $calories, ')
          ..write('prepTime: $prepTime, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, title, imageUrl, calories, prepTime, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkedRecipe &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.title == this.title &&
          other.imageUrl == this.imageUrl &&
          other.calories == this.calories &&
          other.prepTime == this.prepTime &&
          other.savedAt == this.savedAt);
}

class BookmarkedRecipesCompanion extends UpdateCompanion<BookmarkedRecipe> {
  final Value<int> id;
  final Value<String> recipeId;
  final Value<String> title;
  final Value<String> imageUrl;
  final Value<int> calories;
  final Value<int> prepTime;
  final Value<DateTime> savedAt;
  const BookmarkedRecipesCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.title = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.calories = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  BookmarkedRecipesCompanion.insert({
    this.id = const Value.absent(),
    required String recipeId,
    required String title,
    required String imageUrl,
    required int calories,
    required int prepTime,
    required DateTime savedAt,
  }) : recipeId = Value(recipeId),
       title = Value(title),
       imageUrl = Value(imageUrl),
       calories = Value(calories),
       prepTime = Value(prepTime),
       savedAt = Value(savedAt);
  static Insertable<BookmarkedRecipe> custom({
    Expression<int>? id,
    Expression<String>? recipeId,
    Expression<String>? title,
    Expression<String>? imageUrl,
    Expression<int>? calories,
    Expression<int>? prepTime,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (title != null) 'title': title,
      if (imageUrl != null) 'image_url': imageUrl,
      if (calories != null) 'calories': calories,
      if (prepTime != null) 'prep_time': prepTime,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  BookmarkedRecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? recipeId,
    Value<String>? title,
    Value<String>? imageUrl,
    Value<int>? calories,
    Value<int>? prepTime,
    Value<DateTime>? savedAt,
  }) {
    return BookmarkedRecipesCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      prepTime: prepTime ?? this.prepTime,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (prepTime.present) {
      map['prep_time'] = Variable<int>(prepTime.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedRecipesCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('title: $title, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('calories: $calories, ')
          ..write('prepTime: $prepTime, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $BadgesTable extends Badges with TableInfo<$BadgesTable, Badge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _badgeCodeMeta = const VerificationMeta(
    'badgeCode',
  );
  @override
  late final GeneratedColumn<String> badgeCode = GeneratedColumn<String>(
    'badge_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 250,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    badgeCode,
    title,
    description,
    iconPath,
    isUnlocked,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Badge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('badge_code')) {
      context.handle(
        _badgeCodeMeta,
        badgeCode.isAcceptableOrUnknown(data['badge_code']!, _badgeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeCodeMeta);
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
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    } else if (isInserting) {
      context.missing(_iconPathMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Badge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Badge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      badgeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      )!,
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $BadgesTable createAlias(String alias) {
    return $BadgesTable(attachedDatabase, alias);
  }
}

class Badge extends DataClass implements Insertable<Badge> {
  final int id;
  final String badgeCode;
  final String title;
  final String description;
  final String iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  const Badge({
    required this.id,
    required this.badgeCode,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['badge_code'] = Variable<String>(badgeCode);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon_path'] = Variable<String>(iconPath);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  BadgesCompanion toCompanion(bool nullToAbsent) {
    return BadgesCompanion(
      id: Value(id),
      badgeCode: Value(badgeCode),
      title: Value(title),
      description: Value(description),
      iconPath: Value(iconPath),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory Badge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Badge(
      id: serializer.fromJson<int>(json['id']),
      badgeCode: serializer.fromJson<String>(json['badgeCode']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      iconPath: serializer.fromJson<String>(json['iconPath']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'badgeCode': serializer.toJson<String>(badgeCode),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'iconPath': serializer.toJson<String>(iconPath),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  Badge copyWith({
    int? id,
    String? badgeCode,
    String? title,
    String? description,
    String? iconPath,
    bool? isUnlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => Badge(
    id: id ?? this.id,
    badgeCode: badgeCode ?? this.badgeCode,
    title: title ?? this.title,
    description: description ?? this.description,
    iconPath: iconPath ?? this.iconPath,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  Badge copyWithCompanion(BadgesCompanion data) {
    return Badge(
      id: data.id.present ? data.id.value : this.id,
      badgeCode: data.badgeCode.present ? data.badgeCode.value : this.badgeCode,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Badge(')
          ..write('id: $id, ')
          ..write('badgeCode: $badgeCode, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconPath: $iconPath, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    badgeCode,
    title,
    description,
    iconPath,
    isUnlocked,
    unlockedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Badge &&
          other.id == this.id &&
          other.badgeCode == this.badgeCode &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconPath == this.iconPath &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt);
}

class BadgesCompanion extends UpdateCompanion<Badge> {
  final Value<int> id;
  final Value<String> badgeCode;
  final Value<String> title;
  final Value<String> description;
  final Value<String> iconPath;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  const BadgesCompanion({
    this.id = const Value.absent(),
    this.badgeCode = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  BadgesCompanion.insert({
    this.id = const Value.absent(),
    required String badgeCode,
    required String title,
    required String description,
    required String iconPath,
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  }) : badgeCode = Value(badgeCode),
       title = Value(title),
       description = Value(description),
       iconPath = Value(iconPath);
  static Insertable<Badge> custom({
    Expression<int>? id,
    Expression<String>? badgeCode,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconPath,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (badgeCode != null) 'badge_code': badgeCode,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconPath != null) 'icon_path': iconPath,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  BadgesCompanion copyWith({
    Value<int>? id,
    Value<String>? badgeCode,
    Value<String>? title,
    Value<String>? description,
    Value<String>? iconPath,
    Value<bool>? isUnlocked,
    Value<DateTime?>? unlockedAt,
  }) {
    return BadgesCompanion(
      id: id ?? this.id,
      badgeCode: badgeCode ?? this.badgeCode,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (badgeCode.present) {
      map['badge_code'] = Variable<String>(badgeCode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesCompanion(')
          ..write('id: $id, ')
          ..write('badgeCode: $badgeCode, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconPath: $iconPath, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $CommunityPostsTable extends CommunityPosts
    with TableInfo<$CommunityPostsTable, CommunityPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommunityPostsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userAvatarMeta = const VerificationMeta(
    'userAvatar',
  );
  @override
  late final GeneratedColumn<String> userAvatar = GeneratedColumn<String>(
    'user_avatar',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likesCountMeta = const VerificationMeta(
    'likesCount',
  );
  @override
  late final GeneratedColumn<int> likesCount = GeneratedColumn<int>(
    'likes_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userName,
    userAvatar,
    foodName,
    imageUrl,
    calories,
    likesCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'community_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommunityPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('user_avatar')) {
      context.handle(
        _userAvatarMeta,
        userAvatar.isAcceptableOrUnknown(data['user_avatar']!, _userAvatarMeta),
      );
    } else if (isInserting) {
      context.missing(_userAvatarMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('likes_count')) {
      context.handle(
        _likesCountMeta,
        likesCount.isAcceptableOrUnknown(data['likes_count']!, _likesCountMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommunityPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommunityPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      userAvatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_avatar'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      likesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}likes_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CommunityPostsTable createAlias(String alias) {
    return $CommunityPostsTable(attachedDatabase, alias);
  }
}

class CommunityPost extends DataClass implements Insertable<CommunityPost> {
  final int id;
  final String userName;
  final String userAvatar;
  final String foodName;
  final String imageUrl;
  final double calories;
  final int likesCount;
  final DateTime createdAt;
  const CommunityPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.likesCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_name'] = Variable<String>(userName);
    map['user_avatar'] = Variable<String>(userAvatar);
    map['food_name'] = Variable<String>(foodName);
    map['image_url'] = Variable<String>(imageUrl);
    map['calories'] = Variable<double>(calories);
    map['likes_count'] = Variable<int>(likesCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommunityPostsCompanion toCompanion(bool nullToAbsent) {
    return CommunityPostsCompanion(
      id: Value(id),
      userName: Value(userName),
      userAvatar: Value(userAvatar),
      foodName: Value(foodName),
      imageUrl: Value(imageUrl),
      calories: Value(calories),
      likesCount: Value(likesCount),
      createdAt: Value(createdAt),
    );
  }

  factory CommunityPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommunityPost(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      userAvatar: serializer.fromJson<String>(json['userAvatar']),
      foodName: serializer.fromJson<String>(json['foodName']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      calories: serializer.fromJson<double>(json['calories']),
      likesCount: serializer.fromJson<int>(json['likesCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String>(userName),
      'userAvatar': serializer.toJson<String>(userAvatar),
      'foodName': serializer.toJson<String>(foodName),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'calories': serializer.toJson<double>(calories),
      'likesCount': serializer.toJson<int>(likesCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CommunityPost copyWith({
    int? id,
    String? userName,
    String? userAvatar,
    String? foodName,
    String? imageUrl,
    double? calories,
    int? likesCount,
    DateTime? createdAt,
  }) => CommunityPost(
    id: id ?? this.id,
    userName: userName ?? this.userName,
    userAvatar: userAvatar ?? this.userAvatar,
    foodName: foodName ?? this.foodName,
    imageUrl: imageUrl ?? this.imageUrl,
    calories: calories ?? this.calories,
    likesCount: likesCount ?? this.likesCount,
    createdAt: createdAt ?? this.createdAt,
  );
  CommunityPost copyWithCompanion(CommunityPostsCompanion data) {
    return CommunityPost(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      userAvatar: data.userAvatar.present
          ? data.userAvatar.value
          : this.userAvatar,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      calories: data.calories.present ? data.calories.value : this.calories,
      likesCount: data.likesCount.present
          ? data.likesCount.value
          : this.likesCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommunityPost(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('foodName: $foodName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('calories: $calories, ')
          ..write('likesCount: $likesCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userName,
    userAvatar,
    foodName,
    imageUrl,
    calories,
    likesCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommunityPost &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.userAvatar == this.userAvatar &&
          other.foodName == this.foodName &&
          other.imageUrl == this.imageUrl &&
          other.calories == this.calories &&
          other.likesCount == this.likesCount &&
          other.createdAt == this.createdAt);
}

class CommunityPostsCompanion extends UpdateCompanion<CommunityPost> {
  final Value<int> id;
  final Value<String> userName;
  final Value<String> userAvatar;
  final Value<String> foodName;
  final Value<String> imageUrl;
  final Value<double> calories;
  final Value<int> likesCount;
  final Value<DateTime> createdAt;
  const CommunityPostsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.userAvatar = const Value.absent(),
    this.foodName = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.calories = const Value.absent(),
    this.likesCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CommunityPostsCompanion.insert({
    this.id = const Value.absent(),
    required String userName,
    required String userAvatar,
    required String foodName,
    required String imageUrl,
    required double calories,
    this.likesCount = const Value.absent(),
    required DateTime createdAt,
  }) : userName = Value(userName),
       userAvatar = Value(userAvatar),
       foodName = Value(foodName),
       imageUrl = Value(imageUrl),
       calories = Value(calories),
       createdAt = Value(createdAt);
  static Insertable<CommunityPost> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<String>? userAvatar,
    Expression<String>? foodName,
    Expression<String>? imageUrl,
    Expression<double>? calories,
    Expression<int>? likesCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (userAvatar != null) 'user_avatar': userAvatar,
      if (foodName != null) 'food_name': foodName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (calories != null) 'calories': calories,
      if (likesCount != null) 'likes_count': likesCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CommunityPostsCompanion copyWith({
    Value<int>? id,
    Value<String>? userName,
    Value<String>? userAvatar,
    Value<String>? foodName,
    Value<String>? imageUrl,
    Value<double>? calories,
    Value<int>? likesCount,
    Value<DateTime>? createdAt,
  }) {
    return CommunityPostsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      foodName: foodName ?? this.foodName,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (userAvatar.present) {
      map['user_avatar'] = Variable<String>(userAvatar.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (likesCount.present) {
      map['likes_count'] = Variable<int>(likesCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommunityPostsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('userAvatar: $userAvatar, ')
          ..write('foodName: $foodName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('calories: $calories, ')
          ..write('likesCount: $likesCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $FoodLogsTable foodLogs = $FoodLogsTable(this);
  late final $BookmarkedRecipesTable bookmarkedRecipes =
      $BookmarkedRecipesTable(this);
  late final $BadgesTable badges = $BadgesTable(this);
  late final $CommunityPostsTable communityPosts = $CommunityPostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    foodLogs,
    bookmarkedRecipes,
    badges,
    communityPosts,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String gender,
      required int age,
      required double height,
      required double weight,
      required String avatarPath,
      required String dietPreference,
      required String ttmStage,
      Value<int> totalPoints,
      Value<bool> isPremium,
      Value<int> dailyScanCount,
      Value<String> lastScanDate,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> gender,
      Value<int> age,
      Value<double> height,
      Value<double> weight,
      Value<String> avatarPath,
      Value<String> dietPreference,
      Value<String> ttmStage,
      Value<int> totalPoints,
      Value<bool> isPremium,
      Value<int> dailyScanCount,
      Value<String> lastScanDate,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietPreference => $composableBuilder(
    column: $table.dietPreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttmStage => $composableBuilder(
    column: $table.ttmStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyScanCount => $composableBuilder(
    column: $table.dailyScanCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastScanDate => $composableBuilder(
    column: $table.lastScanDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietPreference => $composableBuilder(
    column: $table.dietPreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttmStage => $composableBuilder(
    column: $table.ttmStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPremium => $composableBuilder(
    column: $table.isPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyScanCount => $composableBuilder(
    column: $table.dailyScanCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastScanDate => $composableBuilder(
    column: $table.lastScanDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietPreference => $composableBuilder(
    column: $table.dietPreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ttmStage =>
      $composableBuilder(column: $table.ttmStage, builder: (column) => column);

  GeneratedColumn<int> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<int> get dailyScanCount => $composableBuilder(
    column: $table.dailyScanCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastScanDate => $composableBuilder(
    column: $table.lastScanDate,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> avatarPath = const Value.absent(),
                Value<String> dietPreference = const Value.absent(),
                Value<String> ttmStage = const Value.absent(),
                Value<int> totalPoints = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> dailyScanCount = const Value.absent(),
                Value<String> lastScanDate = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                gender: gender,
                age: age,
                height: height,
                weight: weight,
                avatarPath: avatarPath,
                dietPreference: dietPreference,
                ttmStage: ttmStage,
                totalPoints: totalPoints,
                isPremium: isPremium,
                dailyScanCount: dailyScanCount,
                lastScanDate: lastScanDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gender,
                required int age,
                required double height,
                required double weight,
                required String avatarPath,
                required String dietPreference,
                required String ttmStage,
                Value<int> totalPoints = const Value.absent(),
                Value<bool> isPremium = const Value.absent(),
                Value<int> dailyScanCount = const Value.absent(),
                Value<String> lastScanDate = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                gender: gender,
                age: age,
                height: height,
                weight: weight,
                avatarPath: avatarPath,
                dietPreference: dietPreference,
                ttmStage: ttmStage,
                totalPoints: totalPoints,
                isPremium: isPremium,
                dailyScanCount: dailyScanCount,
                lastScanDate: lastScanDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$FoodLogsTableCreateCompanionBuilder =
    FoodLogsCompanion Function({
      Value<int> id,
      required String foodName,
      required String imagePath,
      required double calories,
      required double carbs,
      required double fats,
      required double protein,
      required bool isPlantBased,
      required int pointsEarned,
      required String mealType,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$FoodLogsTableUpdateCompanionBuilder =
    FoodLogsCompanion Function({
      Value<int> id,
      Value<String> foodName,
      Value<String> imagePath,
      Value<double> calories,
      Value<double> carbs,
      Value<double> fats,
      Value<double> protein,
      Value<bool> isPlantBased,
      Value<int> pointsEarned,
      Value<String> mealType,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$FoodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableFilterComposer({
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

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fats => $composableBuilder(
    column: $table.fats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlantBased => $composableBuilder(
    column: $table.isPlantBased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsEarned => $composableBuilder(
    column: $table.pointsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableOrderingComposer({
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

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fats => $composableBuilder(
    column: $table.fats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlantBased => $composableBuilder(
    column: $table.isPlantBased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsEarned => $composableBuilder(
    column: $table.pointsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fats =>
      $composableBuilder(column: $table.fats, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<bool> get isPlantBased => $composableBuilder(
    column: $table.isPlantBased,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsEarned => $composableBuilder(
    column: $table.pointsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$FoodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogsTable,
          FoodLog,
          $$FoodLogsTableFilterComposer,
          $$FoodLogsTableOrderingComposer,
          $$FoodLogsTableAnnotationComposer,
          $$FoodLogsTableCreateCompanionBuilder,
          $$FoodLogsTableUpdateCompanionBuilder,
          (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
          FoodLog,
          PrefetchHooks Function()
        > {
  $$FoodLogsTableTableManager(_$AppDatabase db, $FoodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fats = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<bool> isPlantBased = const Value.absent(),
                Value<int> pointsEarned = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => FoodLogsCompanion(
                id: id,
                foodName: foodName,
                imagePath: imagePath,
                calories: calories,
                carbs: carbs,
                fats: fats,
                protein: protein,
                isPlantBased: isPlantBased,
                pointsEarned: pointsEarned,
                mealType: mealType,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String foodName,
                required String imagePath,
                required double calories,
                required double carbs,
                required double fats,
                required double protein,
                required bool isPlantBased,
                required int pointsEarned,
                required String mealType,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => FoodLogsCompanion.insert(
                id: id,
                foodName: foodName,
                imagePath: imagePath,
                calories: calories,
                carbs: carbs,
                fats: fats,
                protein: protein,
                isPlantBased: isPlantBased,
                pointsEarned: pointsEarned,
                mealType: mealType,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogsTable,
      FoodLog,
      $$FoodLogsTableFilterComposer,
      $$FoodLogsTableOrderingComposer,
      $$FoodLogsTableAnnotationComposer,
      $$FoodLogsTableCreateCompanionBuilder,
      $$FoodLogsTableUpdateCompanionBuilder,
      (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
      FoodLog,
      PrefetchHooks Function()
    >;
typedef $$BookmarkedRecipesTableCreateCompanionBuilder =
    BookmarkedRecipesCompanion Function({
      Value<int> id,
      required String recipeId,
      required String title,
      required String imageUrl,
      required int calories,
      required int prepTime,
      required DateTime savedAt,
    });
typedef $$BookmarkedRecipesTableUpdateCompanionBuilder =
    BookmarkedRecipesCompanion Function({
      Value<int> id,
      Value<String> recipeId,
      Value<String> title,
      Value<String> imageUrl,
      Value<int> calories,
      Value<int> prepTime,
      Value<DateTime> savedAt,
    });

class $$BookmarkedRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkedRecipesTable> {
  $$BookmarkedRecipesTableFilterComposer({
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

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarkedRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkedRecipesTable> {
  $$BookmarkedRecipesTableOrderingComposer({
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

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkedRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkedRecipesTable> {
  $$BookmarkedRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get prepTime =>
      $composableBuilder(column: $table.prepTime, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$BookmarkedRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkedRecipesTable,
          BookmarkedRecipe,
          $$BookmarkedRecipesTableFilterComposer,
          $$BookmarkedRecipesTableOrderingComposer,
          $$BookmarkedRecipesTableAnnotationComposer,
          $$BookmarkedRecipesTableCreateCompanionBuilder,
          $$BookmarkedRecipesTableUpdateCompanionBuilder,
          (
            BookmarkedRecipe,
            BaseReferences<
              _$AppDatabase,
              $BookmarkedRecipesTable,
              BookmarkedRecipe
            >,
          ),
          BookmarkedRecipe,
          PrefetchHooks Function()
        > {
  $$BookmarkedRecipesTableTableManager(
    _$AppDatabase db,
    $BookmarkedRecipesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkedRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkedRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkedRecipesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> prepTime = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => BookmarkedRecipesCompanion(
                id: id,
                recipeId: recipeId,
                title: title,
                imageUrl: imageUrl,
                calories: calories,
                prepTime: prepTime,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recipeId,
                required String title,
                required String imageUrl,
                required int calories,
                required int prepTime,
                required DateTime savedAt,
              }) => BookmarkedRecipesCompanion.insert(
                id: id,
                recipeId: recipeId,
                title: title,
                imageUrl: imageUrl,
                calories: calories,
                prepTime: prepTime,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarkedRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkedRecipesTable,
      BookmarkedRecipe,
      $$BookmarkedRecipesTableFilterComposer,
      $$BookmarkedRecipesTableOrderingComposer,
      $$BookmarkedRecipesTableAnnotationComposer,
      $$BookmarkedRecipesTableCreateCompanionBuilder,
      $$BookmarkedRecipesTableUpdateCompanionBuilder,
      (
        BookmarkedRecipe,
        BaseReferences<
          _$AppDatabase,
          $BookmarkedRecipesTable,
          BookmarkedRecipe
        >,
      ),
      BookmarkedRecipe,
      PrefetchHooks Function()
    >;
typedef $$BadgesTableCreateCompanionBuilder =
    BadgesCompanion Function({
      Value<int> id,
      required String badgeCode,
      required String title,
      required String description,
      required String iconPath,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
    });
typedef $$BadgesTableUpdateCompanionBuilder =
    BadgesCompanion Function({
      Value<int> id,
      Value<String> badgeCode,
      Value<String> title,
      Value<String> description,
      Value<String> iconPath,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
    });

class $$BadgesTableFilterComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableFilterComposer({
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

  ColumnFilters<String> get badgeCode => $composableBuilder(
    column: $table.badgeCode,
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

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableOrderingComposer({
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

  ColumnOrderings<String> get badgeCode => $composableBuilder(
    column: $table.badgeCode,
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

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get badgeCode =>
      $composableBuilder(column: $table.badgeCode, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$BadgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgesTable,
          Badge,
          $$BadgesTableFilterComposer,
          $$BadgesTableOrderingComposer,
          $$BadgesTableAnnotationComposer,
          $$BadgesTableCreateCompanionBuilder,
          $$BadgesTableUpdateCompanionBuilder,
          (Badge, BaseReferences<_$AppDatabase, $BadgesTable, Badge>),
          Badge,
          PrefetchHooks Function()
        > {
  $$BadgesTableTableManager(_$AppDatabase db, $BadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> badgeCode = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> iconPath = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => BadgesCompanion(
                id: id,
                badgeCode: badgeCode,
                title: title,
                description: description,
                iconPath: iconPath,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String badgeCode,
                required String title,
                required String description,
                required String iconPath,
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
              }) => BadgesCompanion.insert(
                id: id,
                badgeCode: badgeCode,
                title: title,
                description: description,
                iconPath: iconPath,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgesTable,
      Badge,
      $$BadgesTableFilterComposer,
      $$BadgesTableOrderingComposer,
      $$BadgesTableAnnotationComposer,
      $$BadgesTableCreateCompanionBuilder,
      $$BadgesTableUpdateCompanionBuilder,
      (Badge, BaseReferences<_$AppDatabase, $BadgesTable, Badge>),
      Badge,
      PrefetchHooks Function()
    >;
typedef $$CommunityPostsTableCreateCompanionBuilder =
    CommunityPostsCompanion Function({
      Value<int> id,
      required String userName,
      required String userAvatar,
      required String foodName,
      required String imageUrl,
      required double calories,
      Value<int> likesCount,
      required DateTime createdAt,
    });
typedef $$CommunityPostsTableUpdateCompanionBuilder =
    CommunityPostsCompanion Function({
      Value<int> id,
      Value<String> userName,
      Value<String> userAvatar,
      Value<String> foodName,
      Value<String> imageUrl,
      Value<double> calories,
      Value<int> likesCount,
      Value<DateTime> createdAt,
    });

class $$CommunityPostsTableFilterComposer
    extends Composer<_$AppDatabase, $CommunityPostsTable> {
  $$CommunityPostsTableFilterComposer({
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

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAvatar => $composableBuilder(
    column: $table.userAvatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommunityPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommunityPostsTable> {
  $$CommunityPostsTableOrderingComposer({
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

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAvatar => $composableBuilder(
    column: $table.userAvatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommunityPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommunityPostsTable> {
  $$CommunityPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get userAvatar => $composableBuilder(
    column: $table.userAvatar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get likesCount => $composableBuilder(
    column: $table.likesCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CommunityPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommunityPostsTable,
          CommunityPost,
          $$CommunityPostsTableFilterComposer,
          $$CommunityPostsTableOrderingComposer,
          $$CommunityPostsTableAnnotationComposer,
          $$CommunityPostsTableCreateCompanionBuilder,
          $$CommunityPostsTableUpdateCompanionBuilder,
          (
            CommunityPost,
            BaseReferences<_$AppDatabase, $CommunityPostsTable, CommunityPost>,
          ),
          CommunityPost,
          PrefetchHooks Function()
        > {
  $$CommunityPostsTableTableManager(
    _$AppDatabase db,
    $CommunityPostsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommunityPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommunityPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommunityPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String> userAvatar = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<int> likesCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CommunityPostsCompanion(
                id: id,
                userName: userName,
                userAvatar: userAvatar,
                foodName: foodName,
                imageUrl: imageUrl,
                calories: calories,
                likesCount: likesCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userName,
                required String userAvatar,
                required String foodName,
                required String imageUrl,
                required double calories,
                Value<int> likesCount = const Value.absent(),
                required DateTime createdAt,
              }) => CommunityPostsCompanion.insert(
                id: id,
                userName: userName,
                userAvatar: userAvatar,
                foodName: foodName,
                imageUrl: imageUrl,
                calories: calories,
                likesCount: likesCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommunityPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommunityPostsTable,
      CommunityPost,
      $$CommunityPostsTableFilterComposer,
      $$CommunityPostsTableOrderingComposer,
      $$CommunityPostsTableAnnotationComposer,
      $$CommunityPostsTableCreateCompanionBuilder,
      $$CommunityPostsTableUpdateCompanionBuilder,
      (
        CommunityPost,
        BaseReferences<_$AppDatabase, $CommunityPostsTable, CommunityPost>,
      ),
      CommunityPost,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$FoodLogsTableTableManager get foodLogs =>
      $$FoodLogsTableTableManager(_db, _db.foodLogs);
  $$BookmarkedRecipesTableTableManager get bookmarkedRecipes =>
      $$BookmarkedRecipesTableTableManager(_db, _db.bookmarkedRecipes);
  $$BadgesTableTableManager get badges =>
      $$BadgesTableTableManager(_db, _db.badges);
  $$CommunityPostsTableTableManager get communityPosts =>
      $$CommunityPostsTableTableManager(_db, _db.communityPosts);
}
