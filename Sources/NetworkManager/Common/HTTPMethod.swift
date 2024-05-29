//
//  HTTPMethod.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

public enum HTTPMethod {
    case get(headers: [String: String] = [:], token: String? = nil)
    case post(headers: [String: String] = [:], token: String? = nil, body: [String: Any])
    case put(headers: [String: String] = [:], token: String? = nil)
    case delete(headers: [String: String] = [:], token: String? = nil)
    case patch(headers: [String: String] = [:], token: String? = nil)
}

extension HTTPMethod: CustomStringConvertible {
    public var operation: String {
        return self.description
    }

    public var description: String {
        switch self {
        case .get: "GET"
        case .post: "POST"
        case .put: "PUT"
        case .delete: "DELETE"
        case .patch: "PATCH"
        }
    }

    func getHeaders() -> [String: String]? {
        switch self {
        case .get(let headers, _): headers
        case .post(let headers, _, _): headers
        case .put(let headers, _): headers
        case .delete(let headers, _): headers
        case .patch(let headers, _): headers
        }
    }

    func getToken() -> String? {
        switch self {
        case .get(_, let token): token
        case .post(_, let token, _): token
        case .put(_, let token): token
        case .delete(_, let token): token
        case .patch(_, let token): token
        }
    }

    func getData() -> [String: Any]? {
        switch self {
        case .get: nil
        case .post(_, _, let body): body
        case .put: nil
        case .delete: nil
        case .patch: nil
        }
    }
}
