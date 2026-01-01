//
//  MemoHomeWidget.swift
//  MemoHomeWidget
//
//  Created by USER on 2025/12/31.
//

import WidgetKit
import SwiftUI

private enum WidgetConstants {
    static let appGroupId = "group.com.ttperry.handnote"
    static let memoListKey = "memo_list"
    static let statusListKey = "status_list"
    static let maxCardsForSmall = 1
}

private struct MemoHomeWidgetDataProvider {
    static func loadEntry(isPreview: Bool = false) -> MemoWidgetEntry {
        if isPreview {
            return MemoWidgetEntry(date: Date(), memos: sampleMemos, statuses: sampleStatuses)
        }

        let memos = loadMemos()
        let statuses = loadStatuses()
        return MemoWidgetEntry(date: Date(), memos: memos, statuses: statuses)
    }

    static func loadMemos() -> [MemoItem] {
        guard let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId),
              let jsonString = defaults.string(forKey: WidgetConstants.memoListKey),
              let data = jsonString.data(using: .utf8) else {
            return []
        }

        return (try? JSONDecoder().decode([MemoItem].self, from: data)) ?? []
    }

    static func loadStatuses() -> [StatusItem] {
        guard let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId),
              let jsonString = defaults.string(forKey: WidgetConstants.statusListKey),
              let data = jsonString.data(using: .utf8) else {
            return []
        }

        return (try? JSONDecoder().decode([StatusItem].self, from: data)) ?? []
    }

    private static var sampleMemos: [MemoItem] {
        [
            MemoItem(memoId: 101, content: "買い物メモを作成する", statusId: 2, prevStatusId: 2),
            MemoItem(memoId: 102, content: "週末の旅行プランを整理する", statusId: 3, prevStatusId: 3),
            MemoItem(memoId: 103, content: "読書リストを更新", statusId: 2, prevStatusId: 2)
        ]
    }

    private static var sampleStatuses: [StatusItem] {
        [
            StatusItem(statusId: 1, sortNo: 1, statusNm: "完了", statusColor: "#4CAF50"),
            StatusItem(statusId: 2, sortNo: 2, statusNm: "進行中", statusColor: "#FF9800"),
            StatusItem(statusId: 3, sortNo: 3, statusNm: "未着手", statusColor: "#9C27B0")
        ]
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MemoWidgetEntry {
        MemoHomeWidgetDataProvider.loadEntry(isPreview: true)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MemoWidgetEntry {
        MemoHomeWidgetDataProvider.loadEntry(isPreview: context.isPreview)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MemoWidgetEntry> {
        let entry = MemoHomeWidgetDataProvider.loadEntry()
        return Timeline(entries: [entry], policy: .never)
    }
}

struct MemoWidgetEntry: TimelineEntry {
    let date: Date
    let memos: [MemoItem]
    let statuses: [StatusItem]
}

struct MemoItem: Decodable, Identifiable {
    let memoId: Int
    let content: String
    let statusId: Int
    let prevStatusId: Int

    var id: Int { memoId }
}

struct StatusItem: Decodable {
    let statusId: Int
    let sortNo: Int
    let statusNm: String
    let statusColor: String
}

struct MemoHomeWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        let statusMap = Dictionary(uniqueKeysWithValues: entry.statuses.map { ($0.statusId, $0) })
        let memos = trimmedMemos(entry.memos)

        VStack(alignment: .leading, spacing: 12) {
            headerView

            if memos.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 10) {
                    ForEach(memos) { memo in
                        MemoCardView(
                            memo: memo,
                            status: statusMap[memo.statusId]
                        )
                    }
                }
            }
        }
        .padding(14)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var headerView: some View {
        HStack {
            Text("Hand Note")
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "rectangle.grid.1x2.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("メモがありません")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("アプリで新しいメモを追加してください")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func trimmedMemos(_ memos: [MemoItem]) -> [MemoItem] {
        if family == .systemSmall {
            return Array(memos.prefix(WidgetConstants.maxCardsForSmall))
        }
        return memos
    }
}

struct MemoCardView: View {
    let memo: MemoItem
    let status: StatusItem?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(status?.statusNm ?? "未設定")
                    .font(.caption)
                    .foregroundStyle(statusColor)

                Text(memo.content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var statusColor: Color {
        Color(hex: status?.statusColor) ?? Color.accentColor
    }
}

extension Color {
    init?(hex: String?) {
        guard let hex = hex?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
              !hex.isEmpty else {
            return nil
        }

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (r, g, b) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}

struct MemoHomeWidget: Widget {
    let kind: String = "MemoHomeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MemoHomeWidgetEntryView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    MemoHomeWidget()
} timeline: {
    MemoHomeWidgetDataProvider.loadEntry(isPreview: true)
}

#Preview(as: .systemMedium) {
    MemoHomeWidget()
} timeline: {
    MemoHomeWidgetDataProvider.loadEntry(isPreview: true)
}

#Preview(as: .systemLarge) {
    MemoHomeWidget()
} timeline: {
    MemoHomeWidgetDataProvider.loadEntry(isPreview: true)
}
