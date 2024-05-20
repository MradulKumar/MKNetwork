//
//  MKNetwork.swift
//  MKNetwork
//
//  Created by Mradul Kumar on 20/05/24.
//

import Foundation
import UIKit

public enum MKNetworkError: Error {
    case invalidURL
    case invalidBodyParams
    case noResponse
    case requestError(_ error: Error)
    case decodingError(_ error: DecodingError.Context)
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidBodyParams: return "Invalid Body Parameters! JSON Serialisation Failed."
        case .noResponse: return "No Response."
        case .requestError(let error): return "Request error: \(error.localizedDescription)"
        case .decodingError(let error): return "Decoding error: \(error.debugDescription)"
        }
    }
}

public enum MKHTTPMethodType: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class MKNetwork {
    /// Shared singleton instance.
    public static var shared = MKNetwork()
    
    // Prevent  developers from creating their own instances by making the initializer `private`.
    private init() {}
}

private extension MKNetwork {
    
    func api<T: Codable>(urlRequest: URLRequest, completion: @escaping ((Swift.Result<T, Swift.Error>) -> Void)) {
        // Create a URLSession instance
        let session = URLSession.shared
        
        // Create a data task using URLSessionDataTask
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            // Handle the response
            
            // Check for errors
            if let error = error {
                completion(Swift.Result.failure(error))
                return
            }
            
            // Check if data is available
            guard let responseData = data else {
                completion(Swift.Result.failure(MKNetworkError.noResponse))
                return
            }
            
            // Process the received data
            do {
                let json = try JSONSerialization.data(withJSONObject: responseData, options: [])
                do {
                    let result = try JSONDecoder().decode(T.self, from: json)
                    print("Response Result: \\(result)")
                    completion(Swift.Result.success(result))
                } catch let error {
                    completion(Swift.Result.failure(error))
                }
            } catch let error {
                completion(Swift.Result.failure(error))
            }
        }
        dataTask.resume()
    }
    
    func createUrlRequest(with url: String, type: MKHTTPMethodType, headers: [String: String]?, body: [String: Any]? = nil) -> Result<URLRequest, MKNetworkError> {
        guard let apiUrl = URL(string: url) else { return Result.failure(MKNetworkError.invalidURL) }
        var urlRequest = URLRequest(url: apiUrl)
        urlRequest.httpMethod = type.rawValue
        var httpHeaders = getDefaultHeaders()
        if let headers = headers {
            for (key, value) in headers {
                httpHeaders.add(name: key, value: value)
            }
        }
        urlRequest.allHTTPHeaderFields = httpHeaders.convertedToDictionary
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        if let params = body {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return Result.failure(MKNetworkError.invalidBodyParams) }
            urlRequest.httpBody = httpBody
        }
        return Result.success(urlRequest)
    }
}

extension MKNetwork {
    
    func request<T: Codable>(with url: String, type: MKHTTPMethodType, headers: [String: String]?, body: [String: Any]? = nil, completion: @escaping ((Swift.Result<T, Swift.Error>) -> Void)) {
        let result = createUrlRequest(with: url, type: type, headers: headers, body: body)
        switch result {
        case .success(let request):
            self.api(urlRequest: request) { result in
                return completion(result)
            }
        case .failure(let failure):
            return completion(Result.failure(failure))
        }
    }
    
    func getDefaultUserAgent() -> String {
        let source = "iOS"
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let name = UIDevice.current.name
        let userAgent = "\(source) \(model) \(systemVersion) \(name)"
        return userAgent
    }
    
    func getDefaultHeaders() -> MKHTTPHeaders {
        var headers: MKHTTPHeaders = MKHTTPHeaders.init()
        
        //user agent
        let userAgent = getDefaultUserAgent()
        headers.add(name: "UserAgent", value: userAgent)
        
        return headers
    }
}
