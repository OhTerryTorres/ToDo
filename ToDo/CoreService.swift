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
    func getTasksSortedByDate(withPredicate predicate: NSPredicate? = nil) -> [Task] {
        var tasks : [Task] = []
        let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
        if let p = predicate { fetchRequest.predicate = p }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: TaskPropertyKeys.dateCreated.rawValue, ascending: true)]
        do {
            tasks = try context.fetch(fetchRequest)
        }
        catch {
            print("Fetch Failed")
        }
        return tasks
    }
    
    // Add a new task
    // When user hits return after writing the name of a new task
    func insert(taskWithName name: String) -> Task? {
        do {
            // Create Task in context
            let task = try Task(name: name, context: context)
            return task
            
        } catch Task.TaskError.noName {
            print("Task has no name, was not created")
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    // Change name of task
    // When user hits return after changing string in the associated cell's text field
    func set(task: Task, withName name: String) {
        guard let id = task.uniqueID else { return }
        let fetch = NSFetchRequest<Task>(entityName: "Task")
        fetch.predicate = NSPredicate(format: "uniqueID == %@", id)
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
    func delete(task: Task) {
        self.context.delete(task)
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
        
        let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        batchDeleteRequest.resultType = .resultTypeCount
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(batchDelete)
            
        } catch {
            print("batch delete failed")
        }
        
        
    }
    
    // Integrates remote data with local data, updating existing records and adding new ones
    // When the tableview's responsehandler receives json data from the remote store
    func integrateTasks(withJSONArray jsonArray: [[String : Any]]) {
        let fetch = NSFetchRequest<Task>(entityName: "Task")
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
                    let task = Task(withJSON: json, intoContext: context)
                    print("adding \(task.name ?? "")")
                }
            } catch {
                print ("Filtered fetch failed")
            }
        }
    }
    
}
