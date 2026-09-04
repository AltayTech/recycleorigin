# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase / Google Play
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter embedding references Play Core split-install APIs used only for
# deferred components. This app does not ship deferred components, so those
# classes are not on the classpath. AGP 9 always runs R8 in full mode, which
# fails minify unless the missing references are ignored.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Gson / JSON (Dio)
-keepattributes Signature
-keepattributes *Annotation*
