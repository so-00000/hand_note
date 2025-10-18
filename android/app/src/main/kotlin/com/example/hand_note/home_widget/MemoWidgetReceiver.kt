package com.example.hand_note.home_widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class MemoWidgetReceiver : BroadcastReceiver() {

    companion object {
        /** 🕒 完了表示の残留時間（ミリ秒） */
        const val COMPLETED_DISPLAY_DURATION = 750L
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "TOGGLE_STATUS" -> handleToggleStatus(context, intent)
            "NEXT_STATUS" -> handleNextStatus(context, intent)
        }
    }

    // ✅ ステータス切替（完了⇄戻す）
    private fun handleToggleStatus(context: Context, intent: Intent) {
        val memoId = intent.getIntExtra("MEMO_ID", -1)
        if (memoId == -1) return

        val prefs = HomeWidgetPlugin.getData(context)
        val memoJsonString = prefs.getString("memo_list", "[]")
        val memos = JSONArray(memoJsonString)

        var changedToCompleted = false

        for (i in 0 until memos.length()) {
            val memo = memos.getJSONObject(i)
            if (memo.optInt("id") == memoId) {
                val current = memo.optInt("statusId", 2)
                if (current != 1) {
                    // ✅ 未完了 → 完了
                    memo.put("prevStatusId", current)
                    memo.put("statusId", 1)
                    changedToCompleted = true
                } else {
                    // ✅ 完了 → 戻す
                    val prev = memo.optInt("prevStatusId", 2)
                    memo.put("statusId", prev)
                }
                break
            }
        }

        prefs.edit().putString("memo_list", memos.toString()).apply()

        // ✅ 完了になったメモIDを一時保存
        if (changedToCompleted) {
            val tmpPrefs = context.getSharedPreferences("memo_widget_tmp", Context.MODE_PRIVATE)
            tmpPrefs.edit().putLong("recently_completed_$memoId", System.currentTimeMillis()).apply()
        }

        // ✅ 即時更新（完了見た目を反映）
        MemoWidgetProvider.updateAllWidgets(context)

        // ✅ 指定時間後に再描画（非表示へ）
        if (changedToCompleted) {
            Handler(Looper.getMainLooper()).postDelayed({
                MemoWidgetProvider.updateAllWidgets(context)
            }, COMPLETED_DISPLAY_DURATION)
        }
    }

    // ✅ ステータス順送り処理（完了→0.5秒後に消す対応あり）
    private fun handleNextStatus(context: Context, intent: Intent) {
        val memoId = intent.getIntExtra("MEMO_ID", -1)
        if (memoId == -1) return

        val prefs = HomeWidgetPlugin.getData(context)
        val memoJsonString = prefs.getString("memo_list", "[]")
        val statusJsonString = prefs.getString("status_list", "[]")

        val memos = JSONArray(memoJsonString)
        val statuses = JSONArray(statusJsonString)

        val allStatusIds = mutableListOf<Int>()
        for (i in 0 until statuses.length()) {
            val id = statuses.getJSONObject(i).optInt("statusId", -1)
            if (id != -1) allStatusIds.add(id)
        }

        var changedToCompleted = false

        for (i in 0 until memos.length()) {
            val memo = memos.getJSONObject(i)
            if (memo.optInt("id") == memoId) {
                val current = memo.optInt("statusId", 2)
                val currentIndex = allStatusIds.indexOf(current)
                val nextIndex = (currentIndex + 1) % allStatusIds.size
                val nextStatusId = allStatusIds[nextIndex]

                if (nextStatusId == 1) {
                    changedToCompleted = true
                    val tmpPrefs = context.getSharedPreferences("memo_widget_tmp", Context.MODE_PRIVATE)
                    tmpPrefs.edit().putLong("recently_completed_$memoId", System.currentTimeMillis()).apply()
                }

                memo.put("statusId", nextStatusId)
                break
            }
        }

        prefs.edit().putString("memo_list", memos.toString()).apply()

        // ✅ 即時更新
        MemoWidgetProvider.updateAllWidgets(context)

        // ✅ 完了に変わった場合のみ遅延再描画
        if (changedToCompleted) {
            Handler(Looper.getMainLooper()).postDelayed({
                MemoWidgetProvider.updateAllWidgets(context)
            }, COMPLETED_DISPLAY_DURATION)
        }
    }
}
