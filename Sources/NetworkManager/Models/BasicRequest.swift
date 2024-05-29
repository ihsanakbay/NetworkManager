//
//  BasicRequest.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation

public struct BasicRequest<T: Decodable>: APIRequest {
    public typealias ResponseDataType = T

    public init() {}

    public func parseResponse(data: Data) throws -> ResponseDataType {
        let decoder = JSONDecoder()
        return try decoder.decode(ResponseDataType.self, from: data)
    }
}
