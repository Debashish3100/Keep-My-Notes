//
//  CoreDataManager.swift
//  Note Demo
//
//  Created by Debashish Das on 21/09/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import CoreData
import UIKit

final class CoreDataManager {
    private let modelName: String
    
    //MARK: - Initializer
    
    init(modelName: String) {
        self.modelName = modelName
        setupNotificationHandling()
    }
    
    //MARK: - ManagedObjectContext
    
    //MARK: Parent ManagedObjectContext
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistantStoreCoordinator
        return context
    }()
    
    //MARK: Child ManagedObjectContext
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.privateManagedObjectContext
        return context
    }()
    
    //MARK: - ManagedObjectModel
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let dataModelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { fatalError("unable to find data model url") }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelUrl) else { fatalError("unable to find data model") }
        return dataModel
    }()
    
    //MARK: - PersistantStoreCoordinator
    
    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let documentsDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storeUrl =  documentsDirectoryUrl.appendingPathComponent(storeName)
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true,
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        } catch {
            fatalError("unable to add store")
        }
        return coordinator
    }()
    
    //MARK: - Save
    
    private func saveChanges() {
        mainManagedObjectContext.perform {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                print("saving error : child : - \(error.localizedDescription)")
            }
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                print("saving error : parent : - \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Helper Methods
    
    @objc func saveChanges(notificaiton: Notification) {
        saveChanges()
    }
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name:  UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveChanges(notificaiton:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
//MARK: - Note Extension

extension Note {
    var updatedAtAsDate: Date {
        guard let updatedAt = updatedAt else { return Date() }
        return Date(timeIntervalSince1970: updatedAt.timeIntervalSince1970)
    }
    var createdAtAsDate: Date {
        guard let createdAt = createdAt else { return Date() }
        return Date(timeIntervalSince1970: createdAt.timeIntervalSince1970)
    }
    var alphabetizedTags: [Tag]? {
         guard let tags = tags as? Set<Tag> else {
             return nil
         }

         return tags.sorted(by: {
             guard let tag0 = $0.name else { return true }
             guard let tag1 = $1.name else { return true }
             return tag0 < tag1
         })
     }

     var alphabetizedTagsAsString: String? {
         guard let tags = alphabetizedTags, tags.count > 0 else {
             return nil
         }

         let names = tags.compactMap { $0.name }
         return names.joined(separator: ", ")
     }
}

//MARK: - Category Extension

extension Category {
    var color: UIColor? {
        get {
            guard let hex = colorAsHex else { return nil }
            return UIColor(hex: hex)
        }
        set {
            if let newColor = newValue {
                colorAsHex = newColor.toHex
            }
        }
    }
}
