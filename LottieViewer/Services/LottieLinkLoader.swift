import Foundation
import Lottie

protocol LottieLoading {
    func load(from link: String) async throws -> RemoteLottie
}

enum LottieLoaderError: LocalizedError {
    case emptyLink
    case invalidURL
    case invalidGoogleDriveURL
    case httpError(Int)
    case emptyData
    case invalidLottie
    
    var errorDescription: String? {
        switch self {
        case .emptyLink:
            return "Ссылка не указана."
            
        case .invalidURL:
            return "Некорректная ссылка."
            
        case .invalidGoogleDriveURL:
            return "Это не является корректной ссылкой Google Drive."
            
        case .httpError(let statusCode):
            return "Ошибка загрузки. Код: \(statusCode)."
            
        case .emptyData:
            return "Получен пустой файл."
            
        case .invalidLottie:
            return "Файл не является корректной Lottie-анимацией."
        }
    }
}

final class LottieLinkLoader: LottieLoading {
    
    func load(from link: String) async throws -> RemoteLottie {
        
        let trimmedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedLink.isEmpty else {
            throw LottieLoaderError.emptyLink
        }
        
        guard let url = URL(string: trimmedLink) else {
            throw LottieLoaderError.invalidURL
        }
        
        guard let fileID = extractGoogleDriveFileID(from: url) else {
            throw LottieLoaderError.invalidGoogleDriveURL
        }

        var downloadURLComponents = URLComponents()
        downloadURLComponents.scheme = "https"
        downloadURLComponents.host = "drive.google.com"
        downloadURLComponents.path = "/uc"
        downloadURLComponents.queryItems = [
            URLQueryItem(name: "export", value: "download"),
            URLQueryItem(name: "id", value: fileID)
        ]

        guard let downloadURL = downloadURLComponents.url else {
            throw LottieLoaderError.invalidGoogleDriveURL
        }

        let (data, response) = try await URLSession.shared.data(from: downloadURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LottieLoaderError.httpError(0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw LottieLoaderError.httpError(httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw LottieLoaderError.emptyData
        }
        
        guard let animation = try? LottieAnimation.from(data: data) else {
            throw LottieLoaderError.invalidLottie
        }
        
        return RemoteLottie(
            animation: animation,
            sourceURL: url,
            fileName: "animation.json"
        )
    }
    
    private func extractGoogleDriveFileID(from url: URL) -> String? {
        
        guard url.host?.lowercased() == "drive.google.com" else {
            return nil
        }
        
        let pathComponents = url.pathComponents
        
        if let fileIndex = pathComponents.firstIndex(of: "d"),
           fileIndex + 1 < pathComponents.count {
            
            let fileID = pathComponents[fileIndex + 1]
            
            if !fileID.isEmpty {
                return fileID
            }
        }
        
        if let queryItems = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )?.queryItems {
            
            if let id = queryItems.first(where: { $0.name == "id" })?.value,
               !id.isEmpty {
                return id
            }
        }
        
        return nil
    }
}
