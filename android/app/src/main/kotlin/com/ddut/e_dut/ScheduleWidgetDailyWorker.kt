package com.ddut.e_dut

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class ScheduleWidgetDailyWorker(
    private val context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    override fun doWork(): Result {

        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, ScheduleWidget::class.java)
        )

        for (id in ids) {
            updateAppWidget(context, manager, id)
        }

        return Result.success()
    }
}
