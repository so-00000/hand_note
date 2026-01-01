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

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        makeEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = makeEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = makeEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

private func makeEntry(date: Date) -> SimpleEntry {
    let data = loadLatestMemo()
    return SimpleEntry(
        date: date,
        title: data.title,
        content: data.content
    )
}

private func loadLatestMemo() -> (title: String, content: String) {
    guard let defaults = UserDefaults(suiteName: appGroupId),
          let memoRaw = defaults.string(forKey: memoListKey),
          let memoList = decodeJsonArray(memoRaw),
          let first = memoList.first,
          let content = first["content"] as? String,
          !content.isEmpty else {
        return (title: "メモ", content: "メモがありません")
    }

    let statusName = resolveStatusName(
        defaults: defaults,
        statusId: intValue(first["statusId"])
    )

    return (title: statusName ?? "メモ", content: content)
}

private func resolveStatusName(defaults: UserDefaults, statusId: Int?) -> String? {
    guard let statusId = statusId,
          let statusRaw = defaults.string(forKey: statusListKey),
          let statusList = decodeJsonArray(statusRaw) else {
        return nil
    }

    for status in statusList {
        if intValue(status["statusId"]) == statusId {
            return status["statusNm"] as? String
        }
    }

    return nil
}

private func decodeJsonArray(_ raw: String) -> [[String: Any]]? {
    guard let data = raw.data(using: .utf8) else {
        return nil
    }

    return (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
}

private func intValue(_ value: Any?) -> Int? {
    if let intValue = value as? Int {
        return intValue
    }
    if let doubleValue = value as? Double {
        return Int(doubleValue)
    }
    if let stringValue = value as? String {
        return Int(stringValue)
    }
    return nil
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
}

struct MemoWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.headline)
                .lineLimit(1)
            Text(entry.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    MemoWidgets()
} timeline: {
    SimpleEntry(
        date: .now,
        title: "未着手",
        content: "牛乳、卵、パンを買う"
    )
    SimpleEntry(
        date: .now,
        title: "進行中",
        content: "SwiftUIのWidgetKitの章を読む"
    )
}
