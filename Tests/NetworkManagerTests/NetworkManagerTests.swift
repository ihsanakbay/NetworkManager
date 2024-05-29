@testable import NetworkManager
import XCTest

final class NetworkManagerTests: XCTestCase {
    private var networkManager: NetworkManager!
    private let request = MockRequest()
    private let queue = DispatchQueue(label: "NetworkManagerTests")

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)
        networkManager = NetworkManager(urlSession: mockSession)
    }

    override func tearDown() {
        networkManager = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchGet_successfullyParsesExpectedJSONData() throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"testdata\"}".data(using: .utf8))
        setupMockResponse(statusCode: 200, data: mockJSONData)
        let expectation = expectation(description: "NetworkManager fetch expectation")
        let expected = MockDto(message: "testdata")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success(let list):
                XCTAssertEqual(list, expected)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPost_handleSuccessResponse() throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using:.utf8))
        setupMockResponse(statusCode: 201, data: mockJSONData)
        let expectation = expectation(description: "NetworkManager fetch expectation")
        let expected = MockDto(message: "success")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .post(body: ["text": "text"]),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success(let list):
                XCTAssertEqual(list, expected)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPut_handleSuccessResponse() throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using:.utf8))
        setupMockResponse(statusCode: 200, data: mockJSONData)
        let expectation = expectation(description: "NetworkManager fetch expectation")
        let expected = MockDto(message: "success")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .put(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success(let list):
                XCTAssertEqual(list, expected)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchDelete_handleSuccessResponse() throws {
        setupMockResponse(statusCode: 204)
        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .delete(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchDeleteDefaultRequest_handleSuccessResponse() throws {
        setupMockResponse(statusCode: 204)
        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .delete(),
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                break
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchPatch_handleSuccessResponse() throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using: .utf8))
        setupMockResponse(statusCode: 200, data: mockJSONData)
        let expected = MockDto(message: "success")
        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .patch(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success(let list):
                XCTAssertEqual(list, expected)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesInvalidResponseData() throws {
        setupMockResponse()
        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .parseResponse(errorMessage: "The data couldn’t be read because it isn’t in the correct format."))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesBadRequestError() throws {
        setupMockResponse(statusCode: 400)

        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(api: MockAPI.endpoint, method: .get(), request: request, completionQueue: queue) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .httpError(.badRequest))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesUnauthorizedError() throws {
        setupMockResponse(statusCode: 401)

        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .httpError(.unauthorized))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesForbiddenError() throws {
        setupMockResponse(statusCode: 403)

        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .httpError(.forbidden))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesNotFoundError() throws {
        setupMockResponse(statusCode: 404)

        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .httpError(.notFound))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGet_handlesServerError() throws {
        setupMockResponse(statusCode: 500)

        let expectation = expectation(description: "NetworkManager fetch expectation")
        networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request,
            completionQueue: queue
        ) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .httpError(.serverError))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchGetAsync_successfulDataFetch() async throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"testdata\"}".data(using: .utf8))
        let expected = MockDto(message: "testdata")
        setupMockResponse(statusCode: 200, data: mockJSONData)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .get(),
            request: request
        )
        XCTAssertEqual(data, expected)
    }

    func testFetchPostAsync_successfulDataFetch() async throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using: .utf8))
        let expected = MockDto(message: "success")
        setupMockResponse(statusCode: 200, data: mockJSONData)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .post(body: [:]),
            request: request
        )
        XCTAssertEqual(data, expected)
    }

    func testFetchPutAsync_successfulDataFetch() async throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using: .utf8))
        let expected = MockDto(message: "success")
        setupMockResponse(statusCode: 200, data: mockJSONData)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .put(),
            request: request
        )
        XCTAssertEqual(data, expected)
    }

    func testFetchPatchAsync_successfulDataFetch() async throws {
        let mockJSONData = try XCTUnwrap("{\"message\":\"success\"}".data(using: .utf8))
        let expected = MockDto(message: "success")
        setupMockResponse(statusCode: 200, data: mockJSONData)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .patch(),
            request: request
        )
        XCTAssertEqual(data, expected)
    }

    func testFetchDeleteAsync_successfulDataFetch() async throws {
        setupMockResponse(statusCode: 204)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .delete(),
            request: request
        )
        XCTAssertEqual(data, nil)
    }

    func testFetchDeleteAsyncNoRequest_successfulDataFetch() async throws {
        setupMockResponse(statusCode: 204)

        let data = try? await networkManager.fetch(
            api: MockAPI.endpoint,
            method: .delete()
        )
        XCTAssertEqual(data, nil)
    }

    func testFetchGetAsync_handlesInvalidData() async throws {
        let mockJSONData = try XCTUnwrap("{\"notamessage\":\"testdata\"}".data(using: .utf8))
        setupMockResponse(data: mockJSONData)

        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .parseResponse(errorMessage: "The data couldn’t be read because it is missing."))
        }
    }

    func testFetchGetAsync_handlesBadRequestError() async throws {
        setupMockResponse(statusCode: 400)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.badRequest))
        }
    }

    func testFetchGetAsync_handlesUnauthorizedError() async throws {
        setupMockResponse(statusCode: 401)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.unauthorized))
        }
    }

    func testFetchGetAsync_handlesForbiddenError() async throws {
        setupMockResponse(statusCode: 403)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.forbidden))
        }
    }

    func testFetchGetAsync_handlesNotFoundError() async throws {
        setupMockResponse(statusCode: 404)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.notFound))
        }
    }

    func testFetchGetAsync_handlesServerError() async throws {
        setupMockResponse(statusCode: 500)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.serverError))
        }
    }

    func testFetchGetAsync_handlesUnknownError() async throws {
        setupMockResponse(statusCode: 600)
        do {
            _ = try await networkManager.fetch(
                api: MockAPI.endpoint,
                method: .get(),
                request: request
            )
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail()
                return
            }
            XCTAssertEqual(apiError, .httpError(.unknown))
        }
    }
}

extension NetworkManagerTests {
    private func setupMockResponse(statusCode: Int? = nil, data: Data = Data()) {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                XCTFail("Request URL is nil")
                return (HTTPURLResponse(), Data())
            }

            if let statusCode = statusCode,
               let response = HTTPURLResponse(
                   url: url,
                   statusCode: statusCode,
                   httpVersion: nil,
                   headerFields: [:]
               )
            {
                return (response, data)
            } else {
                let response = HTTPURLResponse()
                return (response, data)
            }
        }
    }
}
