//
//  NetworkManager.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import Foundation

/*
 Harcoding token for testing purposes
 */
let token = " "

enum ServerError: Error {
    case notFound
    case generic
    case invalidAuthToken
    case missingToken
}

protocol HTTPServiceProtocol {
    typealias Parameters = [String: Any]
    typealias Token = String
    
    func login(username: String, password: String) async throws -> Token
    
    func get<T: Decodable>(with urlString: String) async throws -> T
    func post(with urlString: String, with parameter: Parameters) async throws -> URLResponse
    func put(with urlString: String, with parameter: Parameters) async throws -> URLResponse
    func patch(with urlString: String, with parameter: Parameters) async throws -> URLResponse
    func delete(to urlString: String, with parameter: Parameters) async throws
    
    func authorizedRequest(from url: URL) async throws -> URLRequest
    
    func refreshTokenAndReTryGetRequest<T: Decodable>(with url: URL, currentToken: Token) async throws -> T
    func refreshTokenAndRetryPostRequest(with url: URL, with parameter: Parameters) async throws -> URLResponse
    func refreshTokenAndRetryPutRequest(with url: URL, with parameter: Parameters) async throws -> URLResponse
    func refreshTokenAndRetryPatchRequest(with url: URL, with parameter: Parameters) async throws -> URLResponse
    func refreshTokenAndReTryDeleteRequest(with url: URL) async throws
}

struct JwtTokenDTO: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class NetworkManager: HTTPServiceProtocol {
    
    static let shared = NetworkManager()
    let session = URLSession.shared
    typealias Parameters = [String: Any]
    typealias Token = String
    
    var baseURL: String {
        /*
         Hardcoding local host for now as no real API exists
         */
        #if DEBUG
        return "http://127.0.0.1:8000"
        #else
        return "http://127.0.0.1:8000"
        #endif
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
    
    func login(username: String, password: String) async throws -> Token {
        
        let parameter: [String: String] = [
            "username": username,
            "password": password
        ]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: baseURL + LoginApi.logIn.path)
        guard let url = url else { throw ServerError.notFound }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        for (key, value) in parameter {
            data.append(convertFormField(named: key, value: "\(value)", using: boundary).data(using: .utf8)!)
        }
        data.append("--\(boundary)--".data(using: .utf8)!)
        
        let (responseData , response) = try await session.upload(
            for: request,
            from: data
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case HTTPStatus.created.rawValue, HTTPStatus.okay.rawValue:
                break
            default:
                throw ServerError.notFound
            }
        }
        
