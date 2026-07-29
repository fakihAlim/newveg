import 'package:drift/drift.dart';

/// SQLite table definition for user profiles.
/// Contains all onboarding data: demographics, avatar, diet preference, TTM stage,
/// and monetization flags (premium status, scan limits).
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gender => text().withLength(min: 1, max: 10)();
  IntColumn get age => integer()();
  RealColumn get height => real()();
  RealColumn get weight => real()();
  TextColumn get avatarPath => text().withLength(min: 1, max: 100)();
  TextColumn get dietPreference => text().withLength(min: 1, max: 50)();
  TextColumn get ttmStage => text().withLength(min: 1, max: 50)();
  IntColumn get totalPoints => integer().withDefault(const Constant(0))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  IntColumn get dailyScanCount => integer().withDefault(const Constant(0))();
  TextColumn get lastScanDate => text().withDefault(const Constant(''))();
}

/// SQLite table definition for food logs.
/// Each row represents a single meal entry with AI-analyzed nutritional data,
/// compliance status, and gamification points.
class FoodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get foodName => text().withLength(min: 1, max: 200)();
  TextColumn get imagePath => text()();
  RealColumn get calories => real()();
  RealColumn get carbs => real()();
  RealColumn get fats => real()();
  RealColumn get protein => real()();
  BoolColumn get isPlantBased => boolean()();
  IntColumn get pointsEarned => integer()();
  TextColumn get mealType => text().withLength(min: 1, max: 20)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
/// SQLite table definition for bookmarked recipes.
class BookmarkedRecipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().withLength(min: 1, max: 50)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get imageUrl => text()();
  IntColumn get calories => integer()();
  IntColumn get prepTime => integer()();
  DateTimeColumn get savedAt => dateTime()();
}

/// SQLite table definition for user achievements / badges.
class Badges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get badgeCode => text().withLength(min: 1, max: 50)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withLength(min: 1, max: 250)();
  TextColumn get iconPath => text().withLength(min: 1, max: 100)();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

/// SQLite table definition for community feed posts.
class CommunityPosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userName => text().withLength(min: 1, max: 100)();
  TextColumn get userAvatar => text().withLength(min: 1, max: 100)();
  TextColumn get foodName => text().withLength(min: 1, max: 200)();
  TextColumn get imageUrl => text()();
  RealColumn get calories => real()();
  IntColumn get likesCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
