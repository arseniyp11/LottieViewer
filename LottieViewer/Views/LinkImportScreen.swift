import SwiftUI

struct LinkImportScreen: View {
    
    @StateObject private var viewModel = LinkImportViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Spacer()
                
                Text("Lottie Animation Viewer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Google Drive Link")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField(
                    "https://drive.google.com/file/d/...",
                    text: $viewModel.link
                )
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                Button {
                    if let clipboardText = UIPasteboard.general.string {
                        viewModel.link = clipboardText
                    }
                } label: {
                    Label(
                        "Paste from Clipboard",
                        systemImage: "doc.on.clipboard"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    viewModel.loadAnimation()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Load Animation")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    viewModel.link.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                    || viewModel.isLoading
                )
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import")
            .navigationDestination(
                isPresented: $viewModel.showPreview
            ) {
                if let animation = viewModel.loadedAnimation {
                    AnimationPreviewScreen(
                        remoteLottie: animation
                    )
                }
            }
        }
    }
}
