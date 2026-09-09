import SwiftUI

struct LinkImportScreen: View {

    private let maxLinkLength = 500

    @StateObject private var viewModel = LinkImportViewModel()
    @FocusState private var isLinkFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        subtitleSection
                        linkInputSection
                        pasteButton
                        loadButton

                        if let errorMessage = viewModel.errorMessage {
                            errorView(errorMessage)
                        }

                        footerInfo
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isLinkFieldFocused = false
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isLinkFieldFocused = false
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.showPreview) {
                if let animation = viewModel.loadedAnimation {
                    AnimationPreviewScreen(remoteLottie: animation)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        Text("Animation Viewer")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
    }

    // MARK: - Subtitle

    private var subtitleSection: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(.blue)

            Text("Paste a Google Drive link to preview a Lottie animation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Link input

    private var linkInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ANIMATION LINK")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(0.6)
                .foregroundStyle(.secondary)

            VStack(alignment: .trailing, spacing: 4) {
                TextField(
                    "https://drive.google.com/file/d/...",
                    text: clampedLinkBinding,
                    axis: .vertical
                )
                .font(.body)
                .lineLimit(3...6)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isLinkFieldFocused)

                Text("\(viewModel.link.count)/\(maxLinkLength)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    private var clampedLinkBinding: Binding<String> {
        Binding(
            get: { viewModel.link },
            set: { newValue in
                viewModel.link = String(newValue.prefix(maxLinkLength))
            }
        )
    }

    // MARK: - Paste from Clipboard

    private var pasteButton: some View {
        Button {
            if let clipboardText = UIPasteboard.general.string {
                viewModel.link = String(clipboardText.prefix(maxLinkLength))
            }
        } label: {
            Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(.blue)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    // MARK: - Load Animation

    private var loadButton: some View {
        Button {
            isLinkFieldFocused = false
            viewModel.loadAnimation()
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 22, height: 22)
                        Image(systemName: "play.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.blue)
                    }

                    Text("Load Animation")
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue)
        )
        .opacity(isLoadDisabled ? 0.5 : 1)
        .disabled(isLoadDisabled)
    }

    private var isLoadDisabled: Bool {
        viewModel.link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.isLoading
    }

    // MARK: - Error

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.opacity(0.1))
        )
    }

    // MARK: - Footer info

    private var footerInfo: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(.blue)

            Text("Google Drive share links are converted automatically to direct download links.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.blue.opacity(0.08))
        )
    }
}
