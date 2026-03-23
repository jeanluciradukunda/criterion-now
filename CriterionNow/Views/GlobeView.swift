import SwiftUI
import SceneKit

private enum GC {
    static let sphereRadius: Double = 1.8
    static let cameraDistance: Float = 5.2
    static let posterSize: CGFloat = 0.04
    static let maxPostersPerCountry: Int = 6
    static let clusterSpread: Double = 2.5
    static let maxCallouts: Int = 12
    static let calloutCardSize: CGFloat = 48
    static let calloutPadding: CGFloat = 16
    static let lineWidth: CGFloat = 0.7
}

// MARK: - Callout (stable identity by country)

struct GlobeCallout: Identifiable {
    var id: String { country } // stable identity — no flicker
    let country: String
    let count: Int
    let films: [LibraryMovie]
    var anchorScreen: CGPoint
    var cardCenter: CGPoint = .zero
    let isFront: Bool
    var posterURL: URL?
}

// MARK: - Scene Manager

@MainActor
class GlobeSceneManager: ObservableObject {
    let scnView = SCNView()
    private var globeNode: SCNNode?
    private var anchors: [(country: String, count: Int, films: [LibraryMovie], node: SCNNode)] = []
    /// Cached poster images keyed by country — loaded once, never re-fetched
    var posterImageCache: [String: NSImage] = [:]

    func build(groups: [CountryFilmGroup]) {
        let scene = SCNScene()
        scene.background.contents = NSColor.clear

        let amb = SCNNode()
        amb.light = SCNLight()
        amb.light!.type = .ambient
        amb.light!.color = NSColor(white: 0.5, alpha: 1)
        amb.light!.intensity = 500
        scene.rootNode.addChildNode(amb)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light!.type = .directional
        sun.light!.color = NSColor(red: 1, green: 0.97, blue: 0.92, alpha: 1)
        sun.light!.intensity = 700
        sun.position = SCNVector3(3, 4, 5)
        sun.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(sun)

        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera?.fieldOfView = 38
        cam.camera?.zNear = 0.1
        cam.camera?.zFar = 50
        cam.position = SCNVector3(0, 0.3, GC.cameraDistance)
        cam.eulerAngles.x = -0.15
        scene.rootNode.addChildNode(cam)

        let globe = makeGlobe()
        scene.rootNode.addChildNode(globe)
        globeNode = globe

        anchors = []
        for g in groups where g.country != "Unknown" {
            for n in makePosters(g) { globe.addChildNode(n) }
            let p = CountryCoordinates.toSpherePosition(lat: g.lat, lng: g.lng, radius: GC.sphereRadius + 0.01)
            let a = SCNNode()
            a.position = SCNVector3(p.x, p.y, p.z)
            globe.addChildNode(a)
            anchors.append((g.country, g.count, g.films, a))
        }

        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.defaultCameraController.inertiaEnabled = true

        // Pre-load poster images for callout cards (once, cached)
        for g in groups where g.country != "Unknown" {
            if let url = g.films.first?.displayImageURL {
                let country = g.country
                Task.detached(priority: .background) {
                    if let (d, _) = try? await URLSession.shared.data(from: url),
                       let img = NSImage(data: d) {
                        await MainActor.run { self.posterImageCache[country] = img }
                    }
                }
            }
        }
    }

    func projectCallouts(viewSize: CGSize) -> [GlobeCallout] {
        var raw: [GlobeCallout] = []
        let cam = scnView.pointOfView?.worldPosition ?? SCNVector3(0, 0, GC.cameraDistance)

        for (country, count, films, node) in anchors {
            let wp = node.worldPosition
            let pp = scnView.projectPoint(wp)
            let sx = CGFloat(pp.x)
            let sy = viewSize.height - CGFloat(pp.y)

            let toCenterFromCam = SCNVector3(-cam.x, -cam.y, -cam.z)
            let dot = wp.x * toCenterFromCam.x + wp.y * toCenterFromCam.y + wp.z * toCenterFromCam.z
            let isFront = dot > 0.2

            guard sx > -100, sx < viewSize.width + 100, sy > -100, sy < viewSize.height + 100 else { continue }

            raw.append(GlobeCallout(
                country: country, count: count, films: films,
                anchorScreen: CGPoint(x: sx, y: sy),
                isFront: isFront,
                posterURL: films.first?.displayImageURL
            ))
        }

        let visible = Array(raw.filter { $0.isFront }.sorted { $0.count > $1.count }.prefix(GC.maxCallouts))

        let cx = viewSize.width / 2
        let cy = viewSize.height / 2
        let globeScreenR = viewSize.height * 0.34

        var solved: [GlobeCallout] = []
        var usedAngles: [CGFloat] = []

        for var c in visible {
            var dx = c.anchorScreen.x - cx
            var dy = c.anchorScreen.y - cy
            let dist = sqrt(dx * dx + dy * dy)
            if dist < 1 { dx = 1; dy = 0 }

            let cardDist = globeScreenR + GC.calloutPadding + GC.calloutCardSize / 2
            var angle = atan2(dy / dist, dx / dist)

            for existing in usedAngles {
                if abs(angle - existing) < 0.25 { angle += 0.25 }
            }
            usedAngles.append(angle)

            let cardX = cx + cos(angle) * cardDist
            let cardY = cy + sin(angle) * cardDist

            c.cardCenter = CGPoint(
                x: min(max(cardX, GC.calloutCardSize / 2 + 4), viewSize.width - GC.calloutCardSize / 2 - 4),
                y: min(max(cardY, GC.calloutCardSize / 2 + 20), viewSize.height - GC.calloutCardSize / 2 - 4)
            )
            solved.append(c)
        }
        return solved
    }

