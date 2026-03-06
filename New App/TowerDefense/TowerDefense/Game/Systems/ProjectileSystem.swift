import SpriteKit

enum ProjectileSystem {
    /// Fire a projectile from `tower` toward `target`.
    /// Returns the projectile node added to `scene`.
    @discardableResult
    static func fire(
        from tower: TowerNode,
        at target: EnemyNode,
        in scene: SKScene,
        gameState: GameState,
        allEnemies: [EnemyNode],
        onHit: @escaping (EnemyNode, CGFloat) -> Void
    ) -> ProjectileNode {
        let proj = ProjectileNode(towerType: tower.towerType, startPosition: tower.position, target: target)
        scene.addChild(proj)

        let baseDamage = tower.towerType.baseDamage * CGFloat(gameState.globalDamageMultiplier)
        let finalDamage = applyCrit(damage: baseDamage, gameState: gameState)

        // Missile tracking speed
        if tower.towerType == .missile {
            proj.trackingSpeed = gameState.missileSpeed
        }

        let towerType      = tower.towerType
        let effectiveRange = tower.effectiveRange
        let splashRadius   = towerType.splashRadius * CGFloat(gameState.splashMultiplier)
        let ignoresArmor   = towerType.ignoresArmor || gameState.hasUpgrade("d5")

        proj.onReachTarget = { [weak scene] hitPoint in
            guard let scene else { return }

            SoundSystem.shared.play(.hit)

            // AoE splash
            if splashRadius > 0 {
                let victims = TargetingSystem.allInRange(allEnemies, from: hitPoint, radius: splashRadius)
                for v in victims { onHit(v, finalDamage) }
            } else {
                onHit(target, finalDamage)
            }

            // Tesla chain lightning
            if towerType == .tesla {
                let chainCount = towerType.chainCount + gameState.chainExtra
                let chained = TargetingSystem.allInRange(allEnemies, from: hitPoint, radius: effectiveRange)
                    .filter { $0 !== target }
                    .prefix(chainCount)
                for enemy in chained {
                    let chainDmg = finalDamage * 0.6
                    onHit(enemy, chainDmg)
                    drawChainLightning(from: hitPoint, to: enemy.position, in: scene)
                }
            }

            // Frost slow — uses tiered cryo values
            if towerType == .frost && !target.enemyType.slowImmune {
                target.applySlowEffect(
                    factor: gameState.cryoFactor,
                    duration: gameState.cryoDuration
                )
            }

            // Death Nova
            if gameState.hasUpgrade("s7") {
                let novaEnemies = TargetingSystem.allInRange(allEnemies, from: hitPoint, radius: 60)
                    .filter { $0 !== target }
                for e in novaEnemies {
                    let novaDmg = 30.0 * CGFloat(gameState.globalDamageMultiplier)
                    onHit(e, novaDmg)
                    if gameState.hasUpgrade("s8") && e.isDead {
                        Task { @MainActor in gameState.earnGold(5) }
                    }
                }
                drawNovaBurst(at: hitPoint, in: scene)
            }

            proj.removeFromParent()
        }

        return proj
    }

    private static func applyCrit(damage: CGFloat, gameState: GameState) -> CGFloat {
        guard gameState.critChance > 0 else { return damage }
        if Double.random(in: 0...1) < gameState.critChance {
            return damage * CGFloat(gameState.critMultiplier)
        }
        return damage
    }

    private static func drawChainLightning(from a: CGPoint, to b: CGPoint, in scene: SKScene) {
        let path = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        let line = SKShapeNode(path: path)
        line.strokeColor = .tdAccentPurple
        line.lineWidth = 2
        scene.addChild(line)
        line.run(.sequence([.wait(forDuration: 0.15), .removeFromParent()]))
    }

    private static func drawNovaBurst(at point: CGPoint, in scene: SKScene) {
        let ring = SKShapeNode(circleOfRadius: 1)
        ring.position = point
        ring.strokeColor = .tdAccentPurple
        ring.lineWidth = 3
        ring.fillColor = .clear
        scene.addChild(ring)
        ring.run(.sequence([
            .scale(to: 60, duration: 0.3),
            .fadeOut(withDuration: 0.1),
            .removeFromParent()
        ]))
    }
}
