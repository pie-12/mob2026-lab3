# ============================================================
# VKU Expense Tracker — R8 / ProGuard rules
# ------------------------------------------------------------
# google_mlkit_text_recognition references ALL script recognizers
# (Chinese, Devanagari, Japanese, Korean) even though only the Latin
# model artifact is bundled in this app. R8 (release shrinking)
# otherwise fails with "Missing class" errors.
# ============================================================

# Silence missing-class errors for ML Kit script recognizers
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Keep ML Kit classes used via reflection / async initialization
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
