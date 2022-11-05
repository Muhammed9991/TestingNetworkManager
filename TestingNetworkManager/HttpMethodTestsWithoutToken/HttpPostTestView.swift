//
//  HttpPostTestView.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import SwiftUI

/*
 SEEMS TO BE WORKING!!!!
 */

// POST URL: https://jsonplaceholder.typicode.com/posts

struct HttpPostTestView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                let parameters: [String: Any] = [
                    "userId": 1,
                    "id": 1,
                    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                    "body": "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
                ]
                let data = try await NetworkManager.shared.post(with: "https://jsonplaceholder.typicode.com/posts", with: parameters)
                
                let _ = print("Data Response Object", data)

               
            } catch {
                print(error)
            }
        }
    }
}

struct HttpPostTestView_Previews: PreviewProvider {
    static var previews: some View {
        HttpPostTestView()
    }
}
