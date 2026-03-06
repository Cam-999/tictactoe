import SpriteKit

final class WaveSystem {
    private weak var scene: SKScene?
    private(set) var activeEnemies: [EnemyNode] = []

    /// Total enemies that will ever exist this wave (grows when splitters spawn grunts)
    private var totalCount: Int = 0
    /// Enemies that have been resolved (killed or reached end)
    private var resolvedCount: Int = 0

    private var shieldUsedThisWave = false

    weak var gameState: GameState?
    var onWaveComplete: (() -> Void)?
    var onEnemyReachedEnd: (() -> Void)?

    init(scene: SKScene, gameState: GameState) {
        self.scene     = scene
        self.gameState = gameState
    }

    func beginWave(_ config: WaveConfig) {
        guard let scene else { return }
        activeEnemies.removeAll()
        totalCount     = config.spawns.count
        resolvedCount  = 0
        shieldUsedThisWave = false

        for spawn in config.spawns {
            scene.run(.sequence([
                .wait(forDuration: spawn.delay),
                .run { [weak self] in self?.spawnEnemy(spawn, in: scene) }
            ]))
        }
    }

    private func spawnEnemy(_ spawn: EnemySpawn, in scene: SKScene) {
        let node = EnemyNode(type: spawn.type, hpScale: spawn.hpScale, speedScale: spawn.speedScale)
        node.position   = PathSystem.waypoints[0]
        node.onDeath    = { [weak self] e in self?.handleEnemyDied(e) }
        node.onReachEnd = { [weak self] e in self?.handleEnemyReachedEnd(e) }
        scene.addChild(node)
        activeEnemies.append(node)
        node.startMoving()
    }

    // MARK: - Enemy events

    private func handleEnemyDied(_ enemy: EnemyNode) {
        activeEnemies.removeAll { $0 === enemy }

        if enemy.enemyType == .splitter {
            let extra = enemy.enemyType.splitCount
            totalCount += extra
            for _ in 0..<extra { spawnSplitGrunt(from: enemy) }
        }

        if let gs = gameState, gs.hasUpgrade("sp6") {
            TargetingSystem.allInRange(activeEnemies, from: enemy.position, radius: 60)
                .forEach { $0.takeDamage(30) }
        }

        resolve()
    }

    private func handleEnemyReachedEnd(_ enemy: EnemyNode) {
        activeEnemies.removeAll { $0 === enemy }

        if let gs = gameState, gs.hasUpgrade("def3"), !shieldUsedThisWave {
            shieldUsedThisWave = true
        } else {
            onEnemyReachedEnd?()
        }

        resolve()
    }

    private func spawnSplitGrunt(from parent: EnemyNode) {
        guard let scene else { return }
        let grunt = EnemyNode(type: .grunt, hpScale: 1.0, speedScale: 1.0)
        grunt.position      = parent.position
        grunt.waypointIndex = parent.waypointIndex
        grunt.onDeath       = { [weak self] e in self?.handleEnemyDied(e) }
        grunt.onReachEnd    = { [weak self] e in self?.handleEnemyReachedEnd(e) }
        scene.addChild(grunt)
        activeEnemies.append(grunt)
        grunt.startMoving(fromWaypoint: parent.waypointIndex + 1)
    }

    private func resolve() {
        resolvedCount += 1
        if resolvedCount >= totalCount && activeEnemies.isEmpty {
            onWaveComplete?()
        }
    }
}
