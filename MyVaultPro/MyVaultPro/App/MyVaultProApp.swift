//
//  MyVaultProApp.swift
//  MyVaultPro
//
//  SwiftUI app entry point. Wires up Core Data, settings,
//  and the splash → onboarding → main flow.
//

import SwiftUI

@main
struct MyVaultProApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var store: DataStore

    init() {
        let persistence = PersistenceController.shared
        SampleData.seedIfNeeded(in: persistence.viewContext)
        _store = StateObject(wrappedValue: DataStore(context: persistence.viewContext))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(store)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .preferredColorScheme(settings.appTheme.colorScheme)
                .tint(Theme.accent)
        }
    }
}
