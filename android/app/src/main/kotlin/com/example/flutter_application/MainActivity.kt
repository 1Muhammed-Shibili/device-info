package com.example.flutter_application

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device/info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deviceId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId)
                }
                "getTotalStorage" -> {
                    result.success(getTotalStorage())
                }
                "getAvailableStorage" -> {
                    result.success(getAvailableStorage())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getTotalStorage(): String {
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            stat.totalBytes
        } else {
            (stat.blockSize.toLong() * stat.blockCount.toLong())
        }
        return "%.2f GB".format(totalBytes / (1024.0 * 1024.0 * 1024.0))
    }

    private fun getAvailableStorage(): String {
        val stat = StatFs(Environment.getDataDirectory().path)
        val availableBytes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            stat.availableBytes
        } else {
            (stat.blockSize.toLong() * stat.availableBlocks.toLong())
        }
        return "%.2f GB".format(availableBytes / (1024.0 * 1024.0 * 1024.0))
    }
}
