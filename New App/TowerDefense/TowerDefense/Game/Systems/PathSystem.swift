import SpriteKit

enum PathSystem {
    // Waypoints in scene coordinates (portrait 390×844 points, origin bottom-left)
    // Path flows left→right→down→left→down→right→exit at bottom
    static let waypoints: [CGPoint] = [
        CGPoint(x: 0,   y: 700),   // entry left edge
        CGPoint(x: 290, y: 700),   // right turn
        CGPoint(x: 290, y: 580),   // down
        CGPoint(x: 100, y: 580),   // left
        CGPoint(x: 100, y: 460),   // down
        CGPoint(x: 290, y: 460),   // right
        CGPoint(x: 290, y: 340),   // down
        CGPoint(x: 100, y: 340),   // left
        CGPoint(x: 100, y: 220),   // down
        CGPoint(x: 290, y: 220),   // right
        CGPoint(x: 290, y: 100),   // down
        CGPoint(x: 390, y: 100),   // exit right edge
    ]

    /// Grid cells (col, row) that the path occupies — pre-computed from waypoints
    static var pathCells: Set<GridCoord> = {
        var cells = Set<GridCoord>()
        let cellSize: CGFloat = 48
        for i in 0..<(waypoints.count - 1) {
            let a = waypoints[i]
            let b = waypoints[i + 1]
            // Walk along segment in cell-size increments
            let steps = Int(a.distance(to: b) / cellSize) + 1
            for s in 0...steps {
                let t = steps == 0 ? 0.0 : CGFloat(s) / CGFloat(steps)
                let pt = CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
                let col = Int(pt.x / cellSize)
                let row = Int(pt.y / cellSize)
                cells.insert(GridCoord(col: col, row: row))
            }
        }
        return cells
    }()

    /// Build an SKAction sequence that moves a node along the waypoints at the given speed.
    static func moveActions(speed: CGFloat) -> [SKAction] {
        var actions: [SKAction] = []
        for i in 0..<(waypoints.count - 1) {
            let dist = waypoints[i].distance(to: waypoints[i + 1])
            let duration = TimeInterval(dist / speed)
            actions.append(.move(to: waypoints[i + 1], duration: duration))
        }
        return actions
    }
}

struct GridCoord: Hashable {
    let col: Int
    let row: Int
}
