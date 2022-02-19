//
//  Main+CoreData.swift
//  Sora
//
//  Created by Anton Heestand on 2022-01-21.
//  Copyright © 2022 Hexagons. All rights reserved.
//

import Foundation
import CoreData

extension Main {
    
    // MARK: - Setup
    
    func setupCoreData() {
        setupPersistentContainer()
    }
    
    func setupPersistentContainer() {
        let container = NSPersistentCloudKitContainer(name: "Sora")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainer = container
    }
    
    // MARK: - Save
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Delete
    
    func delete(soraGradient: SoraGradient) {
        #warning("Find Last Sora Gradient")
        lastSoraGradient = nil
        context.delete(soraGradient)
        try? context.save()
    }
    
    #if DEBUG
    func deleteAllData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SoraGradient")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            print("ALL DATA DELETED")
        } catch {
            print("Delete all data error :", error)
        }
    }
    #endif
}
