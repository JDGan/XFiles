//
//  MasterViewController.swift
//  XFiles
//
//  Created by JDG on 16/3/2.
//  Copyright © 2016年 JDG. All rights reserved.
//

import UIKit
import QuickLook

class MasterViewController: UITableViewController , QLPreviewControllerDataSource ,UIAlertViewDelegate {

    var dataSource = [DocumentPoint]()
    fileprivate var tag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(MasterViewController.refreshPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MasterViewController.donePressed))
        loadCatalog()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadCatalog () {
        dataSource.removeAll()
        if !tag {
            let p = DocumentPoint()
            p.name = "test"
            p.type = .notSure
            dataSource.append(p)
        } else {
            if let f = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                dataSource.append(contentsOf: DocumentPoint.findDocumentPointsAtPath(f).subPoints)
            }
        }
        self.tableView.reloadData()
    }
    
    func refreshPressed (){
        loadCatalog()
        if tag {
            tag = false
        }
    }
    
    func donePressed () {
        let a = UIAlertController(title: "请输入测试代码", message: nil, preferredStyle: .alert)
        a.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        a.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            if let t = a.textFields?.first?.text, t == "ganll" {
                self.tag = true
                self.refreshPressed()
            }
        }))
        
        a.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(a, animated: true, completion: nil)
    }
    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let point = dataSource[indexPath.row]
        cell.textLabel?.text = point.name
        cell.accessoryType = (point.type == .file) ? UITableViewCellAccessoryType.none : UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = dataSource[indexPath.row]
        if point.type == .directory {
            let s = UIStoryboard(name: "Main", bundle: nil)
            if let vc = s.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.docPoint = point
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if point.type == .file {
            let p = QLPreviewController()
            p.dataSource = self
            previewItems = dataSource.filter{$0.type == .file} 
            p.currentPreviewItemIndex = findIndex(point)
            self.navigationController?.pushViewController(p, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let point = dataSource[indexPath.row]
        let f = FileManager.default
        if f.isDeletableFile(atPath: point.path) {
            do {
               try f.removeItem(atPath: point.path)
                dataSource.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tableView.endUpdates()
            } catch {
                print("删除失败")
            }
        }
    }
    
    func findIndex(_ item : DocumentPoint) -> Int {
        let points = previewItems
        var i = 0
        for it in points {
            if item == it {
                return i
            }
            i += 1
        }
        return 0
    }
    
    fileprivate var previewItems = [DocumentPoint]()
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems[index]
    }
}

