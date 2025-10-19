import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // ⚠️ REPLACE THESE WITH YOUR ACTUAL SUPABASE VALUES FROM DASHBOARD
        // Go to: Supabase Dashboard → Settings → API
        let supabaseURL = URL(string: "https://bivnbbhhlllaedjkkugv.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpdm5iYmhobGxsYWVkamtrdWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MjU2NjMsImV4cCI6MjA3NjQwMTY2M30.wV5GY6jU_JfRNoHCY7KUktC3Gz_Fd0pLPfLegyjHJrQ"
        
        print("🔧 Initializing Supabase client...")
        print("📍 URL: \(supabaseURL)")
        print("🔑 Key: \(supabaseKey.prefix(20))...")
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
        
        print("✅ Supabase client initialized")
    }
}
