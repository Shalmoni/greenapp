//
//  greenappApp.swift
//  greenapp
//
//  Created by Otsar on 16/06/2025.
//

import SwiftUI

@main
struct greenappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
