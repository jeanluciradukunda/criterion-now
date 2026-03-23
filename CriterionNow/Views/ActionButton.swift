import SwiftUI

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isHovering ? color : .primary)

                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isHovering ? color : .secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(isHovering ? color.opacity(0.12) : Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(
                                isHovering ? color.opacity(0.3) : Color.white.opacity(0.1),
                                lineWidth: 0.5
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}
