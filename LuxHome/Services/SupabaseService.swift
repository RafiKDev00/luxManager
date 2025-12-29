//
//  SupabaseService.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/29/25.
//

import Foundation

enum SupabaseError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, message: String)
}

class SupabaseService {
    static let shared = SupabaseService()

    // Supabase credentials
    private let baseURL = "https://nhznfazbryazoiesnzkk.supabase.co"
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oem5mYXpicnlhem9pZXNuemtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzOTM5MDQsImV4cCI6MjA4MTk2OTkwNH0.RwQsKju73euoajQfeI-bG8gT4TqrStHMDl5WkUcCyRE"

    private init() {}

    // MARK: - Storage URLs
    var storageURL: String {
        "\(baseURL)/storage/v1/object/public/photos"
    }

    // MARK: - Generic Request Builder
    private func createRequest(endpoint: String, method: String = "GET") throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/rest/v1\(endpoint)") else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=representation", forHTTPHeaderField: "Prefer")

        return request
    }

    // MARK: - Generic CRUD Operations

    /// GET request - fetch data
    func get<T: Decodable>(endpoint: String) async throws -> T {
        let request = try createRequest(endpoint: endpoint, method: "GET")

        print("📥 GET \(endpoint)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                // Try ISO8601 with fractional seconds first
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                // Fallback to standard ISO8601
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            // Log the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Failed to decode response from \(endpoint)")
                print("   Raw response: \(responseString)")
                print("   Error: \(error)")
            }
            throw SupabaseError.decodingError(error)
        }
    }

    /// POST request - create new record
    func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        var request = try createRequest(endpoint: endpoint, method: "POST")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date))
        }
        request.httpBody = try encoder.encode(body)

        print("📤 POST \(endpoint)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return try decoder.decode(R.self, from: data)
        } catch {
            // Log the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Failed to decode POST response from \(endpoint)")
                print("   Raw response: \(responseString)")
            }
            throw SupabaseError.decodingError(error)
        }
    }

    /// POST request without decoding response - for fire-and-forget operations
    func postNoResponse<T: Encodable>(endpoint: String, body: T) async throws {
        var request = try createRequest(endpoint: endpoint, method: "POST")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date))
        }
        request.httpBody = try encoder.encode(body)

        print("📤 POST (no response) \(endpoint)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }

    /// PATCH request - update existing record
    func patch<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        var request = try createRequest(endpoint: endpoint, method: "PATCH")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date))
        }
        request.httpBody = try encoder.encode(body)

        print("🔄 PATCH \(endpoint)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return try decoder.decode(R.self, from: data)
        } catch {
            // Log the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Failed to decode PATCH response from \(endpoint)")
                print("   Raw response: \(responseString)")
            }
            throw SupabaseError.decodingError(error)
        }
    }

    /// DELETE request - remove record
    func delete(endpoint: String) async throws {
        let request = try createRequest(endpoint: endpoint, method: "DELETE")

        print("🗑️ DELETE \(endpoint)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }

    // MARK: - File Upload

    /// Upload image to Supabase Storage
    func uploadPhoto(_ imageData: Data, filename: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/storage/v1/object/photos/\(filename)") else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Return the public URL
        return "\(storageURL)/\(filename)"
    }

    /// Delete photo from Supabase Storage
    func deletePhoto(filename: String) async throws {
        guard let url = URL(string: "\(baseURL)/storage/v1/object/photos/\(filename)") else {
            throw SupabaseError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }
}

// MARK: - Response Wrappers for Single Item Returns
struct SingleItemResponse<T: Decodable>: Decodable {
    let data: T
}
