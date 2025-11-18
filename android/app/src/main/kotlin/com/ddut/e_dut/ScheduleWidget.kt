package com.ddut.e_dut

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.work.*
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.TimeUnit

/**
 * Implementation of App Widget functionality.
 */
class ScheduleWidget : AppWidgetProvider() {
    companion object {
        private const val ACTION_TIME_TICK = Intent.ACTION_TIME_TICK
        private const val ACTION_DATE_CHANGED = Intent.ACTION_DATE_CHANGED
        private const val ACTION_TIME_CHANGED = Intent.ACTION_TIME_CHANGED
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // Khi thời gian thay đổi → refresh widget
        if (intent.action == ACTION_TIME_TICK ||
            intent.action == ACTION_DATE_CHANGED ||
            intent.action == ACTION_TIME_CHANGED
        ) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, ScheduleWidget::class.java)
            )
            for (id in ids) {
                updateAppWidget(context, manager, id)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
        scheduleDailyUpdate(context)
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
        WorkManager.getInstance(context).cancelAllWorkByTag("schedule_widget_daily")
    }
}

@SuppressLint("RemoteViewLayout")
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    android.util.Log.d("ScheduleWidget", "Updating")

    val views = RemoteViews(context.packageName, R.layout.schedule_widget)

    val calendar = Calendar.getInstance()
    val weekday = SimpleDateFormat("EEEE", Locale("vi")).format(calendar.time)
    val month = calendar.get(Calendar.MONTH) + 1
    val day = calendar.get(Calendar.DAY_OF_MONTH)

    views.setTextViewText(R.id.tvWeekday, weekday.replaceFirstChar { it.uppercase() })
    views.setTextViewText(R.id.tvMonth, "Tháng $month")
    views.setTextViewText(R.id.tvDay, "$day")

    val serviceIntent = Intent(context, ScheduleWidgetService::class.java)
    views.setRemoteAdapter(R.id.lvSchedule, serviceIntent)
    views.setEmptyView(R.id.lvSchedule, android.R.id.empty)

    appWidgetManager.updateAppWidget(appWidgetId, views)

    // Notify to refresh ListView data in widget
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.lvSchedule)
}

private fun scheduleDailyUpdate(context: Context) {
    val workRequest = PeriodicWorkRequestBuilder<ScheduleWidgetDailyWorker>(
        24, TimeUnit.HOURS
    )
        .addTag("schedule_widget_daily")
        .build()

    WorkManager.getInstance(context).enqueueUniquePeriodicWork(
        "schedule_widget_daily",
        ExistingPeriodicWorkPolicy.UPDATE,
        workRequest
    )
}