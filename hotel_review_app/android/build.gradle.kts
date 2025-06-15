// android/build.gradle (Project Level)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin
        classpath 'com.android.tools.build:gradle:7.3.0' // Sesuaikan versi Gradle Anda jika perlu

        // Google Services plugin (untuk Firebase)
        classpath 'com.google.gms:google-services:4.3.15' // Versi plugin Firebase Google Services
        // Pastikan versi ini kompatibel dengan versi Firebase SDK yang Anda gunakan.
        // Anda bisa cek versi terbaru di https://firebase.google.com/docs/android/setup

        // Kotlin Gradle Plugin
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10" // Sesuaikan versi Kotlin Anda
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Bagian ini dihapus karena tidak standar dan dapat menyebabkan masalah.
// val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// rootProject.layout.buildDirectory.value(newBuildDir)
//
// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }
// subprojects {
//     project.evaluationDependsOn(":app")
// }
//
// tasks.register<Delete>("clean") {
//     delete(rootProject.layout.buildDirectory)
// }
