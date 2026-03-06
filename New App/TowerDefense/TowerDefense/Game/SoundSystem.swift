import AVFoundation

enum SoundType {
    case cannon, sniper, tesla, frost, missile, hit

    init(towerType: TowerType) {
        switch towerType {
        case .cannon:  self = .cannon
        case .sniper:  self = .sniper
        case .tesla:   self = .tesla
        case .frost:   self = .frost
        case .missile: self = .missile
        }
    }
}

/// Synthesizes short procedural sounds via AVAudioEngine (no audio files needed).
final class SoundSystem: ObservableObject {
    static let shared = SoundSystem()

    @Published var isMuted = false

    private let engine = AVAudioMixerNode()
    private let avEngine = AVAudioEngine()

    private init() {
        avEngine.attach(engine)
        avEngine.connect(engine, to: avEngine.mainMixerNode, format: nil)
        try? avEngine.start()
    }

    func play(_ type: SoundType) {
        guard !isMuted else { return }
        let params = soundParams(for: type)
        guard let buffer = makeBuffer(params) else { return }

        let playerNode = AVAudioPlayerNode()
        avEngine.attach(playerNode)
        avEngine.connect(playerNode, to: engine, format: buffer.format)
        playerNode.play()
        playerNode.scheduleBuffer(buffer) { [weak self] in
            DispatchQueue.main.async { self?.avEngine.detach(playerNode) }
        }
    }

    // MARK: - Buffer synthesis

    private struct Params {
        let oscType: OscType
        let startFreq: Double
        let endFreq: Double
        let duration: Double
        let volume: Float
    }

    private enum OscType { case sine, sawtooth, square, triangle }

    private func soundParams(for type: SoundType) -> Params {
        switch type {
        case .cannon:  return Params(oscType: .sine,     startFreq: 90,   endFreq: 35,  duration: 0.22, volume: 0.18)
        case .sniper:  return Params(oscType: .sawtooth, startFreq: 700,  endFreq: 150, duration: 0.12, volume: 0.18)
        case .tesla:   return Params(oscType: .square,   startFreq: 400,  endFreq: 200, duration: 0.18, volume: 0.12)
        case .frost:   return Params(oscType: .sine,     startFreq: 600,  endFreq: 900, duration: 0.15, volume: 0.14)
        case .missile: return Params(oscType: .triangle, startFreq: 180,  endFreq: 80,  duration: 0.20, volume: 0.18)
        case .hit:     return Params(oscType: .sine,     startFreq: 1200, endFreq: 800, duration: 0.08, volume: 0.10)
        }
    }

    private func makeBuffer(_ params: Params) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(sampleRate * params.duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let twoPi = 2.0 * Double.pi
        var phase = 0.0

        for i in 0..<Int(frameCount) {
            let t        = Double(i) / sampleRate
            let progress = t / params.duration
            let freq     = params.startFreq + (params.endFreq - params.startFreq) * progress
            let envelope = Float(max(0.0, 1.0 - progress))

            phase += twoPi * freq / sampleRate
            if phase > twoPi { phase -= twoPi }

            var sample: Float
            switch params.oscType {
            case .sine:
                sample = Float(sin(phase))
            case .sawtooth:
                sample = Float(phase / Double.pi - 1.0)   // -1 … 1
            case .square:
                sample = sin(phase) >= 0 ? 1.0 : -1.0
            case .triangle:
                let norm = phase / twoPi
                sample = Float(abs(4.0 * norm - 2.0) - 1.0)
            }

            data[i] = sample * envelope * params.volume
        }

        return buffer
    }
}
