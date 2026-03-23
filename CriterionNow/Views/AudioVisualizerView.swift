import SwiftUI

// MARK: - Frequency Trails Visualizer (ridgeline / Joy Division style)

struct AudioVisualizerView: View {
    let barCount: Int
    let color: Color
    let isPlaying: Bool
    var audioLevels: [Float] = []

    private let trailCount = 6
    @State private var trails: [[CGFloat]] = []
    @State private var timer: Timer?

    init(barCount: Int = 32, color: Color = .white, isPlaying: Bool = true, audioLevels: [Float] = []) {
        self.barCount = barCount
        self.color = color
        self.isPlaying = isPlaying
        self.audioLevels = audioLevels
    }

    private var hasRealAudio: Bool {
        !audioLevels.isEmpty && audioLevels.contains(where: { $0 > 0.01 })
    }

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let rowHeight = h / CGFloat(trailCount)

            for row in 0..<trails.count {
                let levels = trails[row]
                guard levels.count >= 2 else { continue }

                let baseY = CGFloat(row) * rowHeight + rowHeight * 0.85
                // Older trails are more faded
                let age = CGFloat(row) / CGFloat(trailCount)
                let opacity = 0.15 + (1.0 - age) * 0.85

                let path = ridgePath(levels: levels, baseY: baseY, peakHeight: rowHeight * 0.9, width: w)

                // Fill with gradient from bottom to peak
                let fillGradient = Gradient(stops: [
                    .init(color: color.opacity(0.02 * opacity), location: 0),
                    .init(color: color.opacity(0.15 * opacity), location: 0.6),
                    .init(color: color.opacity(0.3 * opacity), location: 1.0),
                ])
                context.fill(
                    path,
                    with: .linearGradient(
                        fillGradient,
                        startPoint: CGPoint(x: w / 2, y: baseY),
                        endPoint: CGPoint(x: w / 2, y: baseY - rowHeight * 0.9)
                    )
                )

                // Stroke the ridge line
                let strokePath = ridgeStrokePath(levels: levels, baseY: baseY, peakHeight: rowHeight * 0.9, width: w)
                context.stroke(
                    strokePath,
                    with: .color(color.opacity(opacity)),
                    lineWidth: row == 0 ? 1.5 : 0.8
                )
            }
        }
        .onAppear {
            let flat = (0..<barCount).map { _ in CGFloat(0.03) }
            trails = (0..<trailCount).map { _ in flat }
            if isPlaying { startAnimation() }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: isPlaying) { _, playing in
            if playing {
                startAnimation()
            } else {
                timer?.invalidate()
                timer = nil
                let flat = (0..<barCount).map { _ in CGFloat(0.03) }
                withAnimation(.easeOut(duration: 0.8)) {
                    trails = (0..<trailCount).map { _ in flat }
                }
            }
        }
        .onChange(of: audioLevels) { _, newLevels in
            guard hasRealAudio else { return }
            // Push new real audio data as the front trail, shift older ones back
            let resampled = resampleLevels(newLevels)
            pushTrail(resampled)
        }
    }

    /// Generate a smooth Catmull-Rom ridge path (filled area)
    private func ridgePath(levels: [CGFloat], baseY: CGFloat, peakHeight: CGFloat, width: CGFloat) -> Path {
        let points = ridgePoints(levels: levels, baseY: baseY, peakHeight: peakHeight, width: width)
        var path = Path()
        path.move(to: CGPoint(x: 0, y: baseY))
        addCatmullRom(to: &path, points: points)
        path.addLine(to: CGPoint(x: width, y: baseY))
        path.closeSubpath()
        return path
    }

    /// Generate just the ridge line (no fill)
    private func ridgeStrokePath(levels: [CGFloat], baseY: CGFloat, peakHeight: CGFloat, width: CGFloat) -> Path {
        let points = ridgePoints(levels: levels, baseY: baseY, peakHeight: peakHeight, width: width)
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        addCatmullRom(to: &path, points: points)
        return path
    }

    private func ridgePoints(levels: [CGFloat], baseY: CGFloat, peakHeight: CGFloat, width: CGFloat) -> [CGPoint] {
        let count = levels.count
        let step = width / CGFloat(count - 1)
        return (0..<count).map { i in
            let x = CGFloat(i) * step
            let y = baseY - levels[i] * peakHeight
            return CGPoint(x: x, y: y)
        }
    }

    /// Catmull-Rom spline through points
    private func addCatmullRom(to path: inout Path, points: [CGPoint]) {
        guard points.count >= 2 else { return }
        let count = points.count

        for i in 0..<count {
            let p0 = points[Swift.max(0, i - 1)]
            let p1 = points[i]
            let p2 = points[Swift.min(count - 1, i + 1)]
            let p3 = points[Swift.min(count - 1, i + 2)]

            if i == 0 {
                path.addLine(to: p1)
            }

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6.0,
                y: p1.y + (p2.y - p0.y) / 6.0
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6.0,
                y: p2.y - (p3.y - p1.y) / 6.0
            )
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }
    }

    private func pushTrail(_ newLevel: [CGFloat]) {
        var updated = trails
        // Shift all trails back by one
        for i in stride(from: updated.count - 1, through: 1, by: -1) {
            updated[i] = updated[i - 1]
        }
        if !updated.isEmpty {
            updated[0] = newLevel
        }
        trails = updated
    }

    private func resampleLevels(_ raw: [Float]) -> [CGFloat] {
        guard !raw.isEmpty else {
            return (0..<barCount).map { _ in CGFloat(0.03) }
        }
        return (0..<barCount).map { i in
            let srcIndex = Float(i) / Float(barCount) * Float(raw.count)
            let lo = Int(srcIndex)
            let hi = Swift.min(lo + 1, raw.count - 1)
            let frac = srcIndex - Float(lo)
            let val = raw[lo] * (1 - frac) + raw[hi] * frac
            return Swift.max(0.03, CGFloat(pow(val, 0.65)))
        }
    }

    private func startAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if hasRealAudio { return } // Real data drives the trails via onChange
            let time = Date().timeIntervalSince1970
            let newLevel = (0..<barCount).map { i -> CGFloat in
                let pos = Double(i) / Double(barCount)
                let w1 = sin(pos * .pi * 3.2 + time * 2.6)
                let w2 = sin(pos * .pi * 1.4 + time * 1.7) * 0.55
                let w3 = cos(pos * .pi * 5.5 + time * 3.8) * 0.2
                let w4 = sin(pos * .pi * 0.7 + time * 4.5) * 0.15
                let envelope = 0.6 + 0.4 * sin(pos * .pi)
                let combined = (w1 + w2 + w3 + w4 + 1.9) / 3.8
                return Swift.max(0.03, CGFloat(combined * envelope))
            }
            pushTrail(newLevel)
        }
    }
}

// MARK: - Mini Audio Bars (for compact spaces)

struct MiniAudioBars: View {
    let barCount: Int
    let color: Color
    let isPlaying: Bool

    @State private var phases: [Double] = []

    init(barCount: Int = 5, color: Color = .orange, isPlaying: Bool = true) {
        self.barCount = barCount
        self.color = color
        self.isPlaying = isPlaying
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(color)
                    .frame(width: 3)
                    .scaleEffect(
                        y: isPlaying ? (index < phases.count ? phases[index] : 0.3) : 0.15,
                        anchor: .bottom
                    )
            }
        }
        .onAppear {
            phases = (0..<barCount).map { _ in Double.random(in: 0.2...1.0) }
            animate()
        }
        .onChange(of: isPlaying) { _, _ in animate() }
    }

    private func animate() {
        guard isPlaying else { return }
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            phases = (0..<barCount).map { _ in Double.random(in: 0.2...1.0) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            if isPlaying { animate() }
        }
    }
}
