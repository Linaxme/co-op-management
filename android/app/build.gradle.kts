import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties (android/key.properties)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { 
        keystoreProperties.load(it) 
    }
    // Verify all required properties exist
    if (!keystoreProperties.containsKey("keyAlias")) {
        throw GradleException("keyAlias property not found in key.properties. Available keys: ${keystoreProperties.keys.joinToString()}")
    }
} else {
    throw GradleException("key.properties file not found at: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.linax.ssf"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.linax.coop_ssf"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Release signing config
    signingConfigs {
        create("release") {
            keyPassword = (keystoreProperties["keyPassword"] ?: error("keyPassword missing in key.properties")) as String
            val storeFileProperty = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFileProperty != null) {
                val keystoreFile = file(storeFileProperty)
                if (!keystoreFile.exists()) {
                    // Try relative to app directory
                    val appKeystoreFile = file("${projectDir}/${storeFileProperty}")
                    if (appKeystoreFile.exists()) {
                        appKeystoreFile
                    } else {
                        error("Keystore file not found: ${keystoreFile.absolutePath} or ${appKeystoreFile.absolutePath}")
                    }
                } else {
                    keystoreFile
                }
            } else {
                error("storeFile missing in key.properties")
            }
            storePassword = (keystoreProperties["storePassword"] ?: error("storePassword missing in key.properties")) as String
            keyAlias = (keystoreProperties["keyAlias"] ?: error("keyAlias missing in key.properties")) as String
        }
    }


    buildTypes {
        release {
            // ✅ Use your release keystore (NOT debug)
            signingConfig = signingConfigs.getByName("release")

            // Keep these false for now (simplest release build)
            isMinifyEnabled = false
            isShrinkResources = false
        }

        debug {
            // default debug config
        }
    }
}

flutter {
    source = "../.."
}
