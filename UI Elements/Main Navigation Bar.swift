//
//  Main Navigation Bar.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

//create main navigation bar, icons, animation
struct Main_Navigation_Bar: View {
    @Binding var bottomTabSelection: Int
    @Namespace private var animationNamespace
    
    //populate tuple with SF image icons
    let bottomTabItems : [(image: String, title: String)] = [
    ("book.pages.fill", ""),
    ("flag.fill", ""),
    ]
    
    var body: some View {
        VStack{
            ZStack{
                //create main navigation bar
                Rectangle()
                    .frame(width: Dimensions.width + 10, height: 83)
                    .foregroundColor(.telemagenta)
                    .shadow(radius: 10)
                
                //create icon buttons
                HStack(spacing: 180){
                    ForEach(0..<bottomTabItems.count, id: \.self){index in
                        Button{
                            bottomTabSelection = index + 1
                        }
                    label: {
                        VStack(spacing: 25){
                            HStack{
                                Image(systemName: bottomTabItems[index].image)
                                    .font(Font.system(size: 28))
                                    .offset(y: 6)
                            }
                            //create animation
                            if index + 1 == bottomTabSelection{
                                Circle()
                                    .frame(height: 8)
                                    .matchedGeometryEffect(id: "SelectedBottomTabID", in: animationNamespace)
                                    .offset(y: -8)
                            } else{
                                Circle()
                                    .frame(height: 8)
                                    .foregroundColor(.clear)
                                    .offset(y: -3)
                            }
                        }
                        .foregroundColor(index + 1 == bottomTabSelection ? .babyPowder: .thulianPink) //selected button color scheme
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
