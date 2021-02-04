//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Macbook on 2/3/21.
//

import UIKit
import CoreData


//MARK: -- EXTENSION

extension NSObject {
    func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    var className: String {
        return String(describing: type(of: self))
    }
    class var className: String {
        return String(describing: self)
    }
}


//MARK: -- VIEWCONTROLLER

class ViewController: UIViewController {

    @IBOutlet weak var tvcList: UITableView!
    
//    var people: [NSManagedObject] = []
    var listName: [PersonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvcList.delegate = self
        tvcList.dataSource = self
        tvcList.layer.cornerRadius = 20
        tvcList.register(UINib(nibName: TableViewCell.className, bundle: nil), forCellReuseIdentifier: TableViewCell.className)
//        people = getAll()
        listName = getData()
        tvcList.reloadData()
    }

    @IBAction func btn_Add(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "New List", message: "Add a new name and new age", preferredStyle: .alert)
        alert.addTextField { (txtfldName) in
            txtfldName.placeholder = "Your name"
        }
        alert.addTextField { (txtfldAge) in
            txtfldAge.placeholder = "Your age"
        }
        let btn_Save: UIAlertAction = UIAlertAction(title: "Save", style: .default) { [self] (btnSave) in
            let nameadd = alert.textFields![0].text!
            let ageadd = alert.textFields![1].text!
            self.insertData(nameadd, Int(ageadd) ?? 0)
            self.listName = getData()
            self.tvcList.reloadData()
            self.tvcList.scrollToRow(at: IndexPath(row: listName.count - 1, section: 0), at: .none, animated: true)
        }
        let btn_Cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(btn_Save)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btn_DeleteAll(_ sender: Any) {
        let alert = UIAlertController(title: "DELETE ALL", message: "Do you want delete all name list?", preferredStyle: .alert)
        let btn_DeleteAll = UIAlertAction(title: "Delete All", style: .destructive) { (btnDeleteAll) in
            _ = self.deleteAll()
            self.listName.removeAll()
            self.tvcList.reloadData()
        }
        let btn_Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(btn_DeleteAll)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: -- INSERT
    
    // Insert
    func insertData(_ name: String,_ age: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 1 Lấy ra NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2 Tạo một đối tượng quản lý và insert vào managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3 Thêm giá trị name vào đối tượng person bằng key-value coding.
        person.setValue(name, forKeyPath: "name")
        person.setValue(age, forKeyPath: "age")
        person.setValue(self.nextAvailble("id", forEntityName: "Person", in: managedContext), forKeyPath: "id")
        // 4 Save vào bộ nhớ
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
            print("Could not get id primekey. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    //MARK: -- GET
    
    // Get all NSManagedObject
    func getAll() -> [NSManagedObject] {
        var listData = [NSManagedObject]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Lấy ra NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetching từ CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Xử lý fetch request
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
        for item in self.getAll() {
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
        //1 Lấy ra NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetching từ CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Xử lý fetch request
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
    func deleteId(_ id: Int) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Lấy ra NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Deleting CoreData
        for item in self.getAll() {
            if item.value(forKeyPath: "id") as? Int == id {
                managedContext.delete(item)
            }
        }
        //3 Save vào bộ nhớ
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            return false
        }
    }
    
    // Delete All
    func deleteAll() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Lấy ra NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Deleting CoreData
        for item in self.getAll() {
            managedContext.delete(item)
        }
        //3 Save to coredata
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
            return false
        }
    }
    
    //MARK: -- UPDATE
    
    // Update filter
    func updateData(_ newname: String,_ newage: Int,_ id: Int) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Lấy ra NSManagedObjectContext
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
            return true
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
            return false
        }
    }
    
}

//MARK: -- TABLEVIEWDELEGATE, TABLEVIEWDATASOURE

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return people.count
        return listName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.className) as! TableViewCell
//        let person = people[indexPath.row]
//        cell.lblName.text = person.value(forKeyPath: "name") as? String
//        cell.lblAge.text = String((person.value(forKeyPath: "age") as? Int)!)
        cell.lblName.text = listName[indexPath.row].name
        cell.lblAge.text = String(listName[indexPath.row].age)
        cell.btnEdit.addTarget(self, action: #selector(btn_Edit), for: .touchUpInside)
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(btn_Delete), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        return cell
    }
    
    @objc func btn_Edit(_ sender: UIButton) {
        let i = sender.tag
        let alert: UIAlertController = UIAlertController(title: "Rename List", message: "Add a new name and new age", preferredStyle: .alert)
        alert.addTextField { (txtfldName) in
            txtfldName.placeholder = "New name"
        }
        alert.addTextField { (txtfldAge) in
            txtfldAge.placeholder = "New age"
        }
        let btn_Save: UIAlertAction = UIAlertAction(title: "Save", style: .default) { [self] (btnSave) in
            let nameadd = alert.textFields![0].text!
            let ageadd = alert.textFields![1].text!
            _ = updateData(nameadd, Int(ageadd) ?? 0, listName[i].id)
            self.listName = getData()
            self.tvcList.reloadData()
        }
        let btn_Cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(btn_Save)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func btn_Delete(_ sender: UIButton) {
        let i = sender.tag
        _ = deleteId(listName[i].id)
        listName.remove(at: i)
        tvcList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

