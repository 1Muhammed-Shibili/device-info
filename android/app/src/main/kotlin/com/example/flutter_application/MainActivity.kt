package com.example.flutter_application

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device/info"
    private val REQUEST_CODE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deviceId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId) // Return Android ID instead of IMEI
                }
                "getIMEI" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        result.error("UNAVAILABLE", "IMEI access is restricted on Android 10+", null)
                    } else {
                        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

                        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), REQUEST_CODE)
                            result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
                        } else {
                            val imei = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                telephonyManager.imei
                            } else {
                                telephonyManager.deviceId
                            }
                            result.success(imei)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
