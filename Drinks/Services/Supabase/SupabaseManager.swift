import Foundation
import Supabase

final class SupabaseManager: @unchecked Sendable {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    var isConfigured: Bool {
        AppConfig.isSupabaseConfigured
    }

    private init() {
        let credentials = AppConfig.supabase

        client = SupabaseClient(
            supabaseURL: credentials.projectURL,
            supabaseKey: credentials.anonKey,
            options: SupabaseClientOptions(
                auth: .init(
                    flowType: .pkce,
                    autoRefreshToken: true
                )
            )
        )
    }

    func requireClient() throws -> SupabaseClient {
        guard isConfigured else {
            throw NetworkError.notConfigured
        }
        return client
    }
}
