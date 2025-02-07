//
//  CitizenshipTestApp.swift
//  CitizenshipTest
//
//  Created by Khang Tran on 1/18/25.
//

import SwiftUI
class SelectedPart: ObservableObject{
    @Published var partChosen: String = "Phần 1"
}

class DeviceManager: ObservableObject{
    @Published var isTablet: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    @StateObject private var deviceManager = DeviceManager()
    var body: some Scene {
        WindowGroup {
            CTInitialScreen()
                .environmentObject(selectedPart)
                .environmentObject(deviceManager)
        }
    }
}
