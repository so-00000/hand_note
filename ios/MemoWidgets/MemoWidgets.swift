//
//  MemoWidgets.swift
//  MemoWidgets
//
//  Created by USER on 2026/01/01.
//

import WidgetKit
import SwiftUI

private let appGroupId = "group.com.ttperry.handnote"
private let memoListKey = "memo_list"
private let statusListKey = "status_list"

struct MemoWidgetMemo: Identifiable {
    let id: Int
    let content: String
    let statusId: Int
}

struct MemoWidgetStatus {
    let id: Int
    let name: String
    let colorHex: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let sampleStatuses = [
            MemoWidgetStatus(id: 2, name: "未完了", colorHex: "#4CAF50"),
            MemoWidgetStatus(id: 3, name: "進行中", colorHex: "#FF9800")
        ]
        let sampleMemos = [
            MemoWidgetMemo(id: 1, content: "買い物リストを更新", statusId: 2),
            MemoWidgetMemo(id: 2, content: "企画書レビュー", statusId: 3)
        ]
        return SimpleEntry(date: Date(), memos: sampleMemos, statuses: sampleStatuses)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadEntry(date: Date())
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: entry.date) ?? entry.date
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

    private func loadEntry(date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let memoJson = defaults?.string(forKey: memoListKey) ?? "[]"
        let statusJson = defaults?.string(forKey: statusListKey) ?? "[]"

        let memos = decodeMemos(from: memoJson)
        let statuses = decodeStatuses(from: statusJson)
        return SimpleEntry(date: date, memos: memos, statuses: statuses)
    }

    private func decodeMemos(from json: String) -> [MemoWidgetMemo] {
        guard let data = json.data(using: .utf8) else { return [] }
        guard let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return raw.compactMap { item in
            let memoId = item["memoId"] as? Int ?? item["id"] as? Int ?? -1
            let content = item["content"] as? String ?? ""
            let statusId = item["statusId"] as? Int ?? -1
            guard memoId >= 0 else { return nil }
            return MemoWidgetMemo(id: memoId, content: content, statusId: statusId)
        }
    }

    private func decodeStatuses(from json: String) -> [MemoWidgetStatus] {
        guard let data = json.data(using: .utf8) else { return [] }
        guard let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return raw.compactMap { item in
            guard let statusId = item["statusId"] as? Int else { return nil }
            let statusNm = item["statusNm"] as? String ?? "未完了"
            let statusColor = item["statusColor"] as? String ?? "#4CAF50"
            return MemoWidgetStatus(id: statusId, name: statusNm, colorHex: statusColor)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let memos: [MemoWidgetMemo]
    let statuses: [MemoWidgetStatus]
}

struct MemoWidgetsEntryView: View {
    var entry: Provider.Entry

    private var statusMap: [Int: MemoWidgetStatus] {
        Dictionary(uniqueKeysWithValues: entry.statuses.map { ($0.id, $0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entry.memos) { memo in
                MemoCardView(
                    memo: memo,
                    status: statusMap[memo.statusId]
                )
            }

            if entry.memos.isEmpty {
                Text("メモがありません")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}

struct MemoCardView: View {
    let memo: MemoWidgetMemo
    let status: MemoWidgetStatus?

    var body: some View {
        let statusColor = Color(hex: status?.colorHex ?? "#4CAF50")
        let statusName = status?.name ?? "未完了"

        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            Text(memo.content)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(statusName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct MemoWidgets: Widget {
    let kind: String = "MemoWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MemoWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MemoWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("メモ一覧")
        .description("メモの件数に応じてカード表示します。")
    }
}

#Preview(as: .systemSmall) {
    MemoWidgets()
} timeline: {
    SimpleEntry(
        date: .now,
        memos: [
            MemoWidgetMemo(id: 1, content: "今日のタスク整理", statusId: 2),
            MemoWidgetMemo(id: 2, content: "会議メモ整理", statusId: 3)
        ],
        statuses: [
            MemoWidgetStatus(id: 2, name: "未完了", colorHex: "#4CAF50"),
            MemoWidgetStatus(id: 3, name: "進行中", colorHex: "#FF9800")
        ]
    )
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 3:
            (r, g, b) = ((int >> 8) & 0xF, (int >> 4) & 0xF, int & 0xF)
            (r, g, b) = (r * 17, g * 17, b * 17)
        default:
            (r, g, b) = (76, 175, 80)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