        let returnJSON = try JSONDecoder().decode(JwtTokenDTO.self, from: responseData)
        return returnJSON.accessToken
    }
    
    func get<T: Decodable>(with urlString: String) async throws -> T {
        let url = URL(string: baseURL + urlString)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        
        let (data, response) = try await  session.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case HTTPStatus.okay.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                return try await refreshTokenAndReTryGetRequest(with: url, currentToken: "")
            default:
                throw ServerError.notFound
            }
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func post(with urlString: String, with parameter: Parameters) async throws -> URLResponse {
        let completeURL = baseURL + urlString
        let url = URL(string: completeURL)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        
        guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
        
        let (_ , response) = try await session.upload(
            for: urlRequest,
            from: data
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case HTTPStatus.created.rawValue, HTTPStatus.okay.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                return try await refreshTokenAndRetryPostRequest(with: url, with: parameter)
            default:
                throw ServerError.notFound
            }
        }
        
        return response
    }
    
    func put(with urlString: String, with parameter: Parameters) async throws -> URLResponse {
        let url = URL(string: baseURL + urlString)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
        
        let (_ , response) = try await session.upload(
            for: urlRequest,
            from: data
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case  HTTPStatus.okay.rawValue, HTTPStatus.created.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                return try await refreshTokenAndRetryPutRequest(with: url, with: parameter)
            default:
                throw ServerError.notFound
            }
        }
        
        return response
    }
    
    func patch(with urlString: String, with parameter: Parameters) async throws -> URLResponse {
        let url = URL(string: baseURL + urlString)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        
        guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
        
        let (_ , response) = try await session.upload(
            for: urlRequest,
            from: data
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case  HTTPStatus.okay.rawValue, HTTPStatus.created.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                return try await refreshTokenAndRetryPatchRequest(with: url, with: parameter)
            default:
                throw ServerError.notFound
            }
        }
        
        return response
    }
    
    func performUpdate(with method: HTTPMethod, with urlString: String, with parameter: Parameters) async throws -> URLResponse {
        let url = URL(string: baseURL + urlString)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = method.rawValue
        
        guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
        
        let (_ , response) = try await session.upload(
            for: urlRequest,
            from: data
        )
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case  HTTPStatus.okay.rawValue, HTTPStatus.created.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                return try await refreshTokenAndRetryPatchRequest(with: url, with: parameter)
            default:
                throw ServerError.notFound
            }
        }
        
        return response
    }
    
    func refreshTokenAndRetryUpdate(with method: HTTPMethod, with url: URL, with parameter: [String: Any]) async throws -> URLResponse {
        let token = try await AuthManager.shared.getNewToken()
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = method.rawValue
        guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
        
        let (_ , response) = try await session.upload(
            for: urlRequest,
            from: data
        )
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
        throw ServerError.invalidAuthToken
    }
    
    return response
    }
    
    func delete(to urlString: String, with parameter: [String: Any]) async throws {
        let url = URL(string: baseURL + urlString)
        guard let url = url else { throw ServerError.notFound }
        
        var urlRequest = try await authorizedRequest(from: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        
        let (_, response) = try await  session.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case HTTPStatus.okay.rawValue:
                break
            case HTTPStatus.unauthorized.rawValue:
                 try await refreshTokenAndReTryDeleteRequest(with: url)
            default:
                throw ServerError.notFound
            }
        }
    }
    
    func authorizedRequest(from url: URL) async throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        do {
            let token =  try await AuthManager.shared.getCurrentToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return urlRequest
            
        } catch {
            print("authorizedRequest ERROR: ", error)
            throw ServerError.missingToken
        }
    }
    
    func refreshTokenAndReTryGetRequest<T: Decodable>(with url: URL, currentToken: Token) async throws -> T {
        let token = try await AuthManager.shared.getNewToken()
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await  session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatus.okay.rawValue else {
            throw ServerError.invalidAuthToken
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func refreshTokenAndRetryPostRequest(with url: URL, with parameter: [String: Any]) async throws -> URLResponse {
        let token = try await AuthManager.shared.getNewToken()
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = HTTPMethod.post.rawValue
            guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
            
            let (_ , response) = try await session.upload(
                for: urlRequest,
                from: data
            )
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw ServerError.invalidAuthToken
        }
        
        return response
    }
    
    func refreshTokenAndRetryPutRequest(with url: URL, with parameter: [String: Any]) async throws -> URLResponse {
        let token = try await AuthManager.shared.getNewToken()
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = HTTPMethod.put.rawValue
            guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
            
            let (_ , response) = try await session.upload(
                for: urlRequest,
                from: data
            )
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw ServerError.invalidAuthToken
        }
        
        return response
    }
    
    func refreshTokenAndRetryPatchRequest(with url: URL, with parameter: [String: Any]) async throws -> URLResponse {
        let token = try await AuthManager.shared.getNewToken()
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = HTTPMethod.patch.rawValue
            guard let data = getParameterBody(with: parameter) else { throw ServerError.generic }
            
            let (_ , response) = try await session.upload(
                for: urlRequest,
                from: data
            )
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw ServerError.invalidAuthToken
        }
        
        return response
    }
    
    func refreshTokenAndReTryDeleteRequest(with url: URL) async throws {
        let token = try await AuthManager.shared.getNewToken()
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await  session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatus.okay.rawValue else {
            throw ServerError.invalidAuthToken
        }
    }
    
    func getParameterBody(with parameters: [String: Any]) -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        return httpBody
    }
    
}
