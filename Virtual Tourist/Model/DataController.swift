//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import Foundation
import CoreData

class DataController {
    static var shared = DataController(modelName: "Virtual Tourist")
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgrounContext: NSManagedObjectContext!
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts() {
        backgrounContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgrounContext.automaticallyMergesChangesFromParent = true
        
        backgrounContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump // current changes over store
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // store over current changes
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext()
        }
    }
}
