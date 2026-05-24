import Foundation
import Supabase

/// Dashboard-compatible accessor. Credentials live in `SupabaseSecrets.plist`, not here.
var supabase: SupabaseClient {
    SupabaseManager.shared.client
}
