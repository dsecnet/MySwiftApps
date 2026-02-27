# ════════════════════════════════════════════════════════════════════
# CoreVia Android — ProGuard/R8 Rules
# ════════════════════════════════════════════════════════════════════

# ── General ────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable  # Crashlytics stack traces üçün
-renamesourcefileattribute SourceFile

# ── Retrofit ───────────────────────────────────────────────────────
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-dontwarn retrofit2.**

# ── Kotlinx Serialization ─────────────────────────────────────────
-keepattributes InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class life.corevia.app.data.model.** { *; }
-keep,includedescriptorclasses class life.corevia.app.data.model.**$$serializer { *; }
-keepclassmembers class life.corevia.app.data.model.** {
    *** Companion;
}
-keepclasseswithmembers class life.corevia.app.data.model.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# ── OkHttp ─────────────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
# SSL Pinning üçün kritik
-keep class okhttp3.CertificatePinner { *; }
-keep class okhttp3.CertificatePinner$Pin { *; }

# ── Coil ───────────────────────────────────────────────────────────
-keep class coil.** { *; }

# ── Hilt/Dagger ────────────────────────────────────────────────────
-dontwarn dagger.**
-keep class dagger.** { *; }
-keep class javax.inject.** { *; }
-keep class * extends dagger.hilt.android.internal.managers.ViewComponentManager { *; }

# ── ML Kit ─────────────────────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ── TensorFlow Lite ────────────────────────────────────────────────
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# ── Timber ─────────────────────────────────────────────────────────
-dontwarn timber.log.**

# ── Google Play Services ───────────────────────────────────────────
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ── Security: Obfuscate aggressively ──────────────────────────────
# Token, auth, security class-larını daha güclü obfuscate et
-repackageclasses 'a'
-allowaccessmodification
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*

# ── Remove Log statements in release ──────────────────────────────
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}
-assumenosideeffects class timber.log.Timber {
    public static void v(...);
    public static void d(...);
    public static void i(...);
    public static void w(...);
    public static void e(...);
}

# ── Enum protection ───────────────────────────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
