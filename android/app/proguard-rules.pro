# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# AdMob Rules
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# AndroidX / Support library
-dontwarn androidx.**
-dontwarn android.support.**

# Service Loader
-keep class * implements com.google.android.gms.common.api.Api$InternalApi { *; }
-keep class * implements com.google.android.gms.common.api.GoogleApi$Settings { *; }

# General
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**
-dontwarn io.flutter.embedding.**

# Keep everything in our app
-keep class com.kolatech.smartcalc.** { *; }
