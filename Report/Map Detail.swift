//
//  Map Detail.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI
import MapKit

struct Map_Detail: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @Binding var selectedAlert: Alert?
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var showCreateSheet = false
    @State private var showDetailSheet = false
    @State private var reportLocation = ""
    @State private var locationAlerts: [Alert] = []
    @Binding var alerts: [Alert]
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                Button{
                    show.toggle()
                    mapSelection = nil
                }label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.magentaPantone)
                }
            }
            
//            HStack {
//                            Button("Clear All Alerts") {
//                                alerts.removeAll()
//                            }
//                            .foregroundColor(.red)
//                            .padding()
//
//                        }
            
            if let scene = lookAroundScene{
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            HStack{
                Button{
                    reportLocation = mapSelection?.placemark.title ?? "Unknown Location"
                    showCreateSheet.toggle()
                }label: {
                    Text("Create Report")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.magentaPantone)
                        .cornerRadius(12)
                }
            }
            
            Report_Form(alerts: $alerts, selectedAlert: $selectedAlert, showDetailSheet: $showDetailSheet, locationAlerts: $locationAlerts)
        }
        .padding(.top)
        .padding(.horizontal)
        .ignoresSafeArea()
        .onAppear{
            fetchLookAroundPreview()
            reportLocation = mapSelection?.placemark.title ?? "Unknown Location"
            updateLocationAlerts()
        }
        .onChange(of: mapSelection){oldValue, newValue in
            fetchLookAroundPreview()
            reportLocation = mapSelection?.placemark.title ?? "Unknown Location"
            updateLocationAlerts()
        }
        .sheet(isPresented: $showCreateSheet){
            let latitude = mapSelection?.placemark.coordinate.latitude ?? 0.0
            let longitude = mapSelection?.placemark.coordinate.longitude ?? 0.0
            ReportInput(
                title: "",
                description: "",
                location: reportLocation,
                existingTimestamp: Date(),
                latitude: latitude,
                longitude: longitude,
                onSubmit: {title, description, location, timestamp, latitude, longitude in
                    createReport(title: title, description: description, location: location, timestamp: timestamp, latitude: latitude, longitude: longitude)
                    showCreateSheet = false
                    updateLocationAlerts()
                })
        }
        .sheet(isPresented: $showDetailSheet){
            if let alert = selectedAlert{
                ReportDetail(alert: alert)
            }
        }
        
    }
    
    private func createReport(title: String, description: String, location: String, timestamp: Date, latitude: Double, longitude: Double){
        let newReport = Alert(
            title: title,
            description: description,
            location: location,
            timestamp: timestamp,
            latitude: latitude,
            longitude: longitude
        )
        alerts.insert(newReport, at: 0)
        AlertStorage.saveAlerts(alerts: alerts)
    }
    
    private func updateLocationAlerts() {
           guard let selectedLocation = mapSelection?.placemark.title else {
               locationAlerts = []
               return
           }
           
           locationAlerts = alerts.filter { alert in
               alert.location.lowercased() == selectedLocation.lowercased()
           }
           .sorted { $0.timestamp > $1.timestamp }
       }
    
}

extension Map_Detail{
    func fetchLookAroundPreview(){
        if let mapSelection{
            lookAroundScene = nil
            Task{
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    MapView(showFullScreenMap: .constant(false))
}
