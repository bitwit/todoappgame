//
//  MasterViewController.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-05.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import UIKit
import CoreData
import BWSwipeRevealCell

class MasterViewController: UITableViewController {
    
    private var isFirstAppearance = true
    private var gameStatusView:GameStatusView?

    // Data
    var managedObjectContext: NSManagedObjectContext? = nil
    var allTasks: [String]
    var possibleTasks: [String] = []
    
    // Timer
    var shouldAddTasks = true
    var gameTimer: NSTimer?
    
    required init?(coder aDecoder: NSCoder) {
        
        let path = NSBundle.mainBundle().pathForResource("data.json", ofType: nil)!
        let fileManager = NSFileManager.defaultManager()
        let data:NSData? = fileManager.contentsAtPath(path)
        let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        
        allTasks = (jsonData as! [String])
        
        super.init(coder:aDecoder)
        
        Notifications.observe(self, selector: #selector(newGame), type: .New)
        Notifications.observe(self, selector: #selector(pause), type: .Pause)
        Notifications.observe(self, selector: #selector(resume), type: .Resume)
        Notifications.observe(self, selector: #selector(endGame), type: .End)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(pause))
        
        loadGameStatusView()
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            displayIntro()
            isFirstAppearance = false
        }
    }
    
    func loadGameStatusView() {
    
        let nib = NSBundle.mainBundle().loadNibNamed("GameStatusView", owner: nil, options: nil)
        for object in nib {
            if let o = object as? GameStatusView {
                gameStatusView = o
                break
            }
        }
        
        navigationItem.titleView = gameStatusView
    }
    
   
    // MARK: Timer Stuff
    
    func startTimer() {
    
        gameTimer?.invalidate() // Safety measure, though timer calls *should* be balanced
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(Game.timerInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
    
        gameTimer?.invalidate()
    }
    
    
    // MARK: Game Control
    
    func displayIntro() {
    
        let intro = StoryboardReference("Main", "Introduction").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func displayGameOver() {
    
        let intro = StoryboardReference("Main", "GameOver").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func newGame() {
        
        Game.onReset()
        Notifications.post(.Reset)
        
        possibleTasks = allTasks.shuffle()
        fetchedResultsController.managedObjectContext.rollback()
        
        dismissViewControllerAnimated(true) {
            self.startTimer()
            self.gameTimer!.fire()
        }
    }
    
    func pause() {
        
        stopTimer()
        
        let intro = StoryboardReference("Main", "Pause").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func resume() {
    
        dismissViewControllerAnimated(true) {
            self.startTimer()
        }
    }
    
    func endGame() {
        
        stopTimer()
        
        if let _ = presentedViewController {
            
            dismissViewControllerAnimated(true) {
                self.displayIntro()
            }
        } else {
            
            displayGameOver()
        }
    
    }
    
    func tick() {
        
        Game.onTick()
        Notifications.post(.Tick)
        
        if Game.time > Game.maxTime {
            endGame()
        } else {
            insertNewObject()
        }
    }

    func insertNewObject() {
        
        guard shouldAddTasks else {
            return
        }
        
        guard let taskTitle = possibleTasks.popLast() else {
            return
        }
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let task:Task = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Task
        
        task.timeStamp = NSDate()
        task.title = taskTitle
    }

    
    // MARK: - Segues

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
//    }

    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BWSwipeRevealCell
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        self.configureCell(cell, withObject: object)
        return cell
    }

    func configureCell(cell: BWSwipeRevealCell, withObject task: Task) {
        cell.revealDirection = .Both
        cell.delegate = self
        cell.textLabel!.text = task.title
    }

    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

}

extension MasterViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Top)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! BWSwipeRevealCell, withObject: anObject as! Task)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
}

extension MasterViewController: BWSwipeRevealCellDelegate {
    
    func swipeCellDidStartSwiping(cell: BWSwipeCell) {
        shouldAddTasks = false
    }
    
    func swipeCellDidCompleteRelease(cell: BWSwipeCell) {
        
        shouldAddTasks = true
        
        guard cell.state != .Normal else { return }
        
        switch cell.state {
        case .PastThresholdLeft, .PastThresholdRight:
            let points = 3
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let rootView = appDelegate.window!
            
            let x = CGRectGetMaxX(cell.frame) - 20
            let y = CGRectGetMidY(cell.frame)
            
            let from:CGPoint = cell.superview!.convertPoint(CGPointMake(x, y), toView: rootView)
            let to: CGPoint = CGPointMake(from.x, 40)
            
            let totalPoints = Game.onTaskCompletion(points)
            AnimationWindow.sharedInstance.runPointsAnimation(from, to: to, points:totalPoints)
            
            if let idx = tableView.indexPathForCell(cell), let task = fetchedResultsController.fetchedObjects![idx.row] as? Task {
                fetchedResultsController.managedObjectContext.deleteObject(task)
            }
        default: break
        }
        
    }
    
}