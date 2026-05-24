import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    enum Phase: Equatable {
        case initializing
        case unauthenticated
        case authenticated
    }

    @Published private(set) var phase: Phase = .initializing
    @Published private(set) var profile: Profile?
    @Published private(set) var userEmail: String?
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    var isAuthenticated: Bool { phase == .authenticated }

    private let auth: AuthService
    private let database: DatabaseService
    private var authStateTask: Task<Void, Never>?

    init(auth: AuthService = .shared, database: DatabaseService = .shared) {
        self.auth = auth
        self.database = database
        startObservingAuthState()
    }

    deinit {
        authStateTask?.cancel()
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    func signIn(email: String, password: String) async {
        clearMessages()
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let session = try await auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            await applySession(session)
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }
    }

    func signUp(email: String, password: String, username: String) async {
        clearMessages()
        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedUsername.count >= 3 else {
            errorMessage = "Username must be at least 3 characters."
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters (you entered \(password.count))."
            return
        }

        do {
            let response = try await auth.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                username: trimmedUsername
            )

            if let session = response.session {
                await applySession(session)
            } else {
                successMessage = "Account created. Check your email to confirm, then sign in."
                phase = .unauthenticated
            }
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }
    }

    func signOut() async {
        clearMessages()
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await auth.signOut()
            applySignedOutState()
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }
    }

    func resetPassword(email: String) async {
        clearMessages()
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await auth.resetPassword(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
            successMessage = "If an account exists for that email, a reset link is on its way."
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }
    }

    private func startObservingAuthState() {
        authStateTask = Task { [weak self] in
            guard let self else { return }

            for await (_, session) in auth.authStateChanges() {
                guard !Task.isCancelled else { return }

                if let session {
                    await applySession(session)
                } else {
                    applySignedOutState()
                }
            }
        }
    }

    private func applySession(_ session: Session) async {
        userEmail = session.user.email
        phase = .authenticated
        errorMessage = nil

        do {
            profile = try await database.fetchCurrentProfile()
        } catch {
            profile = nil
        }
    }

    private func applySignedOutState() {
        profile = nil
        userEmail = nil
        phase = .unauthenticated
    }
}
