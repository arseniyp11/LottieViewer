import SwiftUI
import Lottie

struct AnimationPreviewScreen: View {

    let remoteLottie: RemoteLottie

    @StateObject private var viewModel = AnimationPlayerViewModel()
    @State private var isFullScreen = false
    @State private var showInfo = false

    var body: some View {
        VStack(spacing: 16) {
            previewCard
            controlsCard
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(remoteLottie.fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            AnimationInfoSheet(remoteLottie: remoteLottie)
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            fullScreenPlayer
        }
    }

    // MARK: - Preview

    /// The card is sized by the outer VStack's normal flexible-space distribution
    /// (whatever remains after `controlsCard` claims its natural height) — this
    /// automatically reconciles against the controls' real size instead of guessing
    /// a fixed fraction of the screen. The GeometryReader here measures only that
    /// allocated container box, never the Lottie composition's own dimensions, and
    /// reports it straight back up so it can't be inflated by an oversized child.
    private var previewCard: some View {
        GeometryReader { geometry in
            ZStack {
                backdrop(for: viewModel.background)

                if !isFullScreen {
                    LottiePlayerView(
                        animation: remoteLottie.animation,
                        isPlaying: $viewModel.isPlaying,
                        progress: $viewModel.progress,
                        speed: viewModel.speed,
                        loopEnabled: viewModel.loopEnabled,
                        isScrubbing: viewModel.isScrubbing
                    )
                    .frame(
                        width: max(geometry.size.width - 32, 0),
                        height: max(geometry.size.height - 32, 0)
                    )
                    .clipped()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay(alignment: .topTrailing) {
                Button {
                    isFullScreen = true
                } label: {
                    Label("Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                }
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 340, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var fullScreenPlayer: some View {
        GeometryReader { geometry in
            ZStack {
                backdrop(for: viewModel.background)
                    .ignoresSafeArea()

                LottiePlayerView(
                    animation: remoteLottie.animation,
                    isPlaying: $viewModel.isPlaying,
                    progress: $viewModel.progress,
                    speed: viewModel.speed,
                    loopEnabled: viewModel.loopEnabled,
                    isScrubbing: viewModel.isScrubbing
                )
                .frame(
                    width: max(geometry.size.width - 48, 0),
                    height: max(geometry.size.height - 48, 0)
                )
                .clipped()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay(alignment: .topLeading) {
                Button {
                    isFullScreen = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .padding(10)
                        .background(.thinMaterial, in: Circle())
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private func backdrop(for background: PreviewBackground) -> some View {
        switch background {
        case .dark:
            Color(red: 0.06, green: 0.07, blue: 0.12)
        case .light:
            Color(.systemBackground)
        case .checker:
            CheckerboardBackground()
        }
    }

    // MARK: - Controls

    private var controlsCard: some View {
        VStack(spacing: 16) {
            playbackRow
            Divider()
            speedRow
            Divider()
            loopRow
            Divider()
            backgroundRow
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var playbackRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Button {
                    viewModel.togglePlayPause()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.accentColor, in: Circle())
                }

                Button {
                    viewModel.restart()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.4)))
                }

                Slider(
                    value: $viewModel.progress,
                    in: 0...1,
                    onEditingChanged: { editing in
                        viewModel.isScrubbing = editing
                    }
                )
            }

            HStack {
                Text(formattedTime(viewModel.progress * remoteLottie.animation.duration))
                Spacer()
                Text(formattedTime(remoteLottie.animation.duration))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var speedRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Скорость")

            Picker("Скорость", selection: $viewModel.speed) {
                ForEach(viewModel.speedOptions, id: \.self) { option in
                    Text(speedLabel(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var loopRow: some View {
        Toggle(isOn: $viewModel.loopEnabled) {
            HStack(spacing: 6) {
                Text("Loop")
                Image(systemName: "repeat")
                    .foregroundStyle(.blue)
            }
        }
    }

    private var backgroundRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background")

            Picker("Background", selection: $viewModel.background) {
                Label("Dark", systemImage: "moon.fill").tag(PreviewBackground.dark)
                Label("Light", systemImage: "sun.max").tag(PreviewBackground.light)
                Label("Checker", systemImage: "checkerboard.rectangle").tag(PreviewBackground.checker)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Formatting

    private func formattedTime(_ time: TimeInterval) -> String {
        let safeTime = max(0, time)
        let minutes = Int(safeTime) / 60
        let seconds = Int(safeTime) % 60
        let hundredths = Int((safeTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }

    private func speedLabel(_ speed: CGFloat) -> String {
        speed == speed.rounded() ? "\(Int(speed))x" : "\(speed)x"
    }
}

extension PreviewBackground: Hashable {}

private struct CheckerboardBackground: View {
    var tile: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            let columns = Int((size.width / tile).rounded(.up))
            let rows = Int((size.height / tile).rounded(.up))

            for row in 0..<rows {
                for column in 0..<columns {
                    guard (row + column).isMultiple(of: 2) else { continue }
                    let rect = CGRect(x: CGFloat(column) * tile, y: CGFloat(row) * tile, width: tile, height: tile)
                    context.fill(Path(rect), with: .color(.gray.opacity(0.3)))
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

private struct AnimationInfoSheet: View {
    let remoteLottie: RemoteLottie
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("File Name", value: remoteLottie.fileName)
                LabeledContent("Source URL", value: remoteLottie.sourceURL.absoluteString)
                LabeledContent("Dimensions", value: "\(Int(remoteLottie.animation.size.width)) × \(Int(remoteLottie.animation.size.height))")
                LabeledContent("Duration", value: String(format: "%.2fs", remoteLottie.animation.duration))
                LabeledContent("Frame Rate", value: String(format: "%.0f fps", remoteLottie.animation.framerate))
                LabeledContent("Frame Count", value: "\(Int(remoteLottie.animation.endFrame - remoteLottie.animation.startFrame))")
            }
            .navigationTitle("Animation Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
