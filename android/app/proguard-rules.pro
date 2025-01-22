# Keep androidx.lifecycle.DefaultLifecycleObserver from being obfuscated
# Necessary for using file_picker package on release builds
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Keep Dexterous packages from being obfuscated
# https://github.com/Dexterous/flutter_local_notifications/issues/101
-keep class com.dexterous.** { *; }

# SPDX-FileCopyrightText: 2016, microG Project Team
# SPDX-License-Identifier: CC0-1.0

# Keep AutoSafeParcelables
-keep public class * extends org.microg.safeparcel.AutoSafeParcelable {
    @org.microg.safeparcel.SafeParcelable.Field *;
    @org.microg.safeparcel.SafeParceled *;
}

# Keep asInterface method cause it's accessed from SafeParcel
-keepattributes InnerClasses
-keepclassmembers interface * extends android.os.IInterface {
    public static class *;
}
-keep public class * extends android.os.Binder { public static *; }