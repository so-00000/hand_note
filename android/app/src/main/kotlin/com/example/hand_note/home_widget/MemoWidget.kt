package com.example.hand_note.home_widget

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews
import com.example.hand_note.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

object MemoWidget {

    @SuppressLint("RemoteViewLayout")
    fun buildRemoteViews(context: Context): RemoteViews {
        val widgetData = HomeWidgetPlugin.getData(context)
        val tmpPrefs = context.getSharedPreferences("memo_widget_tmp", Context.MODE_PRIVATE)

        // Flutter側で保存されたデータを取得
        val memoJsonString = widgetData.getString("memo_list", "[]")
        val statusJsonString = widgetData.getString("status_list", "[]")

        val memoArray = JSONArray(memoJsonString)
        val statusArray = JSONArray(statusJsonString)

        // ステータスマスタをMap化
        val statusMap = mutableMapOf<Int, JSONObject>()
        for (i in 0 until statusArray.length()) {
            val statusObj = statusArray.getJSONObject(i)
            val id = statusObj.optInt("statusId", -1)
            if (id != -1) statusMap[id] = statusObj
        }

        val parent = RemoteViews(context.packageName, R.layout.memo_widget)
        parent.removeAllViews(R.id.memo_list_container)

        val now = System.currentTimeMillis()

        // メモ一覧を描画
        for (i in 0 until memoArray.length()) {
            val memoObj = memoArray.getJSONObject(i)
            val memoId = memoObj.optInt("id", -1)
            val content = memoObj.optString("content", "")
            val updatedAt = memoObj.optString("updatedAt", "")
            val statusId = memoObj.optInt("statusId", -1)

            // ✅ 完了ステータスでも、完了して一定時間内なら表示を残す
            val lastCompletedTime = tmpPrefs.getLong("recently_completed_$memoId", 0)
            val showCompleted = (now - lastCompletedTime) < MemoWidgetReceiver.COMPLETED_DISPLAY_DURATION

            // 完了ステータスかつ残留期間外なら非表示
            if (statusId == 1 && !showCompleted) continue

            // ステータス情報を取得
            val status = statusMap[statusId]
            val statusName = status?.optString("statusNm", "未完了") ?: "未完了"
            val statusColor = status?.optString("statusColor", "#4CAF50") ?: "#4CAF50"

            val parsedColor = try {
                Color.parseColor(statusColor)
            } catch (e: Exception) {
                Color.GRAY
            }

            // メモカードを構築
            val item = RemoteViews(context.packageName, R.layout.item_memo_card)
            val circleBitmap = createColoredCircle(parsedColor, 32)
            item.setImageViewBitmap(R.id.status_circle, circleBitmap)

            item.setTextViewText(R.id.memo_content, content)
            item.setTextViewText(R.id.memo_date, updatedAt)
            item.setTextViewText(R.id.status_nm, statusName)
            item.setTextColor(R.id.status_nm, parsedColor)

            // ✅ ステータス円クリック（完了⇄戻す）
            val intent = Intent(context, MemoWidgetReceiver::class.java).apply {
                action = "TOGGLE_STATUS"
                putExtra("MEMO_ID", memoId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, memoId, intent, PendingIntent.FLAG_IMMUTABLE
            )
            item.setOnClickPendingIntent(R.id.status_circle, pendingIntent)

            // ✅ ステータス名クリック（順送り）
            val nextIntent = Intent(context, MemoWidgetReceiver::class.java).apply {
                action = "NEXT_STATUS"
                putExtra("MEMO_ID", memoId)
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context, memoId + 10000, nextIntent, PendingIntent.FLAG_IMMUTABLE
            )
            item.setOnClickPendingIntent(R.id.status_nm, nextPendingIntent)

            parent.addView(R.id.memo_list_container, item)
        }

        return parent
    }

    // 🎨 円形ビットマップ生成
    private fun createColoredCircle(color: Int, size: Int): Bitmap {
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val paint = Paint().apply {
            this.color = color
            isAntiAlias = true
        }
        val radius = size / 2f
        canvas.drawCircle(radius, radius, radius, paint)
        return bmp
    }
}