    // Globe center and radius in screen space (for leader line routing)
    func globeScreenGeometry(viewSize: CGSize) -> (center: CGPoint, radius: CGFloat) {
        let center = scnView.projectPoint(SCNVector3Zero)
        let cx = CGFloat(center.x)
        let cy = viewSize.height - CGFloat(center.y)
        return (CGPoint(x: cx, y: cy), viewSize.height * 0.34)
    }

    private func makeGlobe() -> SCNNode {
        let s = SCNSphere(radius: GC.sphereRadius)
        s.segmentCount = 128
        let m = SCNMaterial()
        if let p = Bundle.main.path(forResource: "earth_dark", ofType: "jpg"), let i = NSImage(contentsOfFile: p) {
            m.diffuse.contents = i
        } else {
            m.diffuse.contents = NSColor(red: 0.88, green: 0.85, blue: 0.80, alpha: 1)
        }
        m.specular.contents = NSColor(white: 0.08, alpha: 1)
        m.shininess = 0.05
        m.lightingModel = .phong
        s.materials = [m]
        let n = SCNNode(geometry: s)
        n.name = "globe"
        n.eulerAngles.x = 0.1
        n.eulerAngles.y = -0.3
        return n
    }

    private func makePosters(_ g: CountryFilmGroup) -> [SCNNode] {
        var nodes: [SCNNode] = []
        let cnt = min(g.films.count, GC.maxPostersPerCountry)
        let R = GC.sphereRadius
        for i in 0..<cnt {
            let film = g.films[i]
            let seed = abs(g.country.hashValue &+ i &* 7919)
            let jLat = g.lat + Double((seed % 50) - 25) / 10.0 * GC.clusterSpread / 5
            let jLng = g.lng + Double(((seed / 50) % 50) - 25) / 10.0 * GC.clusterSpread / 5
            let p = CountryCoordinates.toSpherePosition(lat: jLat, lng: jLng, radius: R + 0.005)
            let sz = GC.posterSize
            let plane = SCNPlane(width: sz * 0.67, height: sz)
            plane.cornerRadius = sz * 0.05
            let mat = SCNMaterial()
            mat.diffuse.contents = NSColor(hue: CGFloat(abs(seed % 360)) / 360, saturation: 0.2, brightness: 0.5, alpha: 1)
            mat.lightingModel = .constant
            mat.isDoubleSided = true
            plane.materials = [mat]
            let nd = SCNNode(geometry: plane)
            nd.position = SCNVector3(p.x, p.y, p.z)
            let billboard = SCNBillboardConstraint()
            billboard.freeAxes = .all
            nd.constraints = [billboard]
            nodes.append(nd)
            if let url = film.displayImageURL {
                let ref = mat
                Task.detached(priority: .background) {
                    if let (d, _) = try? await URLSession.shared.data(from: url),
                       let img = NSImage(data: d) {
                        await MainActor.run { ref.diffuse.contents = img }
                    }
                }
            }
        }
        return nodes
    }
}

// MARK: - NSView wrapper

struct GlobeSceneView: NSViewRepresentable {
    let manager: GlobeSceneManager
    func makeNSView(context: Context) -> SCNView { manager.scnView }
    func updateNSView(_ nsView: SCNView, context: Context) {}
}

// MARK: - Composite Globe View

struct GlobeView: View {
    let countryGroups: [CountryFilmGroup]
    let onCountryTap: (CountryFilmGroup) -> Void

