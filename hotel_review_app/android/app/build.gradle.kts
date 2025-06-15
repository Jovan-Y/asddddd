// android/app/build.gradle

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Tambahkan plugin Google Services di sini
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.hotel_review_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.hotel_review_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Pastikan Anda memiliki Firebase BOM di sini
    implementation platform('com.google.firebase:firebase-bom:32.3.1') // Gunakan versi BOM terbaru (cek https://firebase.google.com/docs/android/setup)
    implementation 'com.google.firebase:firebase-analytics' // Hanya contoh, tambahkan layanan Firebase lain yang Anda gunakan
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    // Tambahkan dependensi lain yang Anda butuhkan sesuai dengan pubspec.yaml
    // Misalnya:
    // implementation 'com.google.android.gms:play-services-location:21.0.1' // untuk geolocator
    // implementation 'com.google.android.gms:play-services-maps:18.2.0' // untuk google_maps_flutter
}
