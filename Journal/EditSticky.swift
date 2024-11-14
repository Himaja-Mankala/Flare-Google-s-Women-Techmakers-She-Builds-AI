//
//  EditSticky.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI

struct EditSticky: View {
    @State private var tabSelection = 1 // Track selected tab (1 for My Note, 2 for Gemini AI)
    @State private var originalMessage: String
    @State private var aiOriginalResponse: String?
    @Binding var editedMessage: String
    @Binding var isFilled: Bool
    @Binding var showEditSticky: Bool
    @Binding var aiResponse: String?
    let stickyDate: String
    var onSave: () -> Void
    
    // Initialize Sticky from Journal to EditSticky
    init(editedMessage: Binding<String>, isFilled: Binding<Bool>, showEditSticky: Binding<Bool>, stickyDate: String, aiResponse: Binding<String?>, onSave: @escaping () -> Void) {
        self._editedMessage = editedMessage
        self._isFilled = isFilled
        self._showEditSticky = showEditSticky
        self.stickyDate = stickyDate
        self._aiResponse = aiResponse
        self.onSave = onSave
        _originalMessage = State(initialValue: editedMessage.wrappedValue)
        _aiOriginalResponse = State(initialValue: aiResponse.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                // Sticky UI View
                ZStack(alignment: .topLeading) {
                    // TextField UI View with conditional binding based on the selected tab
                    TextField(
                        isFilled ? "AI Analysis:" : "Enter your note",
                        text: Binding(
                            get: {
                                // Toggle between user input and AI response based on selected tab
                                tabSelection == 1 ? editedMessage : (aiResponse ?? "")
                            },
                            set: { newValue in
                                // Update the correct variable based on the selected tab
                                if tabSelection == 1 {
                                    editedMessage = newValue // Update user input
                                } else {
                                    aiResponse = newValue // Update AI response
                                }
                            }
                        ),
                        axis: .vertical
                    )
                    .font(.headline)
                    .foregroundColor(isFilled ? .babyPowder : .black)
                    .padding()
                    .frame(width: Dimensions.width * 0.90, height: Dimensions.height * 0.42)
                    .background(isFilled ? Color.black : Color.thulianPink)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 5)
                    .multilineTextAlignment(.center)
                    .lineLimit(12)
                    
                    // Date on top-left corner of sticky
                    Text(stickyDate)
                        .font(.headline)
                        .foregroundColor(isFilled ? .thulianPink : .babyPowder)
                        .padding([.top, .leading], 10)
                }
                .padding(.top)
                
                // Tab navigation bar to toggle between "My Note" and "Gemini AI"
                VStack {
                    Rectangle()
                        .frame(width: Dimensions.width, height: Dimensions.height * 0.05)
                        .foregroundColor(.clear)
                    TabView(selection: $tabSelection) {
                        Text("My Note")
                            .tag(1)
                        
                        Text("Gemini AI")
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) {
                        Journal_Navigation_Bar(tabSelection: $tabSelection)
                    }
                }
                
                // White TextBox UI View for input (this will reflect the content based on the tab)
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundColor(Color.babyPowder)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    TextField(
                        isFilled ? "AI Analysis" : "Enter your note",
                        text: Binding(
                            get: {
                                // Toggle between the user input and AI response
                                tabSelection == 1 ? editedMessage : (aiResponse ?? "")
                            },
                            set: { newValue in
                                if tabSelection == 1 {
                                    editedMessage = newValue // Update user note
                                } else {
                                    aiResponse = newValue // Update AI response
                                }
                            }
                        ),
                        axis: .vertical
                    )
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Color.babyPowder)
                    .frame(width: Dimensions.width - 30, height: 250, alignment: .topLeading)
                    .cornerRadius(15)
                }
                .padding()
            }
            .applyGradientBackground()
            .toolbar {
                // Cancel button to dismiss the edit view
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        editedMessage = originalMessage
                        aiResponse = aiOriginalResponse
                        showEditSticky = false
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.babyPowder)
                            .font(Font.system(size: 20))
                    }
                }

                // Save button, enabled only if the message has changed
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .padding()
                            .frame(maxHeight: 40)
                            .background(isSaveButtonEnabled ? Color.magentaPantone : Color.gray)
                            .foregroundColor(.babyPowder)
                            .cornerRadius(50)
                    }
                    .disabled(!isSaveButtonEnabled)
                }
            }
            .onAppear {
                // Set the tab to Gemini AI (tabSelection = 2) if isFilled is true
                if isFilled {
                    tabSelection = 2
                }
            }
            .onChange(of: tabSelection) {oldValue, newValue in
                // Sync isFilled state with tab selection
                isFilled = (newValue == 2) // Set isFilled to true if Gemini AI tab is selected, false for My Note
            }
        }
    }
    
    // Save button enable condition
    private var isSaveButtonEnabled: Bool {
        !editedMessage.isEmpty && editedMessage != originalMessage
    }
}

#Preview {
    Journal()
}
