//
//  Task+CoreDataProperties.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-06.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {

    @NSManaged var timeStamp: NSDate?
    @NSManaged var title: String?
    @NSManaged var points: NSNumber?
    @NSManaged var isReadyForCompletion: NSNumber?
    
    func loadData(data:AnyObject) {
        guard let d = data as? [String: AnyObject] else {
            print("[WARNING]: Didn't load data - ", self.title)
            return
        }
        
        if let points = d["points"] as? Int {
            self.points = points
        } else {
            self.points = 1
        }
        
        if let subtasks = d["subtasks"] as? [String] {
            
            self.isReadyForCompletion = false
            self.subtasks = subtasks
        } else {
            
            self.isReadyForCompletion = true
        }
        
    }

}
