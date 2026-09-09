import Foundation
import Combine
import CoreGraphics

enum PreviewBackground {
    case dark
    case light
    case checker
}

@MainActor
final class AnimationPlayerViewModel: ObservableObject {

    @Published var isPlaying = true
    @Published var progress: CGFloat = 0
    @Published var speed: CGFloat = 1
    @Published var loopEnabled = true
    @Published var isScrubbing = false
    @Published var background: PreviewBackground = .dark

    let speedOptions: [CGFloat] = [0.25, 0.5, 1, 2]

    func togglePlayPause() {
        isPlaying.toggle()
    }
    
    func restart() {
        progress = 0
        isPlaying = true
    }
    
    func setSpeed(_ speed: CGFloat) {
        self.speed = speed
    }
    
    func setLoop(_ enabled: Bool) {
        loopEnabled = enabled
    }
}
