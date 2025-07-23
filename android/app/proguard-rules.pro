# Suppress warnings about missing classes
-dontwarn com.google.j2objc.annotations.ReflectionSupport
-keep class android.os.FileUtils { *; }
-keepclassmembers class * {
    public <init>(...);
}
# Flutter WebRTC
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class org.webrtc.** { *; }