package com.example.hand_note.home_widget

import android.annotation.SuppressLint
import android.content.Context
import android.widget.RemoteViews
import com.example.hand_note.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

object MemoWidget {
    @SuppressLint("RemoteViewLayout")
    fun buildRemoteViews(context: Context): RemoteViews {
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonString = widgetData.getString("mws_list", "[]")
        val jsonArray = JSONArray(jsonString)

        val parent = RemoteViews(context.packageName, R.layout.memo_widget)

        // 🧹 既存コンテンツをクリア
        parent.removeAllViews(R.id.memo_list_container)

        if (jsonArray.length() == 0) {
            val emptyView = RemoteViews(context.packageName, R.layout.item_memo_card)
            emptyView.setTextViewText(R.id.memo_content, "メモがありません")
            emptyView.setTextViewText(R.id.memo_date, "")
            emptyView.setTextViewText(R.id.memo_status, "")
            parent.addView(R.id.memo_list_container, emptyView)
            return parent
        }

        for (i in 0 until jsonArray.length()) {
            val obj = jsonArray.getJSONObject(i)
            val content = obj.optString("content", "")
            val updatedAt = obj.optString("updatedAt", "")
            val statusName = obj.optString("statusName", "未完了")
            val statusColor = obj.optString("statusColor", "#4CAF50")

            val item = RemoteViews(context.packageName, R.layout.item_memo_card)
            item.setTextViewText(R.id.memo_content, content)
            item.setTextViewText(R.id.memo_date, updatedAt)
            item.setTextViewText(R.id.memo_status, statusName)
            item.setTextColor(R.id.memo_status, android.graphics.Color.parseColor(statusColor))

            parent.addView(R.id.memo_list_container, item)
        }

        return parent
    }
}