//
//  Calista_appApp.swift
//  Calista-app
//
//  Created by Badr El malki berrada on 8/5/24.
//

import SwiftUI
import SwiftData
import CoreData

@main
struct Calista_appApp: App {
    @State private var showSplashScreen = true

    // Add the persistent container for Core Data
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplashScreen {
                    SplashScreenView()
                        .onAppear {
                            // Simulate a delay of 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    self.showSplashScreen = false
                                }
                            }
                        }
                } else {
                    ContentView()
                        .environment(\.managedObjectContext, persistentContainer.viewContext) // Inject Core Data context
                }
            }
        }
    }
}
