//
//  AuthManager.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import Foundation

enum KeychainError: Error {
    // Attempted read for an item that does not exist.
    case itemNotFound
    
    // Attempted save to override an existing item.
    // Use update instead of save to update existing items
    case duplicateItem
    
    // A read of an item in any format other than Data
    case invalidItemFormat
    
    // Any operation result status than errSecSuccess
    case unexpectedStatus(OSStatus)
}

actor AuthManager {
    typealias Token = String
    static let shared = AuthManager()
    private init() {}
    
    private var username: String?
    private var password: String?
    
    func getCurrentToken() async throws -> Token {
        let tokenAsData = try await getToken(service: "access-token", account: "app")
        let currentToken = String(data: tokenAsData, encoding: .utf8)

        if let currentToken {
            return currentToken
        } else {
            throw ServerError.invalidAuthToken
        }
    }

    func saveToken(item: Data, service: String, account: String) async throws {
        
        let query: [String: AnyObject] = [
            
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: item as AnyObject
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        if status == errSecDuplicateItem {
            try await updateToken(item: item, service: service, account: account)
        } else if  status == errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func updateToken(item: Data, service: String, account: String) async throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: item as AnyObject
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func getToken(service: String, account: String) async throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let password = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return password
    }
    
    func deleteToken(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func refreshToken() async throws -> Token {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> Token in
            defer { refreshTask = nil }
            
            // TODO: Make network request to get new token e.g.
            // return await networking.refreshToken(withRefreshToken: token.refreshToken)
            
            // Generating a dummy token
            let newToken = Token.init(isValid: true, value: "DummyToken")
            currentToken = newToken
            
            return newToken
        }
        
        self.refreshTask = task
        
        return try await task.value
    }
}


enum AuthError: Error {
    case missingToken
}
