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
    
    var body: some View {
        VStack {
            Text("User with the id \(id) just published")
                .font(.title)
                .padding()
            VStack{
                Text("Title: \(title)")
                Text("\(content)")
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
                let _ = print("data.title:", data.title)
                let _ = print("data.content:", data.content)
                let _ = print("data.id:", data.id)
                let _ = print("data.createdAt:", data.createdAt)
                let _ = print("Complete Data Object:", data)
               
            } catch {
                print(error)
            }
        }
    }
}

struct HttpGetTestView_Previews: PreviewProvider {
    static var previews: some View {
        HttpGetTestView()
    }
}
