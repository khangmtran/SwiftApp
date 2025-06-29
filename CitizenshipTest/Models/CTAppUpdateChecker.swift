//
//  CTAppUpdateChecker.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 6/29/25.
//

import SwiftUI

@MainActor
class AppUpdateChecker: ObservableObject {
    @Published var showUpdateAlert = false
    
    private let lastShownKey = "lastUpdateAlertDate"

    func checkForUpdate() async {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]],
                let info = results.first,
                let storeVersion = info["version"] as? String
            else { return }
            
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

            if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                if shouldShowAlertToday() {
                    showUpdateAlert = true
                    updateLastAlertDate()
                }
            }
        } catch {
        }
    }
    
    private func shouldShowAlertToday() -> Bool {
        if let lastDate = UserDefaults.standard.object(forKey: lastShownKey) as? Date {
            let calendar = Calendar.current
            return !calendar.isDateInToday(lastDate)
        }
        return true
    }

    private func updateLastAlertDate() {
        UserDefaults.standard.set(Date(), forKey: lastShownKey)
    }
    
    func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6747049894") {
            UIApplication.shared.open(url)
        }
    }
}

