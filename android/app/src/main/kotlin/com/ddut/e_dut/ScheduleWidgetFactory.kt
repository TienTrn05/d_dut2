package com.ddut.e_dut

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.ddut.e_dut.R
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class ScheduleWidgetFactory(
    private val context: Context,
    intent: android.content.Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val items = mutableListOf<ScheduleItemModel>()
    private lateinit var prefs: SharedPreferences

    override fun onCreate() {
        prefs = context.getSharedPreferences("widget_shared_prefs", Context.MODE_PRIVATE)

        val json = prefs.getString("schedule_data", null)
        android.util.Log.d("ScheduleWidgetFactory", "onCreate json: $json")
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        items.clear()

        val json = prefs.getString("schedule_data", null)
        android.util.Log.d("ScheduleWidgetFactory", "loadData json: $json")

        // If no data => leave items empty
        if (json.isNullOrEmpty()) {
            android.util.Log.w("ScheduleWidgetFactory", "No schedule_data found → empty list")
            return
        }

        try {
            val type = object : TypeToken<List<ScheduleItemModel>>() {}.type
            val list: List<ScheduleItemModel> = Gson().fromJson(json, type)
            items.addAll(list)
        } catch (e: Exception) {
            android.util.Log.e("ScheduleWidgetFactory", "JSON parse error: ${e.message}")
            // Error? return empty list
        }
    }


    override fun getCount() = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val rv = RemoteViews(context.packageName, R.layout.widget_schedule_item)
        val item = items[position]

        rv.setTextViewText(R.id.tvSubjectName, item.subjectName)
        rv.setTextViewText(R.id.tvRoom, "Phòng ${item.room}")
        rv.setTextViewText(R.id.tvTime, "${item.startStudyTime} - ${item.endStudyTime}")

        return rv
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = position.toLong()
    override fun hasStableIds() = true
    override fun onDestroy() {}
}
