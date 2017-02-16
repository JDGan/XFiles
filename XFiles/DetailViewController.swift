//
//  DetailViewController.swift
//  XFiles
//
//  Created by JDG on 16/3/2.
//  Copyright © 2016年 JDG. All rights reserved.
//

import UIKit
import QuickLook

class DetailViewController: UITableViewController ,QLPreviewControllerDataSource{

    var docPoint : DocumentPoint?     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docPoint?.subPoints.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let point = docPoint?.subPoints[indexPath.row] {
            cell.textLabel?.text = point.name
            cell.accessoryType = (point.type == .file) ? UITableViewCellAccessoryType.none : UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = docPoint?.subPoints[indexPath.row]
        if point?.type == .directory {
            let s = UIStoryboard(name: "Main", bundle: nil)
            if let vc = s.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                vc.docPoint = point
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if let dp = point {
            let p = QLPreviewController()
            p.dataSource = self
            previewItems = docPoint?.subPoints.filter{$0.type == .file} ?? []
            p.currentPreviewItemIndex = findIndex(dp)
            self.navigationController?.pushViewController(p, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let point = docPoint?.subPoints[indexPath.row] {
            let f = FileManager.default
            if f.isDeletableFile(atPath: point.path) {
                do {
                    try f.removeItem(atPath: point.path)
                    docPoint?.subPoints.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    tableView.endUpdates()
                } catch {
                    print("删除失败")
                }
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

