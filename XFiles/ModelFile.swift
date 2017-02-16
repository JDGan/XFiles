//
//  ModelFile.swift
//  XFiles
//
//  Created by JDG on 16/3/2.
//  Copyright © 2016年 JDG. All rights reserved.
//

import Foundation
import QuickLook

enum DocumentPointType {
    case file , directory , notSure
}

class DocumentPoint : NSObject , QLPreviewItem {
    
    class func findDocumentPointsAtPath (_ path : String) -> DocumentPoint {
        let root = DocumentPoint()
        root.path = path
        root.type = .directory
        root.name = "root"
        root.loadSubPoints()
        return root
    }
    
    var path : String = ""
    var name : String = ""
    var type : DocumentPointType = .notSure
    var subPoints : [DocumentPoint] = []
    
    func loadSubPoints () {
        subPoints.removeAll()
        let f = FileManager.default
        do {
            let subPaths = try f.contentsOfDirectory(atPath: path)
            var isDir = ObjCBool(false)
            for subPath in subPaths {
                if subPath.hasPrefix(".") {
                    continue
                }
                let child = DocumentPoint()
                let fullPath = self.path + "/" + subPath
                if f.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    child.name = subPath
                    child.path = fullPath
                    if isDir.boolValue {
                        child.type = .directory
                        child.loadSubPoints()
                    } else {
                        child.type = .file
                    }
                    subPoints.append(child)
                } else {
                    
                }
            }
        } catch {
            
        }
    }
    
    
    /*!
    * @abstract The URL of the item to preview.
    * @discussion The URL must be a file URL.
    */
    var previewItemURL: URL? {
        return URL(fileURLWithPath: path)
    }
    
    /*!
    * @abstract The item's title this will be used as apparent item title.
    * @discussion The title replaces the default item display name. This property is optional.
    */
    var previewItemTitle: String? {
        return name
    }
}


