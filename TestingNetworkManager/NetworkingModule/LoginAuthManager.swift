//
//  LoginAuthManager.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 19/11/2022.
//

import Foundation

let readMe =
"""
Main responsilbilties of this Actor is to:
    - Store token in keychain
    - Store email address in keychain
    - Store password in keychain

Note: this is only ran once at login. Thats why this is in its own Actor.
"""

actor LoginAuthManager {
    static let shared = LoginAuthManager()
    private init() {}
    
    private var username: String?
    private var password: String?
    private var token: String?
    
    private let tokenLocation = "access-token"
    private let usernameLocation = "username"
    private let passwordLocation = "password"
    private let accountLocation = "network-app"
    
    func saveToken(_ item: Data) async throws {
        
        let query: [String: AnyObject] = [
            
            kSecAttrService as String: tokenLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: item as AnyObject,
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        if status != errSecSuccess {
            throw KeychainError.unexpectedStatusWithString(
                "ERROR: ",
                status,
                " Unable to store token in keychain"
            )
        }
    }
    
    func saveUsername(_ item: Data) async throws {
        
        let query: [String: AnyObject] = [
            
            kSecAttrService as String: usernameLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: item as AnyObject,
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        if status != errSecSuccess {
            throw KeychainError.unexpectedStatusWithString(
                "ERROR: ",
                status,
                " Unable to store username in keychain"
            )
        }
    }
    
    func savePassword(_ item: Data) async throws {
        
        let query: [String: AnyObject] = [
            
            kSecAttrService as String: passwordLocation as AnyObject,
            kSecAttrAccount as String: accountLocation as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: item as AnyObject,
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        if status != errSecSuccess {
            throw KeychainError.unexpectedStatusWithString(
                "ERROR: ",
                status,
                " Unable to store password in keychain"
            )
        }
    }
}
