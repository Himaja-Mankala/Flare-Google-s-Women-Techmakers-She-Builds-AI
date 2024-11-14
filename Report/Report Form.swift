//
//  Report Form.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import SwiftUI
import Combine
import MapKit

//Alert Model
struct Alert: Identifiable, Equatable, Encodable, Decodable{
    var id = UUID()
    let title: String
    let description: String
    let location: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    
    init(title: String, description: String, location: String, timestamp: Date, latitude: Double, longitude: Double, id: UUID? = nil) {
            self.id = id ?? UUID()
            self.title = title
            self.description = description
            self.location = location
            self.timestamp = timestamp
            self.latitude = latitude
            self.longitude = longitude
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case description
            case location
            case timestamp
            case latitude
            case longitude
        }
}

//Alert Row: list view for displaying individual alerts
struct AlertRow: View {
    let alert: Alert
    let onTap: () -> Void
    var body: some View {
        Button(action:{
            onTap()
        }){
            HStack{
                //Alert Formatting: title, description, location, timestamp
                VStack(alignment: .leading, spacing: 5){
                    Text(alert.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(alert.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Text(alert.location)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Text(relativeTime(from: alert.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(Color.sweetly)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
    
    //Date Formatting: date and time for beyond 24H
    private var dateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    //Time Display: Calculates difference between date-time and current-time
    private func relativeTime(from date: Date) -> String{
        let seconds = Int(Date().timeIntervalSince(date))
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if seconds < 60 {
            return "Just now" //less than a minute
        } else if minutes < 60 {
            return "\(minutes) minute\(minutes > 1 ? "s" : "") ago" //less than an hour
        } else if hours < 24 {
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"//less than a day
        } else {
            return dateFormatter.string(from: date)//more than a day
        }
    }
}


//Report Input: enter report form details
struct ReportInput: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var description: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var useCustomDate: Bool = false
    @State private var selectedDate: Date
    let existingTimestamp: Date
    let onSubmit: (String, String, String, Date, Double, Double) -> Void
    
    init(title: String,
         description: String,
         location: String,
         existingTimestamp: Date,
         latitude: Double,
         longitude: Double,
         onSubmit: @escaping (String, String, String, Date, Double, Double) -> Void
    ){
        self._title = State(initialValue: title)
        self._description = State(initialValue: description)
        self._location = State(initialValue: location)
        self._selectedDate = State(initialValue: existingTimestamp)
        self.existingTimestamp = existingTimestamp
        self._latitude = State(initialValue: latitude)
        self._longitude = State(initialValue: longitude)
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Report Details")){
                    TextField("Incident Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Location", text: $location)
                        .disabled(true)
                    Toggle("Select Custom Date and Time", isOn: $useCustomDate)
                    
                    if useCustomDate{
                        DatePicker(
                            "Incident Date and Time",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                }
            }
            .navigationBarTitle("Create Report", displayMode: .inline)
            .navigationBarItems(trailing: Button("Submit"){
                let finalTimestamp = useCustomDate ? selectedDate : existingTimestamp
                onSubmit(title, description, location, finalTimestamp, latitude, longitude)
                presentationMode.wrappedValue.dismiss()
            }
                .disabled(!isFormValid)
                .foregroundColor(isFormValid ? .blue : .gray)
            )
        }
    }
    
    //Form Valid: checks if textfields are filled
    private var isFormValid: Bool{
        !title.isEmpty && !description.isEmpty && !location.isEmpty
    }
}

//Report Details: displays submitted report form details
struct ReportDetail: View {
    @Environment(\.presentationMode) var presentationMode
    let alert: Alert
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Alert Details")){
                    Text("Title: \(alert.title)")
                    Text("Description: \(alert.description)")
                    Text("Location: \(alert.location)")
                    Text("Timestamp: \(dateFormatter.string(from: alert.timestamp))")
                }
            }
            .navigationBarTitle("Notification Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close"){
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var dateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}


//Main View: see alert list and alert details
struct Report_Form: View {
    @Binding var alerts: [Alert]
    @Binding var selectedAlert: Alert?
    @Binding var showDetailSheet: Bool
    @State private var showMapDetail = false
    @State private var timer: AnyCancellable?
    @State private var mapSelection: MKMapItem? = nil
    @Binding var locationAlerts: [Alert]
    var body: some View {
        VStack{
            ScrollView{
                VStack(spacing: 10){
                    ForEach(locationAlerts.sorted(by: {$0.timestamp > $1.timestamp})){alert in
                        AlertRow(alert: alert){
                            selectedAlert = alert
                            showDetailSheet = true
                        }
                    }
                }
            }
            .refreshable {
                updateTimestamps()
            }
        }
        .onAppear(perform: loadInitialData)
        .onDisappear(perform: stopTimer)

    }
    
    //Create New Report: insert at the top of alerts list
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
    
    //Update Timestamps: refreshes alerts array to update timestamps
    //New Alert object created for each alert in alerts array
    private func updateTimestamps(){
        alerts = alerts.map{alert in
            Alert(title: alert.title,
                  description: alert.description,
                  location: alert.location,
                  timestamp: alert.timestamp,
                  latitude: alert.latitude,
                  longitude: alert.longitude)
            
        }
    }
    
    //Start Timer: updates at regular intervals (0.1 seconds)
    private func startTimer(){
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink{ _ in
                self.updateTimestamps()
            }
    }
    
    //Stop Timer: stops a running timer
    private func stopTimer(){
        timer?.cancel()
        timer = nil
    }
    
    //Load Initial Data: mock data for UI demonstration
    private func loadInitialData(){
        alerts = AlertStorage.loadAlerts()
        startTimer()
    }
    
}

#Preview {
    MapView(showFullScreenMap: .constant(false))
}
