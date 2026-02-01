import Foundation

enum AppError: Error, Equatable, Identifiable {
    case rateLimited
    case network
    case storage
    case auth
    case config
    case unknown(String)

    var id: String {
        switch self {
        case .rateLimited: return "rateLimited"
        case .network: return "network"
        case .storage: return "storage"
        case .auth: return "auth"
        case .config: return "config"
        case .unknown(let message): return "unknown-\(message)"
        }
    }

    var title: String {
        switch self {
        case .rateLimited: return "Daily limit reached"
        case .network: return "Connection issue"
        case .storage: return "Upload issue"
        case .auth: return "Sign-in required"
        case .config: return "Setup needed"
        case .unknown: return "Something went wrong"
        }
    }

    var message: String {
        switch self {
        case .rateLimited:
            return "You’ve used today’s free analyses. Go Pro for more daily fixes and full step-by-step plans."
        case .network:
            return "We couldn’t reach the server. Check your connection and try again."
        case .storage:
            return "We couldn’t upload your photo. Please try again."
        case .auth:
            return "Please sign in to analyze photos."
        case .config:
            return "Supabase isn’t configured. Add your Config.plist to enable cloud analysis."
        case .unknown(let message):
            return message
        }
    }

    var isRateLimited: Bool {
        if case .rateLimited = self { return true }
        return false
    }

    var actionTitle: String {
        switch self {
        case .rateLimited: return "See Pro"
        default: return "Try again"
        }
    }
}
