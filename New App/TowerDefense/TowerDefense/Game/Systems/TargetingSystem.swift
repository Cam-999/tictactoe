import SpriteKit

enum TargetingSystem {
    /// Returns the enemy node closest to exit (highest waypointIndex) within range.
    static func target(for tower: TowerNode, enemies: [EnemyNode]) -> EnemyNode? {
        let range = tower.effectiveRange
        let pos = tower.position

        return enemies
            .filter { $0.parent != nil && !$0.isDead }
            .filter { pos.distance(to: $0.position) <= range }
            .max(by: { $0.waypointIndex < $1.waypointIndex })
    }

    /// All enemies within range of tower (for AoE / chain)
    static func allInRange(_ enemies: [EnemyNode], from point: CGPoint, radius: CGFloat) -> [EnemyNode] {
        enemies.filter { $0.parent != nil && !$0.isDead && point.distance(to: $0.position) <= radius }
    }
}
