import Foundation
import Supabase

final class SupabaseService {
    let client: SupabaseClient
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    var currentSession: Session? {
        client.auth.currentSession
    }

    var currentUserId: UUID? {
        client.auth.currentUser?.id
    }

    init(supabaseURL: URL, anonKey: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.decoder = decoder
        self.encoder = encoder

        let redirectURL = URL(string: "diyai://login-callback")
        let options = SupabaseClientOptions(
            db: .init(encoder: encoder, decoder: decoder),
            auth: .init(storage: AuthClient.Configuration.defaultLocalStorage, redirectToURL: redirectURL),
            global: .init()
        )
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey, options: options)
    }

    func sendMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(email: email)
    }

    func signInAnonymously() async throws -> Session {
        try await client.auth.signInAnonymously()
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func handleOpenURL(_ url: URL) async throws -> Session {
        try await client.auth.session(from: url)
    }

    func fetchProfile() async throws -> Profile {
        guard let userId = currentUserId else {
            throw NSError(domain: "DIYAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user session"])
        }

        let response: PostgrestResponse<Profile> = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
        return response.value
    }

    func createRepairJob(job: RepairJob) async throws {
        _ = try await client
            .from("repair_jobs")
            .insert(job, returning: .minimal)
            .execute()
    }

    func updateRepairJobStatus(jobId: UUID, status: String, errorMessage: String? = nil) async throws {
        struct Update: Encodable {
            let status: String
            let errorMessage: String?
            enum CodingKeys: String, CodingKey {
                case status
                case errorMessage = "error_message"
            }
        }
        let update = Update(status: status, errorMessage: errorMessage)
        _ = try await client
            .from("repair_jobs")
            .update(update)
            .eq("id", value: jobId.uuidString)
            .execute()
    }

    func fetchRepairJobs(limit: Int = 50) async throws -> [RepairJob] {
        let response: PostgrestResponse<[RepairJob]> = try await client
            .from("repair_jobs")
            .select()
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
        return response.value
    }

    func fetchDiagnosisResult(jobId: UUID) async throws -> DiagnosisResult {
        let response: PostgrestResponse<DiagnosisResult> = try await client
            .from("diagnosis_results")
            .select()
            .eq("job_id", value: jobId.uuidString)
            .single()
            .execute()
        return response.value
    }

    func uploadImage(data: Data, path: String, contentType: String = "image/jpeg") async throws {
        let options = FileOptions(cacheControl: "3600", contentType: contentType, upsert: true)
        _ = try await client.storage
            .from("repairs")
            .upload(path, data: data, options: options)
    }

    func createSignedURL(path: String, expiresIn: Int = 600) async throws -> URL {
        let signed = try await client.storage
            .from("repairs")
            .createSignedURL(path: path, expiresIn: expiresIn)
        return signed
    }

    func invokeAnalyzePhoto(request: AnalyzePhotoRequest) async throws -> AnalyzePhotoResponse {
        let options = FunctionInvokeOptions(body: request)
        return try await client.functions.invoke("analyze-photo", options: options)
    }

    func deleteJob(jobId: UUID, imagePath: String, thumbPath: String) async throws {
        _ = try await client
            .from("repair_jobs")
            .delete()
            .eq("id", value: jobId.uuidString)
            .execute()
        _ = try await client.storage
            .from("repairs")
            .remove(paths: [imagePath, thumbPath])
    }
}

struct AnalyzePhotoRequest: Encodable {
    let job_id: UUID
    let category: String
    let note: String?
    let image_url: String
}

struct AnalyzePhotoResponse: Decodable {
    let issueTitle: String
    let confidence: Int
    let difficulty: String
    let estimatedMinutes: Int
    let highLevelOverview: [String]
    let tools: [ToolItem]
    let parts: [PartItem]
    let steps: [RepairStep]
    let safetyChecklist: [String]
    let commonMistakes: [String]
    let verifyBeforeBuy: [String]
}
