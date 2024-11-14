//
//  Map.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetail = false
    @State private var alerts: [Alert] = AlertStorage.loadAlerts()
    @State private var selectedAlert: Alert?
    @State private var toggleHeatMap = false
    @Binding var showFullScreenMap: Bool
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            Annotation("My Location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue.opacity(0.25))

                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)

                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                }
            }

            ForEach(results, id: \.self) { item in
                let placemark = item.placemark
                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    .tint(Color.marianBlue)
            }

            if toggleHeatMap {
                ForEach(alerts, id: \.id) { alert in
                    Marker("", coordinate: CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude))
                        .tint(self.markerColor(alert: alert))
                }
            }
        }
        .overlay(alignment: .top) {
            VStack {
                HStack {
                    TextField("Search for a location", text: $searchText)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(20)
                        .padding()
                        .shadow(radius: 10)

                    if showFullScreenMap {
                        Button(action: {
                            showFullScreenMap.toggle()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.marianBlue)
                                .padding(.trailing)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                toggleHeatMap.toggle()
            }) {
                Image(systemName: toggleHeatMap ? "flag.slash" : "flag.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding()
                    .background(Circle().fill(Color.red).shadow(radius: 20))
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onSubmit(of: .text) {
            Task { await searchPlaces() }
        }
        .onChange(of: mapSelection) { _, newValue in
            showDetail = newValue != nil
        }
        .sheet(isPresented: $showDetail) {
            Map_Detail(mapSelection: $mapSelection, show: $showDetail, selectedAlert: $selectedAlert, alerts: $alerts)
                .presentationDetents([.height(340), .fraction(0.95)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        }
        .onChange(of: alerts) { _, newAlerts in
            AlertStorage.saveAlerts(alerts: newAlerts)
        }
        .mapControls {
            MapPitchToggle()
        }
    }

    private func markerColor(alert: Alert) -> Color {
        let calendar = Calendar.current
        let currentDate = Date()

        let components = calendar.dateComponents([.day], from: alert.timestamp, to: currentDate)
        guard let daysAgo = components.day else { return .gray }

        if daysAgo < 1 {
            return .red // Reported within day
        } else if daysAgo < 7 {
            return .orange // Reported within week
        } else if daysAgo < 30 {
            return .yellow // Reported within month
        } else if daysAgo < 90 {
            return .gray // Reported within three months
        } else {
            return .clear // More than three months ago
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

extension MapView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion

        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

#Preview {
    MapView(showFullScreenMap: .constant(false))
}
