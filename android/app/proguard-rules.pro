# Keep androidx.lifecycle.DefaultLifecycleObserver from being obfuscated
# Necessary for using file_picker package on release builds
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Keep Dexterous packages from being obfuscated
# https://github.com/Dexterous/flutter_local_notifications/issues/101
-keep class com.dexterous.** { *; }