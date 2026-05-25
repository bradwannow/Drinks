import Foundation

enum NetworkError: LocalizedError, Equatable {
    case notConfigured
    case databaseNotSetup
    case unauthorized
    case notFound
    case decodingFailed
    case serverError(statusCode: Int, message: String?)
    case transport(underlying: String)
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase is not configured. Add your project URL and anon key to SupabaseSecrets.plist."
        case .databaseNotSetup:
            return "Database tables haven't been created yet. Run supabase/migrations through 005_menus.sql in your Supabase SQL Editor, then pull to refresh."
        case .unauthorized:
            return "You are not signed in or your session has expired."
        case .notFound:
            return "The requested resource could not be found."
        case .decodingFailed:
            return "We couldn't read the server response."
        case let .serverError(statusCode, message):
            if let message, !message.isEmpty {
                return "Server error (\(statusCode)): \(message)"
            }
            return "Server error (\(statusCode))."
        case let .transport(underlying):
            return underlying
        case let .unknown(message):
            return message
        }
    }

    static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let urlError = error as? URLError {
            return .transport(underlying: urlError.localizedDescription)
        }

        if error is DecodingError {
            return .decodingFailed
        }

        let message = error.localizedDescription
        if message.localizedCaseInsensitiveContains("could not find")
            || message.localizedCaseInsensitiveContains("could not load")
            || message.localizedCaseInsensitiveContains("relation")
            || message.localizedCaseInsensitiveContains("does not exist") {
            return .databaseNotSetup
        }

        if message.localizedCaseInsensitiveContains("jwt") || message.localizedCaseInsensitiveContains("unauthorized") {
            return .unauthorized
        }

        if message.localizedCaseInsensitiveContains("not found") {
            return .notFound
        }

        return .unknown(message: message)
    }
}
