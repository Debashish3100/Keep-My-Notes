//
//  CoreDataStack.swift
//  Note Demo
//
//  Created by Debashish Das on 15/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import CoreData

final class CoreDataStack {

    //MARK: - Singleton Instance
    
    private static var coreDataStack = CoreDataStack(moduleName: "NotesDemo")
    
    //MARK: - Property
    
    private let moduleName: String
    
    //MARK: Persistant Container
    
    private(set) lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.moduleName)
        let description =  NSPersistentStoreDescription()
//        description.shouldMigrateStoreAutomatically = true
//        description.shouldInferMappingModelAutomatically = true
//        container.persistentStoreDescriptions.append(description)
        return container
    }()
    
    //MARK: - Managed Object Context
    
    private(set) lazy var context: NSManagedObjectContext = {
        self.persistantContainer.viewContext
    }()
    
    //MARK: - Initializer
    
    init(moduleName: String) {
        self.moduleName = moduleName
    }
    
    //MARK: - Load Persistant Store
    
    func loadPersistantStore(completionHandler: @escaping () -> Void) -> Void {
        persistantContainer.loadPersistentStores { (_, error) in
            print("called")
            if let error = error {
                print("ERROR TYPE : \(error.localizedDescription)")
                fatalError("Error in loading persistant store")
            } else {
                completionHandler()
            }
        }
    }
    
    //MARK: - Perform Operation Synchronously
    
    func performSyncOperation(block: () -> Void) -> Void {
        context.performAndWait {
            block()
        }
    }
    
    //MARK: - Perform Operation ASynchronously
    
    func performAsyncOperation(block: @escaping () -> Void) -> Void {
        context.perform {
            block()
        }
    }
    
    //MARK: - Save Operation
    
    func save() {
        persistantContainer.performBackgroundTask { [weak self] (_) in
            guard let weakSelf = self else { return }
            do {
                if weakSelf.context.hasChanges {
                    try weakSelf.context.save()
                    print("saved")
                }
            } catch let error {
                print("ERROR TYPE : \(error.localizedDescription)")
                fatalError("Error in saving data")
            }
        }
    }
    
    //MARK: - Accessor
    
    static func shared() -> CoreDataStack {
        coreDataStack
    }
    
}
