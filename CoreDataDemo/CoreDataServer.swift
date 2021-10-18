//
//  CoreDataServer.swift
//  CoreDataDemo
//
//  Created by Macbook on 2/3/21.
//

import UIKit
import CoreData

class CoreDataServer {
    
    static let shared = CoreDataServer()
    
    //MARK: -- INSERT
    
    // Insert
    func insertData(_ name: String,_ age: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2 Creat object and insert to managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3 Add value name to object person by key-value coding.
        person.setValue(name, forKeyPath: "name")
        person.setValue(age, forKeyPath: "age")
        person.setValue(self.nextAvailble("id", forEntityName: "Person", in: managedContext), forKeyPath: "id")
        // 4 Save to core data
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not insert. \(error), \(error.userInfo)")
        }
    }
    
    // Get ID primekey
    func nextAvailble(_ idKey: String, forEntityName entityName: String, in context: NSManagedObjectContext) -> NSNumber? {
        let req = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        req.entity = entity
        req.fetchLimit = 1
        req.propertiesToFetch = [idKey]
        let indexSort = NSSortDescriptor.init(key: idKey, ascending: false)
        req.sortDescriptors = [indexSort]
        do {
            let fetchedData = try context.fetch(req)
            let firstObject = fetchedData.first as! NSManagedObject
            if let foundValue = firstObject.value(forKey: idKey) as? NSNumber {
                return NSNumber.init(value: foundValue.intValue + 1)
            }
        } catch let error as NSError {
            print("Could not get id primary key. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    //MARK: -- GET
    
    // Get all NSManagedObject
    func getAllNSMO() -> [NSManagedObject] {
        var listData = [NSManagedObject]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetching to CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Fetch request
        do {
            listData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return listData
    }
    
    // Get filter NSManagedObject
    func getAge(_ age: Int) -> [NSManagedObject] {
        var listData = [NSManagedObject]()
        for item in self.getAllNSMO() {
            if item.value(forKeyPath: "age") as? Int == age {
                listData.append(item)
            }
        }
        return listData
    }
    
    // Get All Model
    func getData() -> [PersonModel] {
        var listData = [PersonModel]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetching to CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Fetch request
        do {
            let listCata = try managedContext.fetch(fetchRequest)
            for item in listCata {
                listData.append(PersonModel(data: item))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return listData
    }
    
    // Get filter Model
    func getDataAge(_ age: Int) -> [PersonModel] {
        var listData = [PersonModel]()
        for item in self.getData() {
            if item.age == age {
                listData.append(item)
            }
        }
        return listData
    }
    
    //MARK: -- DELETE
    
    // Delete Filter
    func deleteId(_ id: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Deleting CoreData
        for item in self.getAllNSMO() {
            if item.value(forKeyPath: "id") as? Int == id {
                managedContext.delete(item)
            }
        }
        //3 Save to coredata
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    // Delete All
    func deleteAll() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Deleting CoreData
        for item in self.getAllNSMO() {
            managedContext.delete(item)
        }
        //3 Save to coredata
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: -- UPDATE
    
    // Update filter
    func updateData(_ newname: String,_ newage: Int,_ id: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Updateing CoreData
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results?[0].setValue(newname, forKeyPath: "name")
                results?[0].setValue(newage, forKeyPath: "age")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        //3 Save to coredata
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
    
}
