import Foundation

enum WaveData {
    static let all: [WaveConfig] = (1...100).map { wave in
        let tier    = (wave - 1) / 10          // 0–9
        let hpScale = Float(1.0 + Double(wave) * 0.12)
        let spdScale = Float(1.0 + Double(wave) * 0.04)
        let isBoss  = wave % 10 == 0
        let goldBonus = 50 + wave * 5 + (isBoss ? 150 : 0)

        var spawns: [EnemySpawn] = []

        // Base enemy pool grows with tier
        let availableTypes: [EnemyType] = {
            var types: [EnemyType] = [.grunt]
            if tier >= 1 { types.append(.armored) }
            if tier >= 2 { types.append(.swift) }
            if tier >= 3 { types.append(.healer) }
            if tier >= 4 { types.append(.splitter) }
            return types
        }()

        let baseCount = 5 + wave * 2
        let spawnInterval: TimeInterval = max(0.4, 1.5 - Double(tier) * 0.1)

        for i in 0..<baseCount {
            let typeIndex = i % availableTypes.count
            let type = availableTypes[typeIndex]
            spawns.append(EnemySpawn(
                type: type,
                hpScale: hpScale,
                speedScale: spdScale,
                delay: TimeInterval(i) * spawnInterval
            ))
        }

        // Boss at end of boss waves
        if isBoss {
            let bossDelay = TimeInterval(baseCount) * spawnInterval + 1.0
            spawns.append(EnemySpawn(
                type: .titan,
                hpScale: hpScale * 1.5,
                speedScale: spdScale * 0.8,
                delay: bossDelay
            ))
        }

        return WaveConfig(
            waveNumber: wave,
            spawns: spawns,
            goldBonus: goldBonus,
            isBossWave: isBoss
        )
    }
}
