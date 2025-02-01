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

@main
struct CitizenshipTestApp: App{
    @StateObject private var selectedPart = SelectedPart()
    var body: some Scene {
        WindowGroup {
            CTInitialScreen()
                .environmentObject(selectedPart)
        }
    }
}
