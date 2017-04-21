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
    
    // Fetch all tasks for local store and sort them by data
    // When app is first launched.
    func getAllTasksSortedByDate() -> [Task] {
        var tasks : [Task] = []
        let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
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
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // Integrates remote data with local data, updating existing records and adding new ones
    // When the tableview's responsehandler receives json data from the remote store
    func integrateTasks(tasks: [Task], withJSONArray jsonArray: [[String : Any]]) {
        var newTasks = tasks
        print("begin nearby search json parsing")
        let fetch = NSFetchRequest<Task>(entityName: "Task")
        for json in jsonArray {
            guard let uniqueID = json["uniqueID"] as? String else { return }
            // Check for alreay stored Starbucks location
            fetch.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
            do {
                let fetchedTasks = try context.fetch(fetch)
                if fetchedTasks.count > 0 {
                    // Update task
                    print("updating existing record")
                    fetchedTasks[0].updateProperties(withJSON: json)
                } else {
                    // Add new task
                    print("adding new record")
                    let task = Task(withJSON: json, intoContext: context)
                    newTasks += [task]
                }
            } catch {
                print ("Filtered fetch failed")
            }
        }
        print("end nearby search json parsing")
        
    }
    
}
