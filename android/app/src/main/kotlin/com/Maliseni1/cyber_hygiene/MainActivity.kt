package com.Maliseni1.cyber_hygiene

import android.app.KeyguardManager
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.Maliseni1.cyber_hygiene/scan"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSecurityStatus") {
                val securityReport = runSecurityScan()
                result.success(securityReport)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun runSecurityScan(): List<Map<String, Any>> {
        val report = mutableListOf<Map<String, Any>>()

        // 1. Check Root Status
        val isRooted = checkRootMethod1() || checkRootMethod2() || checkRootMethod3()
        report.add(mapOf(
            "title" to "Root Access",
            "isSafe" to !isRooted,
            "recommendation" to if (isRooted) "Device is rooted! High security risk." else "No root access detected."
        ))

        // 2. Check ADB (USB Debugging)
        val adbEnabled = Settings.Global.getInt(contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
        report.add(mapOf(
            "title" to "USB Debugging",
            "isSafe" to !adbEnabled,
            "recommendation" to if (adbEnabled) "Disable USB Debugging in Developer Options." else "USB Debugging is disabled."
        ))

        // 3. Check Screen Lock
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val isSecure = keyguardManager.isDeviceSecure
        report.add(mapOf(
            "title" to "Screen Lock",
            "isSafe" to isSecure,
            "recommendation" to if (isSecure) "Device is protected." else "Set a PIN, Pattern, or Password immediately."
        ))

        // 4. Check Encryption (Standard on most modern Androids)
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val encryptionStatus = dpm.storageEncryptionStatus
        val isEncrypted = encryptionStatus == DevicePolicyManager.ENCRYPTION_STATUS_ACTIVE || 
                          encryptionStatus == DevicePolicyManager.ENCRYPTION_STATUS_ACTIVE_PER_USER
        
        report.add(mapOf(
            "title" to "Disk Encryption",
            "isSafe" to isEncrypted,
            "recommendation" to if (isEncrypted) "Internal storage is encrypted." else "Encryption is not active."
        ))

        return report
    }

    // --- Root Detection Helpers ---
    private fun checkRootMethod1(): Boolean {
        val buildTags = android.os.Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk", "/sbin/su", "/system/bin/su", 
            "/system/xbin/su", "/data/local/xbin/su", "/data/local/bin/su", 
            "/system/sd/xbin/su", "/system/bin/failsafe/su", "/data/local/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootMethod3(): Boolean {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val input = process.inputStream.bufferedReader()
            input.readLine() != null
        } catch (t: Throwable) {
            false
        } finally {
            process?.destroy()
        }
    }
}