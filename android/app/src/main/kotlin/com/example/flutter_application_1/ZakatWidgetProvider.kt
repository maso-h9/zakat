package com.example.flutter_application_1

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ZakatWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.zakat_widget).apply {

                val zakatDue = widgetData.getString("zakat_due", "---") ?: "---"
                setTextViewText(R.id.widget_zakat_due, zakatDue)

                val daysLeft = widgetData.getString("days_left", "---") ?: "---"
                setTextViewText(R.id.widget_days_left, daysLeft)

                val nisabStatus = widgetData.getString("nisab_status", "") ?: ""
                setTextViewText(R.id.widget_nisab_status, nisabStatus)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}