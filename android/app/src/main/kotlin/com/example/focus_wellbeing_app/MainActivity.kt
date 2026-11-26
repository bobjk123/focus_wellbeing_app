package com.example.focus_wellbeing_app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val channelName = "com.wellbeing.focus_wellbeing_app/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsagePermission" -> result.success(hasUsageStatsPermission())
                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "getTodayUsageStats" -> {
                        if (!hasUsageStatsPermission()) {
                            result.success(emptyList<Map<String, Any>>())
                        } else {
                            result.success(queryTodayUsageStats())
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun queryTodayUsageStats(): List<Map<String, Any>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startMillis = calendar.timeInMillis
        val endMillis = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startMillis,
            endMillis
        ) ?: return emptyList()

        val pm = applicationContext.packageManager
        val aggregated = mutableMapOf<String, Long>()
        for (item in stats) {
            if (item.totalTimeInForeground > 0) {
                aggregated[item.packageName] =
                    (aggregated[item.packageName] ?: 0L) + item.totalTimeInForeground
            }
        }

        return aggregated.entries
            .mapNotNull { (pkg, totalMs) ->
                val minutes = (totalMs / 60_000L).toInt()
                if (minutes <= 0) return@mapNotNull null
                val appLabel = try {
                    val info = pm.getApplicationInfo(pkg, 0)
                    pm.getApplicationLabel(info).toString()
                } catch (_: PackageManager.NameNotFoundException) {
                    pkg
                }
                mapOf(
                    "packageName" to pkg,
                    "appName" to appLabel,
                    "usageMinutes" to minutes
                )
            }
            .sortedByDescending { it["usageMinutes"] as Int }
    }
}
