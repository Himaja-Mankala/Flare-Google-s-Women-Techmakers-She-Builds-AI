//
//  Sticky.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

//Construct Sticky Note Pad
struct Sticky: View {
    @Binding var message: String // capture user input
    @Binding var isFilled: Bool
    @Binding var aiResponse: String?
    let date: String
    var onTap: () -> Void
    
    var body: some View {
        VStack{
            ZStack(alignment: .topLeading){
                //Sticky UI View
                Color(isFilled ? .black : .thulianPink)
                    .frame(width: Dimensions.width - 30, height: Dimensions.height * 0.42)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
                    .animation(.easeInOut(duration: 0.5), value: isFilled)
                    .onTapGesture {
                        onTap()
                    }
                
                //Text UI View
                VStack {
                    Spacer()
                    if isFilled{
                        TextField("AI Generated Note", text: Binding(get: {aiResponse ?? ""}, set: {aiResponse = $0}), axis: .vertical)
                            .font(.headline)
                            .foregroundColor(.babyPowder)
                            .padding()
                            .multilineTextAlignment(.center)
                            .lineLimit(12)
                            .truncationMode(.tail)
                            .disabled(true)
                    } else {
                        TextField("Enter your note", text: $message, axis: .vertical)
                            .font(.headline)
                            .foregroundColor(isFilled ? .babyPowder : .black)
                            .padding()
                            .multilineTextAlignment(.center)
                            .lineLimit(12)
                            .disabled(true) // prevents user from making edits on main page
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                //Date Arranged: top-left corner on sticky
                Text(date)
                    .font(.headline)
                    .foregroundColor(isFilled ? .thulianPink : .babyPowder)
                    .padding([.top, .leading], 10)
                
                //Button: swap personal sticky to AI sticky
                if !message.isEmpty {
                    Button(action: {
                        withAnimation {
                            isFilled.toggle()
                        }
                    }) {
                        Circle()
                            .fill(isFilled ? Color.thulianPink : Color.black)
                            .frame(width: 30, height: 30)
                            .overlay(isFilled ?
                                     Image(systemName: "doc.text")
                                        .foregroundColor(.babyPowder)
                                        .font(Font.system(size: 16)):
                            
                                    Image(systemName: "paintbrush")
                                        .foregroundColor(.babyPowder)
                                        .font(Font.system(size: 16))
                            )
                    }
                    .position(x: 335, y: 20)
                }
            
            }
        }
    }
}

#Preview {
    Journal()
}
