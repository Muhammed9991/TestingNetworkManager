//
//  APIEndPoints.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import Foundation

enum LoginApi {
    case logIn
    
    var path: String {
        switch self {
        case .logIn:
            return "/login"
        }
    }
}

enum PostApi {
    case getSinglePost(userID: Int)
    case createPost
    
    var path: String {
        switch self {
        case .getSinglePost(userID: let userID):
            return "/posts/\(userID)"
        case .createPost:
            return "/posts"
            
        }
    }
}
