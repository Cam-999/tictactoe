import SpriteKit

final class EnemyNode: SKNode {
    let enemyType: EnemyType
    private(set) var maxHP: CGFloat
    private(set) var currentHP: CGFloat
    let moveSpeed: CGFloat           // points per second (SKNode.speed used for slow)
    private(set) var isDead = false
    var waypointIndex: Int = 0

    var onDeath: ((EnemyNode) -> Void)?
    var onReachEnd: ((EnemyNode) -> Void)?

    private let bodyNode: SKShapeNode
    private let hpBarBg: SKShapeNode
    private let hpBarFill: SKShapeNode
    private var originalBodyColor: SKColor

    private var isSlowed = false

    init(type: EnemyType, hpScale: Float, speedScale: Float) {
        self.enemyType = type
        self.maxHP     = type.baseHP    * CGFloat(hpScale)
        self.currentHP = maxHP
        self.moveSpeed = type.baseSpeed * CGFloat(speedScale)

        let size = type.size
        let body = SKShapeNode(rectOf: size, cornerRadius: type == .titan ? 6 : 3)
        body.fillColor   = type.color
        body.strokeColor = .clear
        self.bodyNode = body
        self.originalBodyColor = type.color

        let barW: CGFloat = size.width
        let bg = SKShapeNode(rectOf: CGSize(width: barW, height: 4))
        bg.fillColor   = SKColor(white: 0.2, alpha: 0.8)
        bg.strokeColor = .clear
        bg.position    = CGPoint(x: 0, y: size.height / 2 + 5)
        self.hpBarBg = bg

        let fill = SKShapeNode(rectOf: CGSize(width: barW, height: 4))
        fill.fillColor   = SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1)
        fill.strokeColor = .clear
        fill.position    = CGPoint(x: 0, y: size.height / 2 + 5)
        self.hpBarFill = fill

        super.init()
        addChild(body)
        addChild(bg)
        addChild(fill)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask    = PhysicsCategories.enemy
        physicsBody?.contactTestBitMask = PhysicsCategories.projectile
        physicsBody?.collisionBitMask   = PhysicsCategories.none
        physicsBody?.isDynamic = false

        if type == .healer {
            run(.repeatForever(.sequence([
                .wait(forDuration: 1.0),
                .run { [weak self] in self?.heal(5) }
            ])), withKey: "regen")
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Movement

    func startMoving(fromWaypoint index: Int = 1) {
        waypointIndex = max(index, 1)
        let waypoints = PathSystem.waypoints
        guard waypointIndex < waypoints.count else { return }

        var actions: [SKAction] = []
        var prevPt = waypoints[waypointIndex - 1]

        for i in waypointIndex..<waypoints.count {
            let wp       = waypoints[i]
            let dist     = prevPt.distance(to: wp)
            let duration = TimeInterval(dist / moveSpeed)
            let captured = i
            actions.append(.move(to: wp, duration: duration))
            actions.append(.run { [weak self] in self?.waypointIndex = captured })
            prevPt = wp   // advance for next segment distance calc
        }

        actions.append(.run { [weak self] in
            guard let self, !self.isDead else { return }
            self.isDead = true
            self.removeFromParent()
            self.onReachEnd?(self)
        })

        run(.sequence(actions), withKey: "move")
    }

    // MARK: - Damage / Heal

    func takeDamage(_ rawDamage: CGFloat, ignoresArmor: Bool = false) {
        guard !isDead else { return }
        var dmg = rawDamage
        if !ignoresArmor { dmg *= enemyType.damageReduction }
        currentHP -= dmg
        updateHPBar()
        if currentHP <= 0 { die() }
    }

    private func heal(_ amount: CGFloat) {
        guard !isDead else { return }
        currentHP = min(maxHP, currentHP + amount)
        updateHPBar()
    }

    func die() {
        guard !isDead else { return }
        isDead = true
        removeAction(forKey: "move")
        removeAction(forKey: "regen")
        run(.sequence([.fadeAlpha(to: 0, duration: 0.1), .removeFromParent()]))
        onDeath?(self)
    }

    // MARK: - Slow

    func applySlowEffect(factor: CGFloat = 0.5, duration: TimeInterval = 2.0) {
        guard !enemyType.slowImmune, !isSlowed else { return }
        isSlowed = true
        // SKNode.speed multiplies action playback speed (affects move actions)
        self.speed = factor
        bodyNode.fillColor = .tdAccentTeal

        removeAction(forKey: "slowTimer")
        run(.sequence([
            .wait(forDuration: duration),
            .run { [weak self] in self?.removeSlow() }
        ]), withKey: "slowTimer")
    }

    private func removeSlow() {
        isSlowed = false
        self.speed = 1.0
        bodyNode.fillColor = originalBodyColor
    }

    // MARK: - HP bar

    private func updateHPBar() {
        let fraction = max(0, currentHP / maxHP)
        hpBarFill.xScale = fraction
        // Anchor hpBarFill on left by shifting position
        let fullW = enemyType.size.width
        hpBarFill.position.x = -fullW / 2 * (1 - fraction)
    }
}
