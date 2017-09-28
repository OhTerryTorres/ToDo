//
//  sCoreService.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit
import CoreData

struct CoreService {
    
    let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    init() {
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
    }
    
    // Fetch all tasks for local store and sort them by date
    // When app is first launched.
    func getTasks(withPredicate predicate: NSPredicate? = nil) -> [Task] {
        var taskModels : [TaskModel] = []
        var tasks : [Task] = []
        let fetchRequest : NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        if let p = predicate { fetchRequest.predicate = p }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: TaskPropertyKeys.order.rawValue, ascending: true)]
        do {
            taskModels = try persistentContainer.viewContext.fetch(fetchRequest)
        }
        catch {
            print("Fetch Failed")
        }
        
        for taskModel in taskModels {
            tasks += [Task(withTaskModel: taskModel)]
        }
        
        return tasks
    }

    func deleteAllTasks(withPredicate predicate: NSPredicate? = nil) {
        /*
         Batch deletes react directly with the persistent store, bypassing the context.
         If every item in the data source's array is a reference to a manged object in
         context, but that managed object's record in the persistent store will not match
         up. This results in a merge conflict down the line.
         Since the task list is designed to be shared, the remote store, which sees
         intereaction from all potential users, can be considered More Canon than the local.
         TL;DR, when switching to a new list of tasks, the context can just say "Fuck it."
        */
        persistentContainer.viewContext.reset()

        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
        if let p = predicate {
            fetch.predicate = p
            
        }
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try persistentContainer.viewContext.execute(batchDelete)
        } catch {
            print("batch delete failed")
        }
    }
    
    // Integrates displayed data with data in local store, updating existing records and adding new ones
    func syncTasksToCoreData(tasks: [Task]) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        var newTasks : [TaskModel] = []
        let fetch = NSFetchRequest<TaskModel>(entityName: "TaskModel")
        for task in tasks {
            // Check for alreay stored tasks
            fetch.predicate = NSPredicate(format: "uniqueID == %@", task.uniqueID)
            do {
                let fetchedTasks = try backgroundContext.fetch(fetch)
                if fetchedTasks.count > 0 {
                    // Update task
                    fetchedTasks[0].updateProperties(withTask: task)
                } else {
                    // Add new task
                    print(task.name)
                    print(task.uniqueID)
                    let task = TaskModel(withTask: task, intoContext: backgroundContext)
                    newTasks += [task]
                    print("adding \(task.name ?? "") to core data")
                }
            } catch {
                print ("Filtered fetch failed")
            }
        }
        
        deleteExtraneousTasks(tasks: tasks, withContext: backgroundContext)
        
    }
    
    // If tasks have been deleted from display list, delete them from the local store
    func deleteExtraneousTasks(tasks: [Task], withContext context: NSManagedObjectContext) {
        var taskByIdDict : [String:Task] = [:]
        
        for task in tasks {
            taskByIdDict[task.uniqueID] = task
        }

        let fetch = NSFetchRequest<TaskModel>(entityName: "TaskModel")
        var storedTaskModels : [TaskModel] = []
        do {
            storedTaskModels = try context.fetch(fetch)
        } catch {
            print("Sync fetch failed")
        }
        guard storedTaskModels.count > 0 else { return }
        
        for index in 0..<storedTaskModels.count {
            let storedTask = storedTaskModels[index]
            guard let id = storedTask.uniqueID else { return }
            if taskByIdDict[id] == nil {
                print("deleting extraneous task")
                context.delete(storedTask)
            }
        }
        
        save(context: context)
        print("background context saved")
        
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let saveErrorAlert = UIAlertController(title: "Save Error", message: "ToDo seems to have run into an error while saving your data. If error persists, reinstall ToDo.", preferredStyle: .alert)
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(saveErrorAlert, animated: false)
            }
        }
    }
    
}
