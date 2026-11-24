# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep your models
-keep class com.example.flutter_project.** { *; }

# Keep Firebase Auth/Firestore
-keepattributes *Annotation*
-keepattributes Signature
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }