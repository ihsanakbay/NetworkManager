//
//  DictionaryExtensionTests.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

@testable import NetworkManager
import XCTest

final class DictionaryExtensionTests: XCTestCase {
    func testExtension() throws {
        let data: [String: Any]? = ["email": "test@email.com", "password": "password"]
        let stringParams = try XCTUnwrap(data?.parameters())
        let straightData = try XCTUnwrap("email=test@email.com&password=password".data(using: .utf8))
        let dataParams = try XCTUnwrap(stringParams.data(using: String.Encoding.utf8, allowLossyConversion: false))
        XCTAssertEqual(dataParams.count, straightData.count)
    }
}
