//
//  NetworkManager.swift
//
//
//  Created by İhsan Akbay on 29.05.2024.
//

import Foundation

public final class NetworkManager: NetworkService {
    // MARK: - Properties

    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Methods

    /// async
    public func fetch<T: APIRequest>(
        api: any URLGenerator,
        method: HTTPMethod,
        request: T
    ) async throws -> T.ResponseDataType? {
        let urlRequest = try createURLRequest(api: api, method: method, request: request)
        let (data, response) = try await urlSession.data(for: urlRequest)
        let httpResponse = try handleResponse(data, response)
        try handleStatusCode(statusCode: httpResponse.statusCode)
        return httpResponse.statusCode == 204 ? nil : try parseData(data, for: request)
    }

    /// completion handler
    @discardableResult
    public func fetch<T: APIRequest>(
        api: URLGenerator,
        method: HTTPMethod,
        request: T,
        completionQueue: DispatchQueue,
        completionHandler: @escaping (APIResponse<T.ResponseDataType?>) -> Void
    ) -> URLSessionTask? {
        do {
            let urlRequest = try createURLRequest(
                api: api,
                method: method,
                request: request
            )
            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error {
                    self.completeOnQueue(
                        completionQueue,
                        with: .failure(.network(errorMessage: error.localizedDescription)),
                        completionHandler: completionHandler
                    )
                    return
                }

                if (response as? HTTPURLResponse)?.statusCode == 204 {
                    self.completeOnQueue(
                        completionQueue,
                        with: .success(nil),
                        completionHandler: completionHandler
                    )
                    return
                }

                guard let validData = data else {
                    self.completeOnQueue(
                        completionQueue,
                        with: .failure(.noData),
                        completionHandler: completionHandler
                    )
                    return
                }

                do {
                    let httpResponse = try self.handleResponse(validData, response)
                    try self.handleStatusCode(statusCode: httpResponse.statusCode)
                    if case .delete = method {
                        self.completeOnQueue(
                            completionQueue,
                            with: .success(nil),
                            completionHandler: completionHandler
                        )
                    } else {
                        let parsedResponse = try self.parseData(validData, for: request)
                        self.completeOnQueue(
                            completionQueue,
                            with: .success(parsedResponse),
                            completionHandler: completionHandler
                        )
                    }
                } catch let apiError as APIError {
                    self.completeOnQueue(
                        completionQueue,
                        with: .failure(apiError),
                        completionHandler: completionHandler
                    )
                } catch {
                    self.completeOnQueue(
                        completionQueue,
                        with: .failure(.unknown),
                        completionHandler: completionHandler
                    )
                }
            }
            task.resume()
            return task
        } catch let apiError as APIError {
            completeOnQueue(
                completionQueue,
                with: .failure(apiError),
                completionHandler: completionHandler
            )
            return nil
        } catch {
            completeOnQueue(
                completionQueue,
                with: .failure(.unknown),
                completionHandler: completionHandler
            )
            return nil
        }
    }

    // MARK: - Helpers

    private func createURLRequest<T: APIRequest>(api: URLGenerator, method: HTTPMethod, request: T) throws -> URLRequest {
        let urlRequest = try request.make(api: api, method: method)
        return urlRequest
    }

    private func handleResponse(_ data: Data, _ response: URLResponse?) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(data, response)
        }
        return httpResponse
    }

    private func parseData<T: APIRequest>(_ data: Data, for request: T) throws -> T.ResponseDataType {
        try request.parseResponse(data: data)
    }

    private func handleStatusCode(statusCode: Int) throws {
        switch statusCode {
        case 200 ..< 300:
            break
        case 400:
            throw APIError.httpError(.badRequest)
        case 401:
            throw APIError.httpError(.unauthorized)
        case 403:
            throw APIError.httpError(.forbidden)
        case 404:
            throw APIError.httpError(.notFound)
        case 500:
            throw APIError.httpError(.serverError)
        default:
            throw APIError.httpError(.unknown)
        }
    }

    private func completeOnQueue<T>(
        _ queue: DispatchQueue,
        with response: APIResponse<T>,
        completionHandler: @escaping (APIResponse<T>) -> Void
    ) {
        queue.async {
            completionHandler(response)
        }
    }
}
