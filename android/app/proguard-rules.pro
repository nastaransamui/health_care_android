# Suppress warnings about missing classes
-dontwarn com.google.j2objc.annotations.ReflectionSupport
-keep class android.os.FileUtils { *; }
-keepclassmembers class * {
    public <init>(...);
}