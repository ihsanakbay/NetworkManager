//
//  MockRequest.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation
@testable import NetworkManager

struct MockRequest: APIRequest {
    func parseResponse(data: Data) throws -> MockDto? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(MockDto.self, from: data)
        } catch {
            throw APIError.parseResponse(errorMessage: error.localizedDescription)
        }
    }
}

struct MockDto: Decodable, Equatable {
    let message: String
}
