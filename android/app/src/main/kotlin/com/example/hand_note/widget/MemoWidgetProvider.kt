package com.example.hand_note.widget


import android.appwidget.AppWidgetManager
import android.content.Context
import android.appwidget.AppWidgetProvider

/**
 * 🏠 MemoWidgetProvider
 * - Flutter(HomeWidgetService)からの更新を受け取り再描画
 */
class MemoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = MemoWidget.buildRemoteViews(context)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
