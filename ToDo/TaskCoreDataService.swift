//
//  TaskCoreDataService.swift
//  ToDo
//
//  Created by TerryTorres on 4/5/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit
import CoreData

struct TaskCoreDataService {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllTasksSortedByDate() -> [Task] {
        var tasks : [Task] = []
        let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        do {
            tasks = try context.fetch(fetchRequest)
            print("tasks.count is \(tasks.count)")
        }
        catch {
            print("Fetch Failed")
        }
        return tasks
    }
    
    
    func addNewTask(withName name: String) -> Task? {
        print("4A adding new task with name: \(name)")
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
    
    func updateTask(task: Task, withName name: String) {
        print("4B updating task with name: \(name)")
        guard let id = task.uniqueID else { return }
        let fetch = NSFetchRequest<Task>(entityName: "Task")
        fetch.predicate = NSPredicate(format: "uniqueID == %@", id)
        do {
            let fetchedStarbuckses = try context.fetch(fetch)
            if fetchedStarbuckses.count > 0 {
                print("\(fetchedStarbuckses[0].name) is now \(task.name)")
                fetchedStarbuckses[0].name = name
            }
        } catch {
            print("fetch with unique ID failed")
        }
    }
    
    func delete(task: Task) {
        self.context.delete(task)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}
