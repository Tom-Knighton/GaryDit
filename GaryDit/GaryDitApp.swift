//
//  GaryDitApp.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/06/2023.
//

import SwiftUI
import SwiftData

@main
struct GaryDitApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
