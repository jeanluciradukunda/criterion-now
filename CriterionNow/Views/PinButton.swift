import SwiftUI

struct PinButton: View {
    @Binding var isPinned: Bool
    @State private var isHovering = false

    var body: some View {
        Button {
            isPinned.toggle()
        } label: {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isPinned ? .orange : (isHovering ? .primary : .secondary))
                .rotationEffect(.degrees(isPinned ? 0 : 45))
                .animation(.easeInOut(duration: 0.2), value: isPinned)
        }
        .buttonStyle(.plain)
        .help(isPinned ? "Unpin popover" : "Pin popover open")
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
