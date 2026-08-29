import Foundation
import Combine
import CoreGraphics

@MainActor
final class AnimationPlayerViewModel: ObservableObject {
    
    @Published var isPlaying = true
    @Published var progress: CGFloat = 0
    @Published var speed: CGFloat = 1
    @Published var loopEnabled = true
    
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
