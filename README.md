Một trong những bài học vỡ lòng của các những bạn mới học lập trình iOS (Swift) là làm quen với Core Data. Và bài viết này sẽ giúp các bạn co thể làm quen những thao tác cơ bản nhất với Core Data. Core Data bạn hiểu đơn giản là 1 framework có sẵn để bạn có thể lưu trữ dữ liệu trong app.

## Tạo project tích hợp Core Data

Khi bạn tạo mới 1 project thì bạn tick thêm vào ô "Use Core Data" là được.
![](https://sv1.upanh.me/2021/10/15/Screen-Shot-2021-10-15-at-16.11.435e293a87fbe4e739.png)

## Tạo record model bằng Core Data

Khi bạn tạo mới 1 project có tích hợp Core Data thì X Code sẽ tạo sẵn cho bạn 1 file "xcdatamodeld", đây chính là nơi lưu dữ liệu trong app của bạn.
Để tạo 1 **Entities**, rất đơn giản là bạn nhấn nút "Add Entity", đặt tên cho **Entities** và thêm các trường **Atttribute** cho **Entities** đó.
Ở đây mình tạo 1 entities có tên là **"Person"** với các trường cơ bản là _**name**_, _**id**_, _**age**_.
![](https://sv1.upanh.me/2021/10/15/Screen-Shot-2021-10-15-at-16.46.23045df16207cf9eb5.png)

Tạo xong record model Core Data rồi thì bạn hãy tạo 1 class model object. Class khá đơn giản như sau, trong đó có hàm khởi tạo với NSManagedObject với NSManagedObject là đại diện cho 1 object được lưu trong Core Data. 

```swift
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
```
Okay, đã xong phần tạo record model rồi.

## Tạo file giao diện cơ bản

Bạn vào file storyboard, tạo layout cơ bản như hình, với 1 table, 1 button để xoá tất cả dữ liệu và 1 button để thêm 1 trường dữ liệu.
![](https://sv1.upanh.me/2021/10/15/Screen-Shot-2021-10-15-at-17.03.06a0dc6c6a745e7da8.png)

Sau đó bạn tạo 1 file "TableViewCell" kèm theo file **.xib**. Trong file **.xib** bạn layout 1 label để hiển thị tên, 1 label để hiển thị tuổi, 2 button để sửa và xoá mỗi row tương ứng:
![](https://sv1.upanh.me/2021/10/15/Screen-Shot-2021-10-15-at-17.08.257ada2f9c016207c2.png)

Trong **ViewController.swift** bạn setup đơn giản để hiển thị dữ liệu với tableview như sau:
```swift
class ViewController: UIViewController {
    @IBOutlet weak var tvcList: UITableView!
    var listName: [PersonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvcList.delegate = self
        tvcList.dataSource = self
        tvcList.register(UINib(nibName: TableViewCell.className, bundle: nil), forCellReuseIdentifier: TableViewCell.className)
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.className) as! TableViewCell
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
    }
    
    @objc func btn_Delete(_ sender: UIButton) {
        let i = sender.tag
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
```

## Xử lý dữ liệu với Core Data:
Sau khi setup xong giao diện thì chúng ta bắt đầu tới phần quan trọng nhất là xử lý dữ liệu với Core Data. Ở đây mình sẽ hướng dẫn các bạn nhập và lấy dữ liệu, thêm, xoá và update các trường dữ liệu trong Core Data. 
Bạn hãy tạo 1 file tên **CoreDataServer.swift**. Đây là file bạn để các hàm xử lý với Core Data.

```swift
import UIKit
import CoreData

class CoreDataServer {
    static let shared = CoreDataServer()
}
```

### Nhập dữ liệu.
Trong file **CoreDataServer.swift** bạn thêm hàm sau:

```swift
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
```
Trong đó hàm _**nextAvailble**_ chỉ đơn giản để tạo ra primekey để nhập cho id sẽ tăng dần trong trường **id**.
Với hàm _**insertData**_ mình giải thích các bước như sau:
1. Trước khi bạn có thể thap tác bất kì thứ gì với CoreData, bạn cần phải lấy ra NSManagedObjectContext. Hàm lấy ra có sẵn ở **AppDelegate** khi bạn tạo project có tích hợp CoreData.
2. Tạo một đối tượng quản lý và insert vào managed object context. Nhớ điền đúng tên **"Person"** của EntityName.
3. Set các value cho các trường đối tượng của **Person**
4. Commit và save các thay đổi vào Core Data.

### Lấy dữ liệu

```swift
    func getData() -> [PersonModel] {
        var listData = [PersonModel]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetch to CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Get data
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
```
Với hàm **getData** sẽ trả về **[PersonModel]** bạn đã tạo từ trước. Hàm này sẽ giúp bạn lấy ra tất cả dư liệu của **Person**.

### Xoá và update dữ liệu
```swift
    // Get all NSManagedObject
    func getAllNSMO() -> [NSManagedObject] {
        var listData = [NSManagedObject]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Fetch to CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3 Get NSMângedObject
        do {
            listData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return listData
    }
    // Delete Filter
    func deleteId(_ id: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Delete CoreData
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
    // Update filter
    func updateData(_ newname: String,_ newage: Int,_ id: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //1 Get NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2 Update CoreData
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
```
2 hàm trên sẽ delete và update theo trường **id** trong **Person**

## Làm việc với Core Data.

Đã xong phần tạo các hàm để bạn có thể xử lý dễ dàng với CoreData. Giờ chỉ việc gọi nó và sử dụng thôi nào.
Đầu tiên bạn dùng hàm _**getData**_ để lấy ra tất cả các dữ liệu.
```swift
    listName = CoreDataServer.shared.getData()
```
Build và chạy thì bạn sẽ thấy chưa có dữ liệu, đơn giản là vì bạn chưa nhập dữ liệu nào.
Thêm dữ liệu thì đơn giản thôi, bạn gọi hàm **inserData** đã viết từ trước, điền dữ liệu muốn nhập để nó lưu vào Core Data.
Ví dụ:
```swift
    CoreDataServer.shared.insertData("John", 25)
    CoreDataServer.shared.insertData("Jane", 20)
```


Với việc xoá và sửa dữ liệu cũng tương tự
```swift
        @objc func btn_Edit(_ sender: UIButton) {
        let i = sender.tag
        let alert: UIAlertController = UIAlertController(title: "Đổi tên", message: "Nhập tên mới và tuổi mới", preferredStyle: .alert)
        alert.addTextField { (txtfldName) in
            txtfldName.placeholder = "Tên của bạn"
        }
        alert.addTextField { (txtfldAge) in
            txtfldAge.placeholder = "Tuổi của bạn"
        }
        let btn_Save: UIAlertAction = UIAlertAction(title: "Lưu", style: .default) { [self] (btnSave) in
            let nameadd = alert.textFields![0].text!
            let ageadd = alert.textFields![1].text!
            guard nameadd.count > 0 else { return }
            guard ageadd.count > 0 else { return }
            CoreDataServer.shared.updateData(nameadd, Int(ageadd) ?? 0, listName[i].id)
            self.listName = CoreDataServer.shared.getData()
            self.tvcList.reloadData()
        }
        let btn_Cancel: UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alert.addAction(btn_Save)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func btn_Delete(_ sender: UIButton) {
        let i = sender.tag
        CoreDataServer.shared.deleteId(listName[i].id)
        listName.remove(at: i)
        tvcList.reloadData()
    }
```
Bạn có thể build và tận hưởng thành quả. Rất là đơn giản phải không ^^.

## Tổng kết
Trên đây là những xử lý cơ bản nhất của Core Data trong lập trình iOS với Swift. Tất nhiên vẫn còn rất nhiều thứ hay ho khác về Core Data bạn có thể học nâng cao thêm. Hy vọng bài viết trên sẽ giúp các bạn mới học lập trình iOS hiểu rõ hơn về Core Data

