// Top-level build file where you can add configuration options common to all sub-projects/modules.

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// --- FIX START: FORCE VERSIONS & COMPATIBILITY ---
subprojects {
    // 1. LOCK DEPENDENCIES (Stops them from demanding SDK 36)
    project.configurations.all {
        resolutionStrategy {
            // Force these to versions compatible with SDK 34 (Android 14)
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.browser:browser:1.8.0")
        }
    }

    // 2. FORCE PLUGIN CONFIGURATION
    afterEvaluate {
        val pluginProject = this
        // Check if the project has the Android plugin applied
        if (pluginProject.extensions.findByName("android") != null) {
            val androidExtension = pluginProject.extensions.findByName("android")
            if (androidExtension != null) {
                try {
                    // Force Compile SDK to 34 (Fixes 'lStar' error)
                    val setCompileSdk = androidExtension.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    setCompileSdk.invoke(androidExtension, 34)

                    // Force Namespace (Fixes 'Namespace not specified' error)
                    val getNamespace = androidExtension.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(androidExtension)

                    if (currentNamespace == null) {
                        val setNamespace = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                        // Use the group name as the namespace
                        val groupName = pluginProject.group.toString()
                        setNamespace.invoke(androidExtension, groupName)
                    }
                } catch (e: Exception) {
                    println("Warning: Could not patch plugin ${pluginProject.name}: $e")
                }
            }
        }
    }
}
// --- FIX END ---

// --- CRITICAL: This must be the LAST subprojects block ---
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}