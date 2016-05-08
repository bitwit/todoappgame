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
    
    func loadData(data:QueuedTask) {
        
        timeStamp = NSDate()
        title = data.title
        points = data.points
        
        if !data.subtasks.isEmpty {
            
            self.isReadyForCompletion = false
            subtasks = data.subtasks
        } else {
            
            self.isReadyForCompletion = true
        }
        
    }

}
