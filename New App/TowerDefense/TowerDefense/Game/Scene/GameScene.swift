import SpriteKit

final class GameScene: SKScene {
    // MARK: - State (set before didMove)
    let gameState: GameState
    let appState: AppState

    // MARK: - Systems
    private(set) var waveSystem: WaveSystem!

    // MARK: - Grid
    static let cols = 9
    static let rows = 18
    var grid: [[GridCell]] = []

    // MARK: - Node layers
    private let towerLayer      = SKNode()
    private let enemyLayer      = SKNode()
    private let projectileLayer = SKNode()

    var placedTowers: [TowerNode]           = []
    var activeProjectiles: [ProjectileNode] = []

    private var lastUpdateTime: TimeInterval?

    // MARK: - Init

    init(gameState: GameState, appState: AppState) {
        self.gameState = gameState
        self.appState  = appState
        super.init(size: CGSize(width: 390, height: 844))
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - didMove

    override func didMove(to view: SKView) {
        backgroundColor = .tdBackground
        physicsWorld.gravity  = .zero
        physicsWorld.contactDelegate = self

        addChild(towerLayer)
        addChild(enemyLayer)
        addChild(projectileLayer)

        setupGrid()
        addChild(PathNode(waypoints: PathSystem.waypoints))

        waveSystem = WaveSystem(scene: self, gameState: gameState)
        waveSystem.onWaveComplete    = { [weak self] in self?.handleWaveComplete() }
        waveSystem.onEnemyReachedEnd = { [weak self] in self?.handleEnemyReachedEnd() }
    }

    // MARK: - Grid

    private func setupGrid() {
        grid = (0..<GameScene.rows).map { row in
            (0..<GameScene.cols).map { col in
                var cell = GridCell(column: col, row: row)
                if PathSystem.pathCells.contains(GridCoord(col: col, row: row)) {
                    cell.state = .path
                }
                return cell
            }
        }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        let dt = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        // Move projectiles
        for proj in activeProjectiles { proj.update(deltaTime: dt) }
        activeProjectiles.removeAll { $0.parent == nil }

        // Fire towers
        let enemies = waveSystem?.activeEnemies ?? []
        for tower in placedTowers {
            guard tower.canFire(at: currentTime) else { continue }
            if let target = TargetingSystem.target(for: tower, enemies: enemies) {
                tower.aimAt(target: target)
                tower.didFire(at: currentTime)
                fireProjectile(from: tower, at: target, enemies: enemies)
            }
        }
    }

    private func fireProjectile(from tower: TowerNode, at target: EnemyNode, enemies: [EnemyNode]) {
        SoundSystem.shared.play(SoundType(towerType: tower.towerType))

        let ignoresArmor = tower.towerType.ignoresArmor || gameState.hasUpgrade("d5")
        let proj = ProjectileSystem.fire(
            from: tower,
            at: target,
            in: self,
            gameState: gameState,
            allEnemies: enemies
        ) { [weak self] enemy, damage in
            guard let self else { return }
            enemy.takeDamage(damage, ignoresArmor: ignoresArmor)
            if enemy.isDead {
                Task { @MainActor in
                    self.gameState.earnGold(enemy.enemyType.goldReward)
                }
            }
        }
        activeProjectiles.append(proj)
    }

    // MARK: - Wave events

    private func handleWaveComplete() {
        Task { @MainActor in
            gameState.waveInProgress = false
            gameState.applyInterest()
            if gameState.wave < 100 {
                gameState.shopIsOpen = true
            } else {
                appState.phase = .gameOver
            }
        }
    }

    private func handleEnemyReachedEnd() {
        Task { @MainActor in
            if gameState.shieldsRemaining > 0 {
                gameState.shieldsRemaining -= 1
            } else {
                gameState.loseLife()
                if gameState.lives <= 0 {
                    appState.phase = .gameOver
                }
            }
        }
    }

    // MARK: - Tower placement (called from GameScene+Touches)

    func placeTower(at scenePoint: CGPoint) {
        guard let type = gameState.selectedTowerType else { return }
        let cell = TowerPlacementSystem.cellFor(scenePoint: scenePoint)
        guard cell.row >= 0, cell.row < grid.count,
              cell.col >= 0, cell.col < grid[cell.row].count else { return }
        guard grid[cell.row][cell.col].isPlaceable else { return }

        Task { @MainActor in
            guard gameState.purchase(tower: type) else { return }
            grid[cell.row][cell.col].state = .tower(type)
            let center = TowerPlacementSystem.sceneCenterFor(cell: cell)
            let tower  = TowerNode(type: type, gameState: gameState)
            tower.position = center
            towerLayer.addChild(tower)
            placedTowers.append(tower)
        }
    }
}
