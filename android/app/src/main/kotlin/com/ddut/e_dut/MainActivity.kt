package com.ddut.e_dut

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ddut.e_dut.storage.SharedStorage

class MainActivity : FlutterActivity() {

    private val CHANNEL = "schedule_widget/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val storage = SharedStorage(this)

                when (call.method) {

                    // SAVE SCHEDULE DATA
                    "saveSchedule" -> {
                        val json = call.argument<String>("json")
                        storage.saveSchedule(json ?: "")
                        refreshWidget()
                        result.success(true)
                    }

                    // GET SCHEDULE DATA
                    "getSchedule" -> {
                        result.success(storage.getSchedule())
                    }

                    // REFRESH WIDGET ONLY
                    "refreshWidget" -> {
                        refreshWidget()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun refreshWidget() {
        val context = this
        val manager = AppWidgetManager.getInstance(context)
        val widgetComponent = ComponentName(context, ScheduleWidget::class.java)
        val widgetIds = manager.getAppWidgetIds(widgetComponent)

        for (id in widgetIds) {
            updateAppWidget(context, manager, id)
        }
    }
}
