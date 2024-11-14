//
//  Report.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI
import MapKit

struct Report: View {
    @State private var showFullScreenMap = false
    @State private var offsetY: CGFloat = Dimensions.height * 0.51
    @State private var alerts: [Alert] = AlertStorage.loadAlerts()
    @State private var selectedAlert: Alert? = nil
    @State private var showDetailSheet: Bool = false
    @State private var aiAnalysisResult: String? = nil
    @State private var showAnalysisSheet: Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack {
                    HStack {
                        Text("Report")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.magentaPantone)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    MapView(showFullScreenMap: $showFullScreenMap)
                        .frame(height: geometry.size.height / 2.3)
                        .onTapGesture {
                            showFullScreenMap.toggle()
                        }
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
                .padding(.horizontal)
            }
            .fullScreenCover(isPresented: $showFullScreenMap) {
                MapView(showFullScreenMap: $showFullScreenMap)
            }
            
            BottomSheetView(
                offsetY: $offsetY,
                alerts: $alerts,
                selectedAlert: $selectedAlert,
                showDetailSheet: $showDetailSheet,
                aiAnalysisResult: $aiAnalysisResult,
                showAnalysisSheet: $showAnalysisSheet
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .applyGradientBackground()
        .sheet(isPresented: $showDetailSheet) {
                    if let alert = selectedAlert {
                        ReportDetail(alert: alert)
                    }
            }
        .onAppear {
            refreshAlerts()
        }
        .onDisappear(){
            refreshAlerts()
        }
    }
    private func refreshAlerts() {
            alerts = AlertStorage.loadAlerts()
    }
}


struct BottomSheetView: View {
    @Binding var offsetY: CGFloat
    let minHeight: CGFloat = Dimensions.height * 0.51
    let maxHeight: CGFloat = Dimensions.height * 0.93
    @Binding var alerts: [Alert]
    @Binding var selectedAlert: Alert?
    @Binding var showDetailSheet: Bool
    @Binding var aiAnalysisResult: String?
    @Binding var showAnalysisSheet: Bool
    @State private var isRefreshing: Bool = false
    @State private var isAnalyzing: Bool = false

    init(
        offsetY: Binding<CGFloat>,
        alerts: Binding<[Alert]>,
        selectedAlert: Binding<Alert?>,
        showDetailSheet: Binding<Bool>,
        aiAnalysisResult: Binding<String?>,
        showAnalysisSheet: Binding<Bool>
    ) {
        _offsetY = offsetY
        _alerts = alerts
        _selectedAlert = selectedAlert
        _showDetailSheet = showDetailSheet
        _aiAnalysisResult = aiAnalysisResult
        _showAnalysisSheet = showAnalysisSheet
    }

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(.top, 10)

            Button(action: {
                isAnalyzing = true
                print("Button pressed - Sending today's alerts to Gemini API.")
                
                let todayAlerts = AlertStorage.loadAlerts().filter { alert in
                    Calendar.current.isDateInToday(alert.timestamp)
                }
                print("Today's alerts count: \(todayAlerts.count)")

                let coordinates = todayAlerts.map { (latitude: $0.latitude, longitude: $0.longitude) }
                print("Coordinates being sent to Gemini: \(coordinates)")

                GeminiAnalysis.geminiAnalysis.generateAnalysis(for: coordinates) { analysis in
                    DispatchQueue.main.async {
                        aiAnalysisResult = analysis
                        isAnalyzing = false
                        showAnalysisSheet = true
                    }
                }
            }) {
                Text("Risk Analysis")
                    .frame(maxWidth: .infinity)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.magentaPantone)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(alerts.sorted(by: { $0.timestamp > $1.timestamp })) { alert in
                        AlertRow(alert: alert) {
                            selectedAlert = alert
                            showDetailSheet = true
                        }
                    }
                }
                .overlay(
                    Group {
                        if isAnalyzing {
                            ProgressView("Analyzing...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(2)
                                .padding()
                        }
                    }
                )
            }
            .padding(.bottom, 85)
            .padding(.top, 18)
            .refreshable {
                await refreshData()
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: offsetY)
        .background(getBackgroundColor())
        .cornerRadius(20)
        .shadow(radius: 5)
        .offset(y: Dimensions.height - offsetY)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let newOffset = offsetY - gesture.translation.height
                    if newOffset >= minHeight && newOffset <= maxHeight {
                        offsetY = newOffset
                    }
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        if offsetY > (minHeight + maxHeight) / 2 {
                            offsetY = maxHeight
                        } else {
                            offsetY = minHeight
                        }
                    }
                }
        )
        .animation(.spring(), value: offsetY)

        .sheet(isPresented: $showAnalysisSheet) {
            VStack {
                ScrollView {
                    Text("Gemini AI Analysis")
                        .font(.headline)
                        .padding()

                    if let analysis = aiAnalysisResult {
                        formattedText(analysis)
                            .padding()
                            .font(.body)
                            .foregroundColor(Color.magentaPantone)
                            .multilineTextAlignment(.leading)
                    }

                    Button(action: {
                        showAnalysisSheet = false
                    }) {
                        Text("Close")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.spaceCadet)
                    }
                }
                .background(Color.sweetly)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(15)
            .padding()
            }
        }
    }

    private func formattedText(_ text: String) -> Text {
        var result = Text("")
        
        // Handle bold text
        let parts = text.split(separator: "*")
        for (index, part) in parts.enumerated() {
            if index % 2 == 1 {
                result = result + Text(part).bold()
            } else {
                result = result + Text(part)
            }
        }

        return result
    }
    
    private func getBackgroundColor() -> Color {
        let percentage = (offsetY - minHeight) / (maxHeight - minHeight)
        let lightColor = UIColor(Color.marianBlue)
        let darkColor = UIColor(Color.spaceCadet)

        let red = (1 - percentage) * lightColor.cgColor.components![0] + percentage * darkColor.cgColor.components![0]
        let green = (1 - percentage) * lightColor.cgColor.components![1] + percentage * darkColor.cgColor.components![1]
        let blue = (1 - percentage) * lightColor.cgColor.components![2] + percentage * darkColor.cgColor.components![2]

        return Color(red: red, green: green, blue: blue)
    }

    private func refreshData() async {
        isRefreshing = true
        alerts = AlertStorage.loadAlerts()
        isRefreshing = false
    }
}

#Preview {
    Report()
}
