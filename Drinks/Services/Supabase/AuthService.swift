import Foundation
import Supabase

protocol AuthServiceProtocol: Sendable {
    func currentSession() async throws -> Session?
    func signIn(email: String, password: String) async throws -> Session
    func signUp(email: String, password: String, username: String) async throws -> AuthResponse
    func signOut() async throws
    func resetPassword(email: String) async throws
    func authStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)>
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private let manager: SupabaseManager

    init(manager: SupabaseManager = .shared) {
        self.manager = manager
    }

    func currentSession() async throws -> Session? {
        let client = try manager.requireClient()
        return client.auth.currentSession
    }

    func signIn(email: String, password: String) async throws -> Session {
        let client = try manager.requireClient()
        let session = try await client.auth.signIn(email: email, password: password)
        return session
    }

    func signUp(email: String, password: String, username: String) async throws -> AuthResponse {
        let client = try manager.requireClient()
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        return try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "display_name": .string(trimmedUsername),
                "username": .string(trimmedUsername)
            ]
        )
    }

    func signOut() async throws {
        let client = try manager.requireClient()
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        let client = try manager.requireClient()
        try await client.auth.resetPasswordForEmail(email)
    }

    func authStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    let client = try manager.requireClient()

                    for await (event, session) in client.auth.authStateChanges {
                        if Self.relevantEvents.contains(event) {
                            continuation.yield((event, session))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.yield((.signedOut, nil))
                    continuation.finish()
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private static let relevantEvents: Set<AuthChangeEvent> = [
        .initialSession,
        .signedIn,
        .signedOut,
        .tokenRefreshed,
        .userUpdated
    ]
}
