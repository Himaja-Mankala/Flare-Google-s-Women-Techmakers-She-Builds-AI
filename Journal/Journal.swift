//
//  Journal.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

// Custom model to hold both user and AI sticky note data
struct StickyNote {
    var message: String
    var aiResponse: String?
    var isFilled: Bool
}

struct Journal: View {
    @State private var todayDate: Date = Date()
    @State private var stickies: [StickyNote] = Array(repeating: StickyNote(message: "", aiResponse: nil, isFilled: false), count: 30)
    @State private var currentIndex: Int?
    @State private var editedMessage: String = ""
    @State private var editedDate: String = ""
    @State private var showEditSticky: Bool = false
    @State private var draggedStickyIndex: Int? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var swipedAwayStickies: [StickyNote] = []
    @State private var submittedStickies: [(String, String)] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Title
                VStack {
                    Text("Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.magentaPantone)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Sticky Note Pad: drag, swipe, delete animations
                ZStack {
                    ForEach(stickies.indices, id: \.self) { index in
                        let date = getDate(for: index)
                        
                        Sticky(message: $stickies[index].message, isFilled: $stickies[index].isFilled, aiResponse: $stickies[index].aiResponse, date: date) {
                            currentIndex = index
                            editedMessage = stickies[index].message
                            editedDate = date
                            showEditSticky = true
                        }
                        .scaleEffect(draggedStickyIndex == index ? 1.05 : 1.0)
                        .offset(x: draggedStickyIndex == index ? dragOffset.width : 0)
                        .rotationEffect(Angle(degrees: draggedStickyIndex == index ? (dragOffset.width > 0 ? 1.8 : -1.8) : 0))
                        .gesture(DragGesture()
                            .onChanged { value in
                                if draggedStickyIndex == nil {
                                    draggedStickyIndex = index
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                if draggedStickyIndex == index {
                                    if value.translation.width < -250 || value.translation.width > 250 {
                                        // Swiped Away Action
                                        swipedAwayStickies.append(stickies[index])
                                        stickies.remove(at: index)
                                    } else {
                                        withAnimation(.interpolatingSpring(stiffness: 250, damping: 15)) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                                draggedStickyIndex = nil
                            }
                        )
                    }
                }
                .padding()
                
                Spacer()
                
                VStack {
                    // Undo Button
                    HStack {
                        Button(action: {
                            // Undo: Restore last swiped sticky and its corresponding AI sticky
                            if let lastSwipedSticky = swipedAwayStickies.popLast() {
                                stickies.append(lastSwipedSticky)
                            }
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(.babyPowder)
                                .fontWeight(.bold)
                            Text("undo")
                                .foregroundColor(.babyPowder)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
                    Spacer()
                    
                    // Submitted Stickies
                    ScrollView {
                        let groupedStickies = Dictionary(grouping: submittedStickies, by: { getMonth(for: $0.1) })
                        
                        ForEach(groupedStickies.keys.sorted(), id: \.self) { month in
                            HStack {
                                Text(month)
                                    .font(.title3)
                                    .foregroundColor(.babyPowder)
                                    .fontWeight(.semibold)
                                    .padding(.top)
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            ForEach(groupedStickies[month]!, id: \.1) { sticky in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(sticky.0)
                                            .foregroundColor(Color.babyPowder)
                                            .font(.headline)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        
                                        Text(sticky.1)
                                            .font(.caption)
                                            .foregroundColor(Color.thulianPink)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(height: 73)
                                .background(Color.spaceCadet.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y:5)
                                .padding(.horizontal)
                                .onTapGesture {
//                                    editedMessage = sticky.0
//                                    editedDate = sticky.1
//                                    currentIndex = nil
                                    showEditSticky = true
                                }
                            }
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
            .applyGradientBackground()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .fullScreenCover(isPresented: $showEditSticky) {
                EditSticky(editedMessage: $editedMessage, isFilled: $stickies[currentIndex ?? 0].isFilled, showEditSticky: $showEditSticky, stickyDate: editedDate, aiResponse: $stickies[currentIndex ?? 0].aiResponse) {
                    if let index = currentIndex {
                        // Update sticky message and AI response
                        stickies[index].message = editedMessage
                        let dateString = getDate(for: index)
                        
                        // Update submittedStickies with the new message
                        if let existingIndex = submittedStickies.firstIndex(where: { $0.1 == dateString }) {
                            submittedStickies[existingIndex].0 = editedMessage
                        } else {
                            submittedStickies.append((editedMessage, dateString))
                        }
                        
                        // Generate new AI response
                        GeminiText.geminiText.generateAnalysis(for: editedMessage) { aiSticky in
                            stickies[index].aiResponse = aiSticky
                            stickies[index].isFilled = true
                        }
                    }
                    showEditSticky = false
                }
            }
        }
    }
    
    private func getDate(for index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d yyyy"
        let pastDate = Calendar.current.date(byAdding: .day, value: -(29 - index), to: todayDate)
        return dateFormatter.string(from: pastDate ?? Date())
    }
    
    private func getMonth(for dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d yyyy"
        guard let date = dateFormatter.date(from: dateString) else { return "" }
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM yyyy"
        return monthFormatter.string(from: date)
    }
}


#Preview {
    Journal()
}
