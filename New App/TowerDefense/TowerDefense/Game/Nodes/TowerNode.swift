import SpriteKit

final class TowerNode: SKNode {
    let towerType: TowerType
    var effectiveRange: CGFloat
    var effectiveDamage: CGFloat
    var effectiveFireRate: TimeInterval

    private let baseSprite: SKShapeNode
    private let rangeRing: SKShapeNode

    var lastFireTime: TimeInterval = 0

    init(type: TowerType, gameState: GameState) {
        self.towerType        = type
        self.effectiveRange   = type.range      * CGFloat(gameState.globalRangeMultiplier)
        self.effectiveDamage  = type.baseDamage * CGFloat(gameState.globalDamageMultiplier)
        self.effectiveFireRate = TowerNode.computeFireRate(type: type, gameState: gameState)

        // Base circle
        let base = SKShapeNode(circleOfRadius: 18)
        base.fillColor   = type.color
        base.strokeColor = SKColor(white: 1, alpha: 0.8)
        base.lineWidth   = 1.5
        self.baseSprite  = base

        // Barrel rect parented to base so it rotates with it
        let barrel = SKShapeNode(rectOf: CGSize(width: 6, height: 20), cornerRadius: 2)
        barrel.fillColor   = SKColor(white: 0.85, alpha: 1)
        barrel.strokeColor = .clear
        barrel.position    = CGPoint(x: 0, y: 12)
        base.addChild(barrel)

        // Range ring
        let ring = SKShapeNode(circleOfRadius: effectiveRange)
        ring.strokeColor = type.color.withAlphaComponent(0.35)
        ring.lineWidth   = 1
        ring.fillColor   = type.color.withAlphaComponent(0.05)
        ring.isHidden    = true
        self.rangeRing   = ring

        super.init()
        addChild(base)
        addChild(ring)
    }

    required init?(coder: NSCoder) { fatalError() }

    func showRangeRing(_ show: Bool) { rangeRing.isHidden = !show }

    func canFire(at currentTime: TimeInterval) -> Bool {
        currentTime - lastFireTime >= effectiveFireRate
    }

    func aimAt(target: EnemyNode) {
        let angle = position.angle(to: target.position) - (.pi / 2)
        baseSprite.run(.rotate(toAngle: angle, duration: 0.05, shortestUnitArc: true))
    }

    func didFire(at time: TimeInterval) { lastFireTime = time }

    func refreshStats(from gameState: GameState) {
        effectiveRange    = towerType.range      * CGFloat(gameState.globalRangeMultiplier)
        effectiveDamage   = towerType.baseDamage * CGFloat(gameState.globalDamageMultiplier)
        effectiveFireRate = TowerNode.computeFireRate(type: towerType, gameState: gameState)
        rangeRing.path    = CGPath(ellipseIn: CGRect(
            x: -effectiveRange, y: -effectiveRange,
            width: effectiveRange * 2, height: effectiveRange * 2
        ), transform: nil)
    }

    // MARK: - Fire rate helper

    private static func computeFireRate(type: TowerType, gameState: GameState) -> TimeInterval {
        var rate = type.fireRate / gameState.globalFireRateMultiplier
        if type == .tesla  && gameState.hasUpgrade("r5") { rate /= 2.0 }
        if type == .sniper && gameState.hasUpgrade("r6") { rate /= 1.5 }
        return rate
    }
}
