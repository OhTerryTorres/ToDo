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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init() {
        context.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
    }
    
    // Fetch all tasks for local store and sort them by data
    // When app is first launched.
    func getTasks(withPredicate predicate: NSPredicate? = nil) -> [Task] {
        var taskModels : [TaskModel] = []
        var tasks : [Task] = []
        let fetchRequest : NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        if let p = predicate { fetchRequest.predicate = p }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: TaskPropertyKeys.order.rawValue, ascending: true)]
        do {
            taskModels = try context.fetch(fetchRequest)
        }
        catch {
            print("Fetch Failed")
        }
        
        for taskModel in taskModels {
            tasks += [Task(withTaskModel: taskModel)]
        }
        
        return tasks
    }
    
    // Add a new task
    // When user hits return after writing the name of a new task
    func insert(taskWithName name: String, atIndex index: Int) -> Task? {
        // Create Task in context
        let task = Task(name: name, order: index)
        return task
    }
    
    // Change name of task
    // When user hits return after changing string in the associated cell's text field
    func set(task: Task, withName name: String) {
        let fetch = NSFetchRequest<TaskModel>(entityName: "Task")
        fetch.predicate = NSPredicate(format: "uniqueID == %@", task.uniqueID)
        do {
            let fetchedStarbuckses = try context.fetch(fetch)
            if fetchedStarbuckses.count > 0 {
                fetchedStarbuckses[0].name = name
            }
        } catch {
            print("fetch with unique ID failed")
        }
    }
    
    // Remove task from local store
    // When the delete edit action is taken on the tableview
    func delete(taskModel: TaskModel) {
        self.context.delete(taskModel)
    }
    func deleteAllTasks() {
        /*
         Batch deletes react directly with the persistent store, bypassing the context.
         If every item in the data source's array is a reference to a manged object in
         context, but that managed object's record in the persistent store will not match
         up. This results in a merge conflict down the line.
         Since the task list is designed to be shared, the remote store, which sees
         intereaction from all potential users, can be considered More Canon than the local.
         TL;DR, when switching to a new list of tasks, the context can just say "Fuck it."
        */
        context.reset()

        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskModel")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(batchDelete)
            
        } catch {
            print("batch delete failed")
        }
        
        
    }
    
    // Integrates remote data with local data, updating existing records and adding new ones
    // When the tableview's responsehandler receives json data from the remote store
    func integrateTasks(tasks: [Task], withJSONArray jsonArray: [[String : Any]]) {
        save()
        var newTasks : [TaskModel] = []
        let fetch = NSFetchRequest<TaskModel>(entityName: "TaskModel")
        for json in jsonArray {
            guard let uniqueID = json["uniqueID"] as? String else { return }
            // Check for alreay stored Starbucks location
            fetch.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
            do {
                let fetchedTasks = try context.fetch(fetch)
                if fetchedTasks.count > 0 {
                    // Update task
                    fetchedTasks[0].updateProperties(withJSON: json)
                } else {
                    // Add new task
                    let task = TaskModel(withJSON: json, intoContext: context)
                    newTasks += [task]
                    print("adding \(task.name ?? "")")
                }
            } catch {
                print ("Filtered fetch failed")
            }
        }
        
        let newSortedTasks = newTasks.sorted(by: {$1.dateCreated! as Date > $0.dateCreated! as Date})
        var currentIndex = tasks.count
        for task in newSortedTasks {
            task.order = Int16(currentIndex)
            currentIndex += 1
        }
    }
    
    func syncTasksToCoreData(tasks: [Task]) {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        var taskByIdDict : [String:Task] = [:]

        let fetch = NSFetchRequest<TaskModel>(entityName: "TaskModel")
        var storedTaskModels : [TaskModel] = []
        do {
            storedTaskModels = try backgroundContext.fetch(fetch)
        } catch {
            print("Sycn fetch failed")
        }
        guard storedTaskModels.count > 0 else { return }
        
        for index in 0..<storedTaskModels.count {
            var storedTask = storedTaskModels[index]
            guard let id = storedTask.uniqueID else { return }
            if let displayedTask = taskByIdDict[id] {
                storedTask = TaskModel(withTask: displayedTask, intoContext: backgroundContext)
            } else {
                delete(taskModel: storedTask)
            }
        }
        
        save(context: backgroundContext)
        
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // *****
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}
