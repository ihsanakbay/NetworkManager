//
//  APIResponse.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation

public enum APIResponse<T> {
    case success(T?)
    case failure(APIError)

    public var result: Result<T?, APIError> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}
