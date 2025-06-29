import SwiftUI

@MainActor
class AppUpdateChecker: ObservableObject {
    @Published var showUpdateAlert = false
    @Published var latestVersion: String = ""

    private var trackId: Int?

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

            latestVersion = storeVersion
            trackId = info["trackId"] as? Int

            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
            if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                showUpdateAlert = true
            }
        } catch {
            // Ignore errors silently
        }
    }

    func openAppStore() {
        guard let trackId = trackId,
              let url = URL(string: "itms-apps://itunes.apple.com/app/id\(trackId)") else { return }
        UIApplication.shared.open(url)
    }
}
