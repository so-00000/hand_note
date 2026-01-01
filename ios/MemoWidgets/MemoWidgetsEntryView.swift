import SwiftUI

struct MemoWidgetsEntryView: View {
    var entry: Provider.Entry

    private var statusMap: [Int: MemoWidgetStatus] {
        Dictionary(uniqueKeysWithValues: entry.statuses.map { ($0.id, $0) })
    }

    var body: some View {
        let displayedMemos = Array(entry.memos.prefix(maxDisplayCount))

        VStack(alignment: .leading, spacing: 6) {
            ForEach(displayedMemos) { memo in
                MemoCardView(
                    memo: memo,
                    status: statusMap[memo.statusId]
                )
            }

            if displayedMemos.isEmpty {
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