    @StateObject private var manager = GlobeSceneManager()
    @State private var callouts: [GlobeCallout] = []
    @State private var built = false
    @State private var hoveredCountry: String?
    @State private var projectionTimer: Timer?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GlobeSceneView(manager: manager)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Routed leader lines
                Canvas { ctx, size in
                    let globe = manager.globeScreenGeometry(viewSize: size)
                    for c in callouts where c.isFront && c.cardCenter != .zero {
                        drawRoutedLeader(ctx: &ctx, c: c, globeCenter: globe.center, globeRadius: globe.radius)
                    }
                }
                .allowsHitTesting(false)

                // Stable callout cards — use cached images, not AsyncImage
                ForEach(callouts.filter { $0.isFront && $0.cardCenter != .zero }) { c in
                    calloutCard(c)
                        .position(c.cardCenter)
                        .transition(.opacity)
                        .onTapGesture {
                            if let g = countryGroups.first(where: { $0.country == c.country }) {
                                onCountryTap(g)
                            }
                        }
                        .onHover { h in hoveredCountry = h ? c.country : nil }
                }
            }
            .onAppear {
                if !built {
                    manager.build(groups: countryGroups)
                    built = true
                }
                startTimer()
            }
            .onDisappear { projectionTimer?.invalidate() }
        }
    }

    private func startTimer() {
        projectionTimer?.invalidate()
        projectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                let s = manager.scnView.bounds.size
                guard s.width > 0 else { return }
                withAnimation(.linear(duration: 0.08)) {
                    callouts = manager.projectCallouts(viewSize: s)
                }
            }
        }
    }

    // MARK: - Callout Card (stable, cached image)

    private func calloutCard(_ c: GlobeCallout) -> some View {
        let isHov = hoveredCountry == c.country

        return VStack(spacing: 2) {
            if let img = manager.posterImageCache[c.country] {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 28, height: 40)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            } else {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.2))
                    .frame(width: 28, height: 40)
            }
            Text(c.country)
                .font(.system(size: 7, weight: isHov ? .bold : .medium))
                .foregroundStyle(isHov ? AppAccent.current : .white.opacity(0.7))
                .lineLimit(1)
            Text("\(c.count)")
                .font(.system(size: 6, weight: .bold, design: .monospaced))
                .foregroundStyle(isHov ? AppAccent.current : .white.opacity(0.35))
        }
        .scaleEffect(isHov ? 1.1 : 1.0)
        .animation(.easeOut(duration: 0.12), value: isHov)
    }

    // MARK: - Routed Leader Line (bends around globe silhouette)

    private func drawRoutedLeader(ctx: inout GraphicsContext, c: GlobeCallout, globeCenter: CGPoint, globeRadius: CGFloat) {
        let A = c.anchorScreen
        let card = c.cardCenter

        // Direction from globe center to anchor
        var dx = A.x - globeCenter.x
        var dy = A.y - globeCenter.y
        let dist = sqrt(dx * dx + dy * dy)
        if dist < 1 { dx = 1; dy = 0 }
        let nx = dx / dist
        let ny = dy / dist

        // Rim exit point: where the line leaves the globe silhouette
        let rimMargin: CGFloat = 6
        let E = CGPoint(
            x: globeCenter.x + nx * (globeRadius + rimMargin),
            y: globeCenter.y + ny * (globeRadius + rimMargin)
        )

        // Draw: A → E (on/near globe surface to rim)
        // Then E → card via quadratic Bézier that curves outward
        var path = Path()
        path.move(to: A)
        path.addLine(to: E)

        // Control point for the curve: push outward from the midpoint of E→card
        let midX = (E.x + card.x) / 2
        let midY = (E.y + card.y) / 2
        let pushOut: CGFloat = 12
        let controlX = midX + nx * pushOut
        let controlY = midY + ny * pushOut

        path.addQuadCurve(to: card, control: CGPoint(x: controlX, y: controlY))

        let isHov = hoveredCountry == c.country
        ctx.stroke(path, with: .color(isHov ? AppAccent.current.opacity(0.5) : Color(white: 0.4, opacity: 0.2)), lineWidth: GC.lineWidth)

        // Dot at anchor
        let dot = Path(ellipseIn: CGRect(x: A.x - 2, y: A.y - 2, width: 4, height: 4))
        ctx.fill(dot, with: .color(isHov ? AppAccent.current : AppAccent.current.opacity(0.4)))

        // Small dot at rim exit
        let rimDot = Path(ellipseIn: CGRect(x: E.x - 1.5, y: E.y - 1.5, width: 3, height: 3))
        ctx.fill(rimDot, with: .color(Color(white: 0.5, opacity: 0.2)))
    }
}
