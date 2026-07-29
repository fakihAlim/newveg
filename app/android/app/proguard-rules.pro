# ProGuard rules for release builds

# Drift / SQLite / SQLCipher
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-keep class com.sqlite.** { *; }

# Lottie animations
-keep class com.airbnb.lottie.** { *; }
