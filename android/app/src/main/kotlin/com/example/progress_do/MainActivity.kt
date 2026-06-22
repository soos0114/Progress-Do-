package com.example.progress_do

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "progress_do/notification_permissions"
        ).setMethodCallHandler { call, result ->
            if (call.method != "canUseFullScreenIntent") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val allowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                manager.canUseFullScreenIntent()
            } else {
                true
            }
            result.success(allowed)
        }
    }
}
