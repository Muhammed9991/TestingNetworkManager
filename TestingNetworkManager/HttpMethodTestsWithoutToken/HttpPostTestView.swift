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

// POST URL: http://127.0.0.1:8000/posts

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
                    "title": "Post Created in Xcode",
                    "content": "content of Xcode Post"
                ]
                let response = try await NetworkManager.shared.post(
                    with: PostApi.createPost.path,
                    with: parameters
                )
                
                let _ = print("response: ", response)
               
            } catch {
                print("ERROR: ",error)
            }
        }
    }
}

struct HttpPostTestView_Previews: PreviewProvider {
    static var previews: some View {
        HttpPostTestView()
    }
}
