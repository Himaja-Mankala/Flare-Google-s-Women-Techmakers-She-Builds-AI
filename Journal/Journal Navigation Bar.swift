//
//  Journal Navigation Bar.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

struct Journal_Navigation_Bar: View {
    @Binding var tabSelection: Int
    
    let navigationBarItems : [(image: String, title: String )] = [
        ("doc.text","My Note"),
        ("paintbrush","Gemini AI")
        ]

    var body: some View {
        VStack{
            ZStack{
                Capsule()
                    .frame(width: Dimensions.width - 70, height: 40)
                    .foregroundColor(Color.marianBlue.opacity(0.8))
                    .shadow(radius: 10)
                
                HStack(spacing: 40){
                    ForEach(0..<2, id: \.self){index in
                        Button{
                            tabSelection = index + 1
                        }
                    label:{
                        VStack{
                            HStack {
                                Image(systemName: navigationBarItems[index].image)
                                    .font(Font.system(size: 22))
                                    .offset(y: 1)
                                
                                Text(navigationBarItems[index].title)
                                    .font(Font.system(size: 18))
                                    .fontWeight(.semibold)
                                    .offset(y: 2)
                            }
                        }
                        .foregroundColor(index + 1 == tabSelection ? .babyPowder:.gray)
                    }
                    }
                }
                .frame(height: 20)
            }
        }
    }
}

#Preview {
    Journal()
}
