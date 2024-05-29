//
//  MockAPI.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation
@testable import NetworkManager

enum MockAPI: URLGenerator {
    case endpoint

    var url: URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "endpoint"
        component.path = "/path/"
        return component.url
    }
}
