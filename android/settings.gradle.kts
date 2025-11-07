pluginManagement {
    val flutterSdkPath: String by lazy {
        val props = java.util.Properties()
        file("local.properties").inputStream().use { props.load(it) }
        val p = props.getProperty("flutter.sdk")
        check(p != null) { "flutter.sdk not set in local.properties" }
        p
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "2.2.0" apply false}
include(":app")