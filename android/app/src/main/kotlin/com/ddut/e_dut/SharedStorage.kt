package com.ddut.e_dut.storage

import android.content.Context
import android.content.SharedPreferences

class SharedStorage(private val context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("widget_shared_prefs", Context.MODE_PRIVATE)

    fun saveSchedule(data: String) {
        prefs.edit().putString("schedule_data", data).apply()
    }

    fun getSchedule(): String? {
        return prefs.getString("schedule_data", null)
    }
}
