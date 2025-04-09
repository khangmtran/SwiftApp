//
//  CTGetLegislators.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 2/8/25.
//

// CTGeocodioService.swift
import Foundation

struct Legislator: Codable, Identifiable {
    let type: String
    let firstName: String
    let lastName: String
    let state: String
    
    var id: String{
        "\(firstName)\(lastName)"
    }
}

class CTGeocodioService {
    private let baseURL = "https://citizenship-swiftapp-backend.onrender.com/api/geocode"
    
    func fetchLegislators(zipCode: String) async throws -> [Legislator] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["zipCode": zipCode]
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let proxyResponse = try JSONDecoder().decode(ProxyResponse.self, from: data)
        
        let state = extractStateFromAddress(address: proxyResponse.data.address)

        return proxyResponse.data.fields.congressional_districts.first?.current_legislators.map { legislator in
            Legislator(
                type: legislator.type,
                firstName: legislator.bio.first_name,
                lastName: legislator.bio.last_name,
                state: state
            )
        } ?? []
    }

    private func extractStateFromAddress(address: String) -> String {
        let cityStateZip = address.components(separatedBy: ", ")
        let state = cityStateZip[1].components(separatedBy: " ")
        return state[0]
    }
}

struct ProxyResponse: Codable {
    let data: GeocodioResponse
}

// Response models
struct GeocodioResponse: Codable {
    let address: String
    let fields: Fields
}

struct Fields: Codable {
    let congressional_districts: [CongressionalDistrict]
}

struct CongressionalDistrict: Codable {
    let current_legislators: [CurrentLegislator]
}

struct CurrentLegislator: Codable {
    let type: String
    let bio: Bio
}

struct Bio: Codable {
    let first_name: String
    let last_name: String
}
