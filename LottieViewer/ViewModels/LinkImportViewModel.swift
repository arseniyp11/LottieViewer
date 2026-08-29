import Foundation
import Combine
import Lottie

@MainActor
final class LinkImportViewModel: ObservableObject {
    
    @Published var link: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var loadedAnimation: RemoteLottie?
    @Published var showPreview: Bool = false
    
    private let loader = LottieLinkLoader()
    
    func loadAnimation() {
        guard !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Введите ссылку на Google Drive"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let remoteLottie = try await loader.load(from: link)
                
                loadedAnimation = remoteLottie
                showPreview = true
                isLoading = false
                
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
