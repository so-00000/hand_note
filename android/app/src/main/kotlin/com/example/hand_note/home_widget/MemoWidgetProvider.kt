package com.example.hand_note.home_widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.appwidget.AppWidgetProvider

class MemoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = MemoWidget.buildRemoteViews(context)
            manager.updateAppWidget(id, views)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, MemoWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) {
                val views = MemoWidget.buildRemoteViews(context)
                manager.updateAppWidget(id, views)
            }
        }
    }
}
