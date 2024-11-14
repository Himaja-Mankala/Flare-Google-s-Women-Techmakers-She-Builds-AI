//
//  Color Palette.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

//create colors: RGB values
extension Color {
    //pink shades
    static let amaranthPurple: Color = Color(red: 171/255, green: 39/255 , blue: 79/255)
    static let magentaPantone: Color = Color(red: 208/255, green: 55/255 , blue: 126/255)
    static let telemagenta: Color = Color(red: 207/255, green: 52/255 , blue: 118/255)
    static let thulianPink: Color = Color(red: 222/255, green: 111/255 , blue: 161/255)
    static let sweetly: Color = Color(red: 255/255, green: 229/255 , blue: 239/255)
    
    //white shades
    static let babyPowder: Color = Color(red: 254/255, green: 254/255 , blue: 250/255)
    
    //blue shades
    static let spaceCadet: Color = Color(red: 26/255, green: 28/255 ,blue: 56/255)
    static let marianBlue: Color = Color(red: 54/255, green: 68/255 ,blue: 115/255)
}

//design gradient
struct GradientBackground : ViewModifier {
    func body(content: Content) -> some View {
        
        content
            .background(LinearGradient(gradient: Gradient(colors: [Color.marianBlue, Color.spaceCadet]), startPoint: .bottomTrailing, endPoint: .top))
            .edgesIgnoringSafeArea(.bottom)
    }
}

//create function to call gradient
extension View {
    func applyGradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
}

//preview gradient
struct Color_Palette: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .foregroundColor(.clear)
                .frame(width: Dimensions.width, height: Dimensions.height)
            .scaledToFill()
        }
        .applyGradientBackground()
    }
}

#Preview {
    Color_Palette()
}
