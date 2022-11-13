//
//  CustomLoginScreen.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 05/11/2022.
//

import SwiftUI

/*
 TODO: Add REGEX to see if email in correct format (disable button if not
 TODO: If login button pressed and either username or password not filled then disable button
 
 Only do this when above is done.
 TODO: network request to get JWT token and save this inside keychain
 "username": "hello@gmail.com",
 "password": "12345"
 */

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct CustomLoginScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var authenticationDidFail: Bool = false
    @State private var authenticationDidSucceed: Bool = false
    @FocusState private var dimissKeyboard: Bool
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    WelcomeText()
                    UserImage()
                    
                    UsernameTextField(username: $username, dismissKeyboard: $dimissKeyboard)
                    PasswordSecureField(password: $password, dismissKeyboard: $dimissKeyboard)
                    
                    if authenticationDidFail {
                        Text("Information not correct. Try again.")
                            .offset(y: -10)
                            .foregroundColor(.red)
                    }
                    
                    
                    NavigationLink(destination: HttpGetTestView(), isActive: $authenticationDidSucceed) {
                        EmptyView()
                    }
                    
                    Button {
                        print("Login Button tapped")
                        Task {
                            do {
                                let accessToken = try await NetworkManager.shared.login(
                                    with: LoginApi.logIn.path,
                                    with: [
                                        "username": "hello@gmail.com",
                                        "password": "12345"
                                    ]
                                )
                                
                                username = "hello@gmail.com"
                                password = "12345"
                                authenticationDidSucceed = true
                                let _ = print("token: ", accessToken)
                                let _ = print("username: ", username)
                                let _ = print("password: ", password)
                                
                                let accessTokenData = Data(accessToken.utf8)
                                
                                try await AuthManager.shared.saveToken(item: accessTokenData, service: "access-token", account: "app")
                        
                            } catch {
                                authenticationDidFail = true
                                print("ERROR:", error)
                            }
                        }
                        dimissKeyboard = false
                    } label: {
                        LoginButtonContent()
                    }
                }
                .padding()
                
                if authenticationDidSucceed {
                    LoginSucceededPopUp()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done") {
                        dimissKeyboard = false
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CustomLoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomLoginScreen()
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image("Apple_logo_black")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
        
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct UsernameTextField: View {
    @Binding var username: String
    var dismissKeyboard: FocusState<Bool>.Binding
    
    var body: some View {
        TextField("Username", text: $username)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
            .focused(dismissKeyboard)
    }
}

struct PasswordSecureField: View {
    @Binding var password: String
    var dismissKeyboard: FocusState<Bool>.Binding
    
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
            .focused(dismissKeyboard)
    }
}

struct LoginSucceededPopUp: View {
    var body: some View {
        Text("Login succeeded!")
            .font(.headline)
            .frame(width: 250, height: 80)
            .background(Color.green)
            .cornerRadius(20.0)
            .foregroundColor(.white)
            .animation(.easeIn(duration: 2), value: 1.0)
    }
}
