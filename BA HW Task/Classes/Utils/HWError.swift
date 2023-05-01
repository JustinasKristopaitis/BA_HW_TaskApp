import Foundation

enum ContentCachingError: Error {
    case cacheMiss
}

enum HWError: Error, LocalizedError {
    case badURL
    case noInternetConnection
    case unsupportedType
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Something went wrong. Please contact us at aaa@bbb.com or try again later"
        case .noInternetConnection:
            return "No internet connection. Please connect and try again"
        case .unsupportedType:
            return "Unsupported Type"
        }
        
    }
}
