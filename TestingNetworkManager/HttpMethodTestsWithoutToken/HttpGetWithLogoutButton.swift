//
//  HttpGetWithLogoutButton.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 19/11/2022.
//

import SwiftUI

struct HttpGetWithLogoutButton: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var id: Int = 1
    @State private var createdAt: String = ""
    @Binding var authenticationDidSucceed: Bool
    
    
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
            
            Button {
                Task {
                    do {
                         let tokenLocation = "access-token"
                         let usernameLocation = "username"
                         let passwordLocation = "password"
                        
                        try await AuthManager.shared.deleteItemFromKeychain(service: tokenLocation)
                        try await AuthManager.shared.deleteItemFromKeychain(service: usernameLocation)
                        try await AuthManager.shared.deleteItemFromKeychain(service: passwordLocation)
                        let _ = print("------------------------------------------")

                        let _ = print("User succesfully logged out and details deleted from keychain")
                        let _ = print("------------------------------------------")

                    
                        authenticationDidSucceed = false
                
                    } catch {
                        print("Unable to Log out:", error)
                    }
                }
            } label: {
                GenericButton(buttonText: "LogOut")
            }

            
            
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

struct HttpGetWithLogoutButton_Previews: PreviewProvider {
    static var previews: some View {
        HttpGetWithLogoutButton(
            authenticationDidSucceed: .constant(true)
        )
    }
}
