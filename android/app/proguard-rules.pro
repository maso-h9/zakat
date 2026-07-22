# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.cloud.firestore.** { *; }

# Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }

# Firebase Remote Config
-keep class com.google.firebase.remoteconfig.** { *; }

# Gson (used by Firebase)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Model classes for Gson
-keep class com.example.flutter_application_1.** { *; }

# Hive
-keep class com.google.gson.** { *; }
-keep class * extends org.apache.hive.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# timezone
-keep class org.joda.time.** { *; }
