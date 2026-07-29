import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [UserProfiles, FoodLogs, BookmarkedRecipes, Badges, CommunityPosts])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static AppDatabase? _instance;

  /// Singleton accessor — ensures one DB instance across the app.
  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed default badges
        await _seedDefaultBadges(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add monetization columns introduced in schema v2.
          await m.addColumn(userProfiles, userProfiles.isPremium);
          await m.addColumn(userProfiles, userProfiles.dailyScanCount);
          await m.addColumn(userProfiles, userProfiles.lastScanDate);
        }
        if (from < 3) {
          // Create FoodLogs table introduced in schema v3.
          await m.createTable(foodLogs);
        }
        if (from < 4) {
          // Create BookmarkedRecipes table introduced in schema v4.
          await m.createTable(bookmarkedRecipes);
        }
        if (from < 5) {
          // Create Badges and CommunityPosts tables introduced in schema v5.
          await m.createTable(badges);
          await m.createTable(communityPosts);
          // Seed default badges
          await _seedDefaultBadges(m);
        }
        if (from < 6) {
          // Add auth columns in schema v6.
          await m.addColumn(userProfiles, userProfiles.email);
          await m.addColumn(userProfiles, userProfiles.fullName);
          await m.addColumn(userProfiles, userProfiles.authToken);
        }
        if (from < 7) {
          // Recreate user_profiles to make sure all columns (especially gender)
          // have the correct nullable constraints as defined in drift tables.
          await customStatement('DROP TABLE IF EXISTS user_profiles;');
          await m.createTable(userProfiles);
        }
      },
    );
  }

  Future<void> _seedDefaultBadges(Migrator m) async {
    // Seeding badges with batch insert
    await batch((batch) {
      batch.insertAll(badges, [
        BadgesCompanion.insert(
          badgeCode: 'first_scan',
          title: 'First AI Scan',
          description: 'Berhasil memindai hidangan pertama menggunakan AI Vision.',
          iconPath: 'badge_first_scan',
        ),
        BadgesCompanion.insert(
          badgeCode: 'green_streak',
          title: 'Eco Warrior',
          description: 'Mengonsumsi hidangan nabati 5 kali berturut-turut.',
          iconPath: 'badge_eco_warrior',
        ),
        BadgesCompanion.insert(
          badgeCode: 'quiz_master',
          title: 'Quiz Master',
          description: 'Menjawab kuis harian gizi dengan benar.',
          iconPath: 'badge_quiz_master',
        ),
      ]);
    });
  }

  // ---------------------------------------------------------------------------
  // UserProfiles CRUD
  // ---------------------------------------------------------------------------

  /// Insert a new user profile and return the generated ID.
  Future<int> insertUserProfile(UserProfilesCompanion profile) {
    return into(userProfiles).insert(profile);
  }

  /// Retrieve the first (and typically only) user profile, or null.
  Future<UserProfile?> getUserProfile() {
    return (select(userProfiles)..limit(1)).getSingleOrNull();
  }

  /// Update an existing user profile by [profileId].
  Future<bool> updateUserProfile(int profileId, UserProfilesCompanion data) {
    return (update(userProfiles)..where((t) => t.id.equals(profileId)))
        .write(data)
        .then((rows) => rows > 0);
  }

  /// Delete all profiles (useful for re-onboarding / reset).
  Future<int> deleteAllProfiles() {
    return delete(userProfiles).go();
  }

  // ---------------------------------------------------------------------------
  // Scan Limit Management
  // ---------------------------------------------------------------------------

  /// Resets the daily scan counter if the current date differs from [lastScanDate].
  /// Returns the current scan count after potential reset.
  Future<int> resetDailyScanIfNeeded(int profileId, String today) async {
    final profile = await getUserProfile();
    if (profile == null) return 0;

    if (profile.lastScanDate != today) {
      await updateUserProfile(profileId, UserProfilesCompanion(
        dailyScanCount: const Value(0),
        lastScanDate: Value(today),
      ));
      return 0;
    }
    return profile.dailyScanCount;
  }

  /// Increments the daily scan counter by 1.
  Future<void> incrementDailyScanCount(int profileId, String today) async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final newCount = profile.lastScanDate == today
        ? profile.dailyScanCount + 1
        : 1;

    await updateUserProfile(profileId, UserProfilesCompanion(
      dailyScanCount: Value(newCount),
      lastScanDate: Value(today),
    ));
  }

  /// Adds [points] to the user's total points.
  Future<void> addPoints(int profileId, int points) async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final newTotal = profile.totalPoints + points;
    await updateUserProfile(profileId, UserProfilesCompanion(
      totalPoints: Value(newTotal < 0 ? 0 : newTotal),
    ));
  }

  // ---------------------------------------------------------------------------
  // FoodLogs CRUD
  // ---------------------------------------------------------------------------

  /// Insert a new food log entry and return the generated ID.
  Future<int> insertFoodLog(FoodLogsCompanion log) {
    return into(foodLogs).insert(log);
  }

  /// Get all food logs for a specific date (comparing by date only, not time).
  Future<List<FoodLog>> getFoodLogsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(foodLogs)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get today's food logs.
  Future<List<FoodLog>> getTodayFoodLogs() {
    return getFoodLogsByDate(DateTime.now());
  }

  /// Get all food logs ordered by creation date (newest first).
  Future<List<FoodLog>> getAllFoodLogs() {
    return (select(foodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Delete a food log by ID.
  Future<int> deleteFoodLog(int logId) {
    return (delete(foodLogs)..where((t) => t.id.equals(logId))).go();
  }

  // ---------------------------------------------------------------------------
  // BookmarkedRecipes CRUD
  // ---------------------------------------------------------------------------

  /// Insert a bookmarked recipe.
  Future<int> insertBookmarkedRecipe(BookmarkedRecipesCompanion recipe) {
    return into(bookmarkedRecipes).insert(recipe);
  }

  /// Get all bookmarked recipes.
  Future<List<BookmarkedRecipe>> getBookmarkedRecipes() {
    return select(bookmarkedRecipes).get();
  }

  /// Check if a recipe is bookmarked.
  Future<bool> isRecipeBookmarked(String rId) async {
    final query = select(bookmarkedRecipes)..where((t) => t.recipeId.equals(rId));
    final match = await query.getSingleOrNull();
    return match != null;
  }

  /// Delete a bookmarked recipe by recipeId.
  Future<int> deleteBookmarkedRecipe(String rId) {
    return (delete(bookmarkedRecipes)..where((t) => t.recipeId.equals(rId))).go();
  }

  // ---------------------------------------------------------------------------
  // Badges CRUD
  // ---------------------------------------------------------------------------

  /// Get all badges.
  Future<List<Badge>> getAllBadges() {
    return select(badges).get();
  }

  /// Unlock a badge by badgeCode.
  Future<bool> unlockBadge(String code) {
    return (update(badges)..where((t) => t.badgeCode.equals(code)))
        .write(BadgesCompanion(
          isUnlocked: const Value(true),
          unlockedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  // ---------------------------------------------------------------------------
  // CommunityPosts CRUD
  // ---------------------------------------------------------------------------

  /// Insert a community post.
  Future<int> insertCommunityPost(CommunityPostsCompanion post) {
    return into(communityPosts).insert(post);
  }

  /// Get all community posts ordered by creation date (newest first).
  Future<List<CommunityPost>> getCommunityPosts() {
    return (select(communityPosts)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Update likes on a post.
  Future<bool> updatePostLikes(int postId, int newLikesCount) {
    return (update(communityPosts)..where((t) => t.id.equals(postId)))
        .write(CommunityPostsCompanion(likesCount: Value(newLikesCount)))
        .then((rows) => rows > 0);
  }

  // ---------------------------------------------------------------------------
  // Sync Management
  // ---------------------------------------------------------------------------

  /// Fetch all food logs that have not been synced yet.
  Future<List<FoodLog>> getUnsyncedFoodLogs() {
    return (select(foodLogs)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Mark food log as synced.
  Future<bool> markFoodLogSynced(int logId) {
    return (update(foodLogs)..where((t) => t.id.equals(logId)))
        .write(const FoodLogsCompanion(isSynced: Value(true)))
        .then((rows) => rows > 0);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'newveg.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
