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
    private var mockStoreVersion = "99.0.0"
    
    init() {
            // Listen for when app becomes active (user returns from App Store)
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                // Re-check for updates when user returns to the app
                Task {
                    try? await Task.sleep(nanoseconds: 10_000_000_000)
                    await self.checkForUpdate()
                }
            }
        }
    
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
            
            //for testing:
//            if mockStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
//                    showUpdateAlert = true
//            }
            
            //for production:
            if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                    showUpdateAlert = true
            }
            
        } catch {
        }
    }
    
    func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6747049894") {
            UIApplication.shared.open(url)
            //test purpose: mock user has updated after returning from app store.
            //mockStoreVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        }
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
}

