# Giữ Firebase / Crashlytics
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Giữ native / JNI
-keepclasseswithmembernames class * {
    native <methods>;
}
