//
//  LuxHomeApp.swift
//  LuxHome
//
//  Created by RJ  Kigner on 12/18/25.
//

import SwiftUI
import CoreData

@main
struct LuxHomeApp: App {
    // let persistenceController = PersistenceController.shared
    let model = LuxHomeModel.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                // .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(model)
        }
    }
}
