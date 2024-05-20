//
//  MKHeaders.swift
//  MKNetwork
//
//  Created by Mradul Kumar on 20/05/24.
//

import Foundation

public struct MKHTTPHeaders: Hashable {
    private var headers: [MKHTTPHeader] = []
    
    /// Creates an empty instance.
    public init() {}
    
    public init(_ headers: [MKHTTPHeader]) {
        self.init()
        headers.forEach { update($0) }
    }
    
    /// Creates an instance from a  Dict
    public init(_ dictionary: [String: String]) {
        self.init()
        dictionary.forEach { update(MKHTTPHeader(name: $0.key, value: $0.value)) }
    }
    
    /// Add header value by key value
    public mutating func add(name: String, value: String) {
        update(MKHTTPHeader(name: name, value: value))
    }
    
    /// Add header
    public mutating func add(_ header: MKHTTPHeader) {
        update(header)
    }
    
    /// Update Header by key value
    public mutating func update(name: String, value: String) {
        update(MKHTTPHeader(name: name, value: value))
    }
    
    /// Update Header
    public mutating func update(_ header: MKHTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        headers.replaceSubrange(index...index, with: [header])
    }
    
    /// Remove a header value
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        headers.remove(at: index)
    }
    
    /// Sort the current instance by header name, case insensitively.
    public mutating func sort() {
        headers.sort { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    /// find a header's value by name
    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }
        return headers[index].value
    }
    
    /// Case-insensitively access the header with the given name.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }
    
    /// All headers in Dictionary Form
    public var convertedToDictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

extension Array where Element == MKHTTPHeader {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

public struct MKHTTPHeader: Hashable {
    /// Name of the header.
    public let name: String
    
    /// Value of the header.
    public let value: String
    
    /// Creates an instance from the given `name` and `value`.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension MKHTTPHeader: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}
