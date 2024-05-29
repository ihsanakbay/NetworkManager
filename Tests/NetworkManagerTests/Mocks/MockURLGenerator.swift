//
//  MockURLGenerator.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation
@testable import NetworkManager

struct MockURLGenerator: URLGenerator {
    var url: URL? = URL(string: "https://www.google.com")
}
