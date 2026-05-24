import Foundation

enum AppEnvironment: String {
    case development
    case staging
    case production

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

struct SupabaseCredentials: Equatable {
    let projectURL: URL
    let anonKey: String

    var isConfigured: Bool {
        !anonKey.isEmpty
            && anonKey != AppConfig.placeholderAnonKey
            && projectURL.absoluteString != AppConfig.placeholderProjectURL
    }
}

enum AppConfig {
    static let placeholderProjectURL = "https://YOUR_PROJECT_REF.supabase.co"
    static let placeholderAnonKey = "YOUR_SUPABASE_ANON_KEY"

    private static let secretsFileName = "SupabaseSecrets"
    private static let urlKey = "SUPABASE_URL"
    private static let anonKeyKey = "SUPABASE_ANON_KEY"

    static let environment: AppEnvironment = .current

    static var supabase: SupabaseCredentials {
        guard
            let plistURL = Bundle.main.url(forResource: secretsFileName, withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let urlString = plist[urlKey] as? String,
            let anonKey = plist[anonKeyKey] as? String,
            let projectURL = URL(string: urlString)
        else {
            return SupabaseCredentials(
                projectURL: URL(string: placeholderProjectURL)!,
                anonKey: placeholderAnonKey
            )
        }

        return SupabaseCredentials(projectURL: projectURL, anonKey: anonKey)
    }

    static var isSupabaseConfigured: Bool {
        supabase.isConfigured
    }
}
