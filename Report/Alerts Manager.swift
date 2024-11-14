//
//  Alerts Manager.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import Foundation
import CoreLocation

class AlertStorage {
    private static let alertsKey = "alertsKey"
    
    static func saveAlerts(alerts: [Alert]){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(alerts){
            UserDefaults.standard.set(encoded, forKey: alertsKey)
        }
    }
    
    static func loadAlerts() -> [Alert]{
        if let savedData = UserDefaults.standard.data(forKey: alertsKey),
           let decodedAlerts = try? JSONDecoder().decode([Alert].self, from: savedData){
            return decodedAlerts
        }
        return []
    }
}

