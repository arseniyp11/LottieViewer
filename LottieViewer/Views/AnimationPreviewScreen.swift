import SwiftUI
import Lottie

struct AnimationPreviewScreen: View {
    
    let remoteLottie: RemoteLottie
    
    @StateObject private var viewModel = AnimationPlayerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Предпросмотр")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            LottiePlayerView(
                animation: remoteLottie.animation,
                isPlaying: $viewModel.isPlaying,
                progress: $viewModel.progress,
                speed: viewModel.speed,
                loopEnabled: viewModel.loopEnabled
            )
            .frame(maxWidth: .infinity)
            .frame(height: 350)
            
            HStack(spacing: 20) {
                
                Button {
                    viewModel.togglePlayPause()
                } label: {
                    Image(
                        systemName: viewModel.isPlaying
                        ? "pause.fill"
                        : "play.fill"
                    )
                    .font(.title2)
                }
                
                Button {
                    viewModel.restart()
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                }
            }
            
            Slider(
                value: $viewModel.progress,
                in: 0...1
            )
            
            HStack {
                Text("Скорость")
                
                Spacer()
                
                Picker("Скорость", selection: $viewModel.speed) {
                    Text("0.5x").tag(CGFloat(0.5))
                    Text("1x").tag(CGFloat(1))
                    Text("2x").tag(CGFloat(2))
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            Toggle(
                "Loop",
                isOn: $viewModel.loopEnabled
            )
            
            Spacer()
        }
        .padding()
        .navigationTitle("Animation Preview")
    }
}
