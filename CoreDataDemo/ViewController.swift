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
    
    var listName: [PersonModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvcList.delegate = self
        tvcList.dataSource = self
        tvcList.layer.cornerRadius = 20
        tvcList.register(UINib(nibName: TableViewCell.className, bundle: nil), forCellReuseIdentifier: TableViewCell.className)
        listName = CoreDataServer.shared.getData()
        tvcList.reloadData()
    }

    @IBAction func btn_Add(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Tạo mới", message: "Nhập tên và tuổi của bạn", preferredStyle: .alert)
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
            CoreDataServer.shared.insertData(nameadd, Int(ageadd) ?? 0)
            self.listName = CoreDataServer.shared.getData()
            self.tvcList.reloadData()
            self.tvcList.scrollToRow(at: IndexPath(row: listName.count - 1, section: 0), at: .none, animated: true)
        }
        let btn_Cancel: UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alert.addAction(btn_Save)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btn_DeleteAll(_ sender: Any) {
        let alert = UIAlertController(title: "Xoá tất cả", message: "Bạn có muốn xoá tất cả dữ liệu", preferredStyle: .alert)
        let btn_DeleteAll = UIAlertAction(title: "Xoá tất cả", style: .destructive) { (btnDeleteAll) in
            CoreDataServer.shared.deleteAll()
            self.listName.removeAll()
            self.tvcList.reloadData()
        }
        let btn_Cancel = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alert.addAction(btn_DeleteAll)
        alert.addAction(btn_Cancel)
        self.present(alert, animated: true, completion: nil)
    }
        
    
}

//MARK: -- TABLEVIEWDELEGATE, TABLEVIEWDATASOURE

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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

