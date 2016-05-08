
import UIKit
import CoreData
import BWSwipeRevealCell

class MasterViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    let taskManager = TaskManager.sharedInstance
    var currentMistakeCell: TaskCell? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        Notifications.observe(self, selector: #selector(newGame), type: .New)
        Notifications.observe(self, selector: #selector(pause), type: .Pause)
        Notifications.observe(self, selector: #selector(resume), type: .Resume)
        Notifications.observe(self, selector: #selector(endGame), type: .End)
        Notifications.observe(self, selector: #selector(addTask), type: .AddTask)
        Notifications.observe(self, selector: #selector(tick), type: .Tick)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(menuButtonPressed))
        
        loadGameStatusView()
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func loadGameStatusView() {
        
        let nib = NSBundle.mainBundle().loadNibNamed("GameStatusView", owner: nil, options: nil)
        for object in nib {
            if let o = object as? GameStatusView {
                o.prepare()
                navigationItem.titleView = o
                break
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func menuButtonPressed(){
        Game.pause()
    }
    
    // MARK: Game Control
    
    func newGame() {
        
        fetchedResultsController.managedObjectContext.rollback()
        taskManager.reset()
        
        dismissViewControllerAnimated(true) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            Game.start()
            self.insertNewObject(6)
        }
    }
    
    func pause() {
        
        let intro = StoryboardReference("Main", "Pause").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func resume() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func endGame() {
        
        if let _ = presentedViewController {
            
            dismissViewControllerAnimated(true) {
                (self.navigationController as! MainNavigationController).displayIntro()
            }
        } else {
            
            (self.navigationController as! MainNavigationController).displayGameOver()
        }
        
    }
    
    func addTask() {
        
        insertNewObject()
    }
    
    func tick() {
    
        guard Game.stage >= 3 else {
            
            return
        }
        
        if let cell = currentMistakeCell {
        
            triggerMistakeFromCell(cell)
        }
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let taskCell = sender as? TaskCell, let indexPath = tableView.indexPathForCell(taskCell) {
                let task = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Task
                let controller = segue.destinationViewController as! DetailViewController
                controller.detailItem = task
            }
        }
    }
    
    func insertNewObject(numberOfTasks:Int = 1) {
        
        (0 ..< numberOfTasks).forEach { _ in
            
            let taskData = taskManager.pop()
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let task:Task = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Task
            
            task.loadData(taskData)
        }
        
    }
    
    
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
       
        guard let c = cell as? TaskCell else {
            return
        }
        
        c.type = .SpringRelease
        c.revealDirection = .Both
        c.delegate = self
        
        c.titleLabel.textColor = Colors.scheme.cellTextColor
        c.titleLabel.text = task.title
        
        c.pointsLabel.alpha = 1
        c.pointsLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
        c.pointsLabel.text = task.points!.stringValue
        c.pointsLabel.textColor = Colors.scheme.cellTextColor
        
        if task.isReadyForCompletion?.boolValue == true {
            
            c.contentView.backgroundColor = Colors.scheme.base
            c.bgViewLeftImage = UIImage(named:"icon-checkmark")!
            c.bgViewLeftColor = Colors.scheme.success
            c.bgViewRightImage = UIImage(named:"icon-disabled")!
            c.bgViewRightColor = Colors.scheme.danger
        } else {
            
            c.contentView.backgroundColor = Colors.scheme.info
            c.bgViewLeftImage = UIImage(named:"icon-disabled")!
            c.bgViewLeftColor = Colors.scheme.danger
            c.bgViewRightImage = UIImage(named:"icon-cog")!
            c.bgViewRightColor = Colors.scheme.settings
        }
    }
    
    
    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
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
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
        
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
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? BWSwipeRevealCell {
                let task = anObject as! Task
                self.configureCell(cell, withObject: task)
            }
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func triggerMistakeFromCell(cell:TaskCell) {
        
        Game.onMistake()
        Score.total -= 1
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootView = appDelegate.window!
        let originPoint = CGPointMake(CGRectGetMaxX(cell.frame) - 40, cell.pointsLabel!.center.y)
        let from = cell.pointsLabel.superview!.convertPoint(originPoint, toView: rootView)
        
        Chirp.sharedManager.playSoundType(.Error)
        
        AnimationWindow.sharedInstance.runPositionedAnimation(from, withText: "-1")
        Notifications.post(.DecrementPoints)
    }
    
}

extension MasterViewController: BWSwipeRevealCellDelegate {
    
    func swipeCellDidSwipe(cell: BWSwipeCell) {
        
        currentMistakeCell = nil
        
        guard let taskCell = cell as? TaskCell
            where taskCell.state != .Normal
            else {
                return
        }
        
        guard let idx = tableView.indexPathForCell(cell),
            let task = fetchedResultsController.fetchedObjects![idx.row] as? Task
            else {
                return
        }
        switch cell.state {
        case .PastThresholdLeft:
            
            guard let isReady = task.isReadyForCompletion?.boolValue
                where isReady
                else {
                    
                    currentMistakeCell = taskCell
                    return
            }
            
        case .PastThresholdRight:
            
            guard let isReady = task.isReadyForCompletion?.boolValue
                where !isReady else {
                
                currentMistakeCell = taskCell
                return
            }
            
        default: break
            
        }
    }
    
    func swipeCellWillRelease(cell: BWSwipeCell) {
        
        if let cell = currentMistakeCell {
        
            triggerMistakeFromCell(cell)
            currentMistakeCell = nil
        }
    }
    
    func swipeCellDidCompleteRelease(cell: BWSwipeCell) {
        
        guard let taskCell = cell as? TaskCell
            where taskCell.state != .Normal
            else {
                return
        }
        
        guard let idx = tableView.indexPathForCell(cell),
            let task = fetchedResultsController.fetchedObjects![idx.row] as? Task
            else {
                return
        }
        
        switch cell.state {
        case .PastThresholdLeft:
            
            guard let isReady = task.isReadyForCompletion?.boolValue
                where isReady
                else {
                    return
            }
            
            let points = Int(task.points!.intValue)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let rootView = appDelegate.window!
            
            
            let originPoint = CGPointMake(CGRectGetMaxX(taskCell.frame) - 40, taskCell.pointsLabel!.center.y)
            let from = taskCell.pointsLabel.superview!.convertPoint(originPoint, toView: rootView)
            let to = CGPointMake(CGRectGetMaxX(taskCell.frame) - 16, 40)
            
            let result = Game.onTaskCompletion(points)
            Score.appendToHistory(task.title!, points: result.points, multiplier: result.multiplier)
            
            AnimationWindow.sharedInstance.runPointsAnimation(from, to: to, points:result.points)
            if result.multiplier > 1 {
                
                AnimationWindow.sharedInstance.runPositionedAnimation(from, withText: "x\(result.multiplier)")
            }
            
            Chirp.sharedManager.playSoundType(.Done)
            
            fetchedResultsController.managedObjectContext.deleteObject(task)
            
            UIView.animateWithDuration(0.2) { // animate the points label disappearing softly
                taskCell.pointsLabel.alpha = 0
                taskCell.pointsLabel.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }
            
        case .PastThresholdRight:
            
            if let isReady = task.isReadyForCompletion?.boolValue
                where !isReady {
                
                if navigationController?.viewControllers.last == self {
                    
                    Chirp.sharedManager.playSoundType(.Settings)
                    performSegueWithIdentifier("showDetail", sender: cell)
                }
            }
            
        default: break
            
        }
        
    }
    
}