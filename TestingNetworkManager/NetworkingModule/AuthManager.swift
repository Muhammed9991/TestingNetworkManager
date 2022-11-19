//
//  AuthManager.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import Foundation

actor AuthManager {
    typealias Token = String
    typealias Parameters = [String: Any]
    static let shared = AuthManager()
    private init() {}
    
    private var username: String?
    private var password: String?
    private var token: [Token: LoaderStatus] = [:]
    
    private let tokenLocation = "access-token"
    private let usernameLocation = "username"
    private let passwordLocation = "password"
    private let accountLocation = "network-app"
    
    private enum LoaderStatus {
        case inProgress(Task<Token, Error>)
    }
    
    func getCurrentToken() async throws -> Token {
        let tokenAsData = try await getTokenFromKeychain()
        let currentToken = String(data: tokenAsData, encoding: .utf8)
        
        if let currentToken {
            return currentToken
        } else {
            throw ServerError.invalidAuthToken
        }
    }
    
    func getTokenFromKeychain() async throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: tokenLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
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
            throw ServerError.missingToken
        }
        
        guard status == errSecSuccess else {
            throw ServerError.generic
        }
        
        guard let token = itemCopy as? Data else {
            throw ServerError.missingToken
        }
        
        return token
    }
    
    func updateToken(item: Data) async throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: tokenLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
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
            throw ServerError.missingToken
        }
        
        guard status == errSecSuccess else {
            throw ServerError.generic
        }
    }
    
    func getUsernameFromKeychain() async throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: usernameLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
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
            throw ServerError.missingToken
        }
        
        guard status == errSecSuccess else {
            throw ServerError.generic
        }
        
        guard let username = itemCopy as? Data else {
            throw ServerError.missingToken
        }
        
        return username
    }
    
    func getPasswordFromKeychain() async throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: passwordLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
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
            throw ServerError.missingToken
        }
        
        guard status == errSecSuccess else {
            throw ServerError.generic
        }
        
        guard let password = itemCopy as? Data else {
            throw ServerError.missingToken
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
            throw ServerError.generic
        }
    }
    
    func getNewToken() async throws -> Token {
        let currentToken = ""
        if let status = token[currentToken] {
            switch status {
            case .inProgress(let task):
                /*
                 If we encounter an in-progress task, we await the task's
                 value to obtain the Token without creating a duplicate task
                 */
                return try await task.value
                
            }
        }
        
        let task: Task<Token, Error> = Task {
            let usernameData = try await getUsernameFromKeychain()
            let passwordData = try await getPasswordFromKeychain()
            
            let username = String(data: usernameData, encoding: .utf8)
            let password = String(data: passwordData, encoding: .utf8)
            
            guard let username, let password else {
                throw ServerError.missingToken
            }
            
            let token = try await NetworkManager.shared.login(username: username, password: password)
            let accessTokenData = Data(token.utf8)
            
            do {
                try await updateToken(item: accessTokenData)
                return token
                
            } catch {
                throw ServerError.missingToken
            }
        }
        
        token[currentToken] = .inProgress(task)
        
        let tokenFromTask = try await task.value
        
        return tokenFromTask
    }
}


enum AuthError: Error {
    case missingToken
}
