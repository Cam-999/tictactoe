import SpriteKit

final class ProjectileNode: SKNode {
    let towerType: TowerType
    private weak var target: EnemyNode?
    var trackingSpeed: CGFloat = 250
    var onReachTarget: ((CGPoint) -> Void)?

    private let sprite: SKShapeNode

    init(towerType: TowerType, startPosition: CGPoint, target: EnemyNode) {
        self.towerType = towerType
        self.target    = target

        let size: CGFloat = towerType == .missile ? 8 : 5
        let shape = SKShapeNode(circleOfRadius: size)
        shape.fillColor   = towerType.color
        shape.strokeColor = .clear
        self.sprite = shape

        super.init()
        position = startPosition
        addChild(shape)

        physicsBody = SKPhysicsBody(circleOfRadius: size)
        physicsBody?.categoryBitMask    = PhysicsCategories.projectile
        physicsBody?.contactTestBitMask = PhysicsCategories.enemy
        physicsBody?.collisionBitMask   = PhysicsCategories.none
        physicsBody?.isDynamic          = true
        physicsBody?.affectedByGravity  = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(deltaTime: TimeInterval) {
        guard let target, !target.isDead, target.parent != nil else {
            onReachTarget?(position)
            return
        }
        let dest = target.position
        let diff = dest - position
        let dist = diff.length
        let step = trackingSpeed * CGFloat(deltaTime)

        if dist <= step {
            onReachTarget?(dest)
        } else {
            let dir = diff.normalized()
            position = position + dir * step

            // Rotate sprite toward movement direction
            let angle = diff.angle(to: .zero) + .pi
            sprite.zRotation = angle
        }
    }
}
