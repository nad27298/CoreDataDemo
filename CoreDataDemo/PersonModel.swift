//
//  PersonModel.swift
//  CoreDataDemo
//
//  Created by Macbook on 2/3/21.
//

import Foundation
import CoreData

class PersonModel {
    
    var name: String = ""
    var id: Int = 0
    var age: Int = 0
    
    init(data: NSManagedObject) {
        self.name = data.value(forKeyPath: "name") as? String ?? ""
        self.id = data.value(forKeyPath: "id") as? Int ?? 0
        self.age = data.value(forKeyPath: "age") as? Int ?? 0
    }
    
}
