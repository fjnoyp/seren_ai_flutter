# Keep androidx.lifecycle.DefaultLifecycleObserver from being obfuscated
# Necessary for using file_picker package on release builds
-keep class androidx.lifecycle.DefaultLifecycleObserver
