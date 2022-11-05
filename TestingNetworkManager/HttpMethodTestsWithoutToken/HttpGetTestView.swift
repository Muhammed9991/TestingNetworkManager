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
// For: https://dummyjson.com/products/1
struct Welcome: Codable {
    let id: Int
    let title, welcomeDescription: String
    let price: Int
    let discountPercentage, rating: Double
    let stock: Int
    let brand, category: String
    let thumbnail: String
    let images: [String]

    enum CodingKeys: String, CodingKey {
        case id, title
        case welcomeDescription = "description"
        case price, discountPercentage, rating, stock, brand, category, thumbnail, images
    }
}

struct HttpGetTestView: View {
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
                var data: Welcome
                
                (data, _ ) = try await NetworkManager.shared.get(with: "https://dummyjson.com/products/1")
                let _ = print("data.id:", data.id)
                let _ = print("data.title:", data.title)
                let _ = print("data.price:", data.price)
                let _ = print("data.discountPercentage:", data.discountPercentage)
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
