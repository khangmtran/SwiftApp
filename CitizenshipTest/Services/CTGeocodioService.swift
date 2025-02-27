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
    private let apiKey = "0eaed66a3af37ee17636001e6176e7777aa7e7a"
    
    func fetchLegislators(zipCode: String) async throws -> [Legislator] {
        let urlString = "https://api.geocod.io/v1.7/geocode?q=\(zipCode)&fields=cd&format=simple&api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeocodioResponse.self, from: data)
        
        let state = extractStateFromAddress(address: response.address)
        
        return response.fields.congressional_districts.first?.current_legislators.map{ legislator in
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
