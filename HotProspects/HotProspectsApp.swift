//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Arkasha Zuev on 19.08.2021.
//

import SwiftUI

@main
struct HotProspectsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
