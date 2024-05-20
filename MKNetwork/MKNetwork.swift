//
//  MKNetwork.swift
//  MKNetwork
//
//  Created by Mradul Kumar on 20/05/24.
//

import Foundation

public enum MKNetworkError: Error {
    case invalidURL
    case requestError(_ error: Error)
    case decodingError(_ error: DecodingError.Context)
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestError(let error): return "Request error: \(error.localizedDescription)"
        case .decodingError(let error): return "Decoding error: \(error.debugDescription)"
        }
    }
}

class MKNetwork {
    
}
