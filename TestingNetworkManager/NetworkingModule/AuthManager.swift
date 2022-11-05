//
//  AuthManager.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import Foundation

struct Token: Decodable {
    let isValid: Bool
    let value: String
    
}

actor AuthManager {
    private var currentToken: Token?  // Should be from keychain (just an example)
    private var refreshTask: Task<Token, Error>?
    
    func validToken() async throws -> Token {
        if let handle = refreshTask {
            return try await handle.value
        }
        
        guard let token = currentToken else {
            throw ServerError.missingToken
        }
        
        if token.isValid {
            return token
        }
        
        return try await refreshToken()
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
