import SpriteKit

final class PathNode: SKNode {
    init(waypoints: [CGPoint], roadWidth: CGFloat = 40) {
        super.init()

        guard waypoints.count >= 2 else { return }

        let path = CGMutablePath()
        path.move(to: waypoints[0])
        for pt in waypoints.dropFirst() {
            path.addLine(to: pt)
        }

        let road = SKShapeNode(path: path)
        road.strokeColor = .tdPath
        road.lineWidth   = roadWidth
        road.lineCap     = .round
        road.lineJoin    = .round
        road.zPosition   = -1
        addChild(road)

        // Dashed center line
        let dashes = CGMutablePath()
        dashes.move(to: waypoints[0])
        for pt in waypoints.dropFirst() {
            dashes.addLine(to: pt)
        }
        let dashLine = SKShapeNode(path: dashes)
        dashLine.strokeColor = SKColor(white: 1, alpha: 0.07)
        dashLine.lineWidth   = 2
        addChild(dashLine)
    }

    required init?(coder: NSCoder) { fatalError() }
}
