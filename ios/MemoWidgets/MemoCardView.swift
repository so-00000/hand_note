import SwiftUI

struct MemoCardView: View {
    let memo: MemoWidgetMemo
    let status: MemoWidgetStatus?

    var body: some View {
        let statusColor = Color(hex: status?.colorHex ?? "#4CAF50")
        let statusName = status?.name ?? "未完了"

        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(memo.content)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(statusName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(statusColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        var r, g, b: UInt64
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
