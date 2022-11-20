//
//  AsynGetImage.swift
//  TestingNetworkManager
//
//  Created by Muhammed Mahmood on 20/11/2022.
//

import SwiftUI

struct AsynGetImage: View {
    var body: some View {
        
        GetImage(
            urlString: "https://developer.apple.com/news/images/og/swiftui-og.png",
            errorPlaceHolder: Color.red,
            placeholder: Color.blue
        )
        .frame(width: 600, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

struct AsynGetImage_Previews: PreviewProvider {
    static var previews: some View {
        AsynGetImage()
    }
}


struct GetImage: View {
    let urlString: String
    let errorPlaceHolder: Color
    let placeholder: Color
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image.resizable() // Displays the loaded image.
            } else if phase.error != nil {
                errorPlaceHolder // Indicates an error.
            } else {
                placeholder // Acts as a placeholder.
            }
        }
    }
}
