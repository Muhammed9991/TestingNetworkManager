//
//  HttpGetTestView.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import SwiftUI
/**
 
 THIS SEEMS TO BE WORKING FINE!!!!
 
 */
// For: http://127.0.0.1:8000/posts/1
struct Post: Codable {
    let title, content: String
    let published: Bool
    let id: Int
    let createdAt: String
    let ownerID: Int
    let owner: Owner

    enum CodingKeys: String, CodingKey {
        case title, content, published, id
        case createdAt = "created_at"
        case ownerID = "owner_id"
        case owner
    }
}

struct Owner: Codable {
    let id: Int
    let email, createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, email
        case createdAt = "created_at"
    }
}

struct HttpGetTestView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var id: Int = 1
    @State private var createdAt: String = ""
    
    
    var body: some View {
        VStack {
                
            Text(title)
                .font(.title)
                .padding()
            VStack{
                Text(content)
                Text(createdAt)
            }
            
            Spacer()
            
        }
        .padding()
        .task {
            do {
                let data: Post = try await NetworkManager.shared.get(
                    with: PostApi.getSinglePost(userID: 1).path
                )
                title = data.title
                content = data.content
                id = data.id
                
                let _ = print("------------------------------------------")
                let _ = print("Complete Data Object:", data)
                let _ = print("------------------------------------------")
                title = "User with the id \(data.id) just published"
                content = data.content
                createdAt = data.createdAt
               
            } catch ServerError.missingToken {
                title = "ERROR: \(ServerError.missingToken)"
            } catch {
                title = "ERROR: \(error)"
            }
        }
    }
}

struct HttpGetTestView_Previews: PreviewProvider {
    static var previews: some View {
        HttpGetTestView()
    }
}
