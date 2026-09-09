import SwiftUI
import Lottie

struct LottiePlayerView: UIViewRepresentable {
    
    let animation: LottieAnimation
    
    @Binding var isPlaying: Bool
    @Binding var progress: CGFloat
    
    var speed: CGFloat
    var loopEnabled: Bool
    var isScrubbing: Bool

    func makeUIView(context: Context) -> LottieAnimationView {

        let view = LottieAnimationView()

        view.animation = animation
        view.contentMode = .scaleAspectFit
        view.loopMode = loopEnabled ? .loop : .playOnce
        view.animationSpeed = speed

        if isPlaying {
            view.play()
        }

        return view
    }

    func updateUIView(
        _ uiView: LottieAnimationView,
        context: Context
    ) {

        uiView.animationSpeed = speed
        uiView.loopMode = loopEnabled ? .loop : .playOnce
        context.coordinator.isScrubbing = isScrubbing

        if isScrubbing {
            uiView.pause()

            if abs(uiView.currentProgress - progress) > 0.001 {
                uiView.currentProgress = progress
            }
        } else {
            if abs(uiView.currentProgress - progress) > 0.01 {
                uiView.currentProgress = progress
            }

            if isPlaying {
                if !uiView.isAnimationPlaying {
                    uiView.play()
                }
            } else {
                uiView.pause()
            }
        }

        context.coordinator.startUpdatingProgress(
            from: uiView,
            progress: $progress
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {

        private var timer: Timer?
        var isScrubbing = false

        func startUpdatingProgress(
            from view: LottieAnimationView,
            progress: Binding<CGFloat>
        ) {

            guard timer == nil else { return }

            timer = Timer.scheduledTimer(
                withTimeInterval: 0.05,
                repeats: true
            ) { [weak self] _ in
                guard let self, !self.isScrubbing else { return }

                if view.isAnimationPlaying {
                    progress.wrappedValue = view.currentProgress
                }
            }
        }

        deinit {
            timer?.invalidate()
        }
    }
}
