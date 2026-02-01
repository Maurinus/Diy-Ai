import Foundation

struct AppErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .timedOut:
                return .network
            default:
                return .unknown(urlError.localizedDescription)
            }
        }

        let message = error.localizedDescription
        let lower = message.lowercased()

        if lower.contains("daily limit") || lower.contains("limit reached") || lower.contains("429") {
            return .rateLimited
        }
        if lower.contains("offline") || lower.contains("network") || lower.contains("connection") {
            return .network
        }
        if lower.contains("storage") || lower.contains("upload") {
            return .storage
        }
        if lower.contains("unauthorized") || lower.contains("no user session") || lower.contains("invalid token") {
            return .auth
        }
        if lower.contains("config") || lower.contains("supabase") {
            return .config
        }

        return .unknown("We hit a snag. Please try again.")
    }
}
