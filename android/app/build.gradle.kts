plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.Maliseni1.cyber_hygiene"
    
    // FIX 1: Explicitly set to 34 to resolve 'lStar' not found errors
    compileSdk = 34
    
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // FIX 2: Use Java 17 (Required for Android Gradle Plugin 8.0+)
        // "VERSION_34" does not exist in Java.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // FIX 3: Match the Java version above
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID matches your namespace
        applicationId = "com.Maliseni1.cyber_hygiene"
        
        // UPDATED: Set to 26 (Android 8.0)
        minSdk = 26 
        
        // It is safe to keep targetSdk as flutter.targetSdkVersion, 
        // but if you still get errors, change this to 34 as well.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}