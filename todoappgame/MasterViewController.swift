
import UIKit
import CoreData
import BWSwipeRevealCell

class MasterViewController: UITableViewController {
    
    private var isFirstAppearance = true
    
    // Data
    var managedObjectContext: NSManagedObjectContext? = nil
    var allTasks: Array<[String:AnyObject]>
    var possibleTasks: Array<[String:AnyObject]> = []
    
    // Timer
    var gameTimer: NSTimer?
    
    required init?(coder aDecoder: NSCoder) {
        
        let path = NSBundle.mainBundle().pathForResource("data.json", ofType: nil)!
        let fileManager = NSFileManager.defaultManager()
        let data:NSData? = fileManager.contentsAtPath(path)
        let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        
        allTasks = (jsonData as! Array<[String:AnyObject]>)
        
        print("TOTAL TASKS:", allTasks.count)
        
        super.init(coder:aDecoder)
        
        Notifications.observe(self, selector: #selector(newGame), type: .New)
        Notifications.observe(self, selector: #selector(pause), type: .Pause)
        Notifications.observe(self, selector: #selector(resume), type: .Resume)
        Notifications.observe(self, selector: #selector(endGame), type: .End)
        Notifications.observe(self, selector: #selector(tick), type: .AddTask)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(menuButtonPressed))
        
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
    
    func displayIntro() {
        
        let intro = StoryboardReference("Main", "Introduction").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func displayGameOver() {
        
        let intro = StoryboardReference("Main", "GameOver").instantiate()
        presentViewController(intro, animated: true, completion: nil)
    }
    
    func newGame() {
        
        fetchedResultsController.managedObjectContext.rollback()
        possibleTasks = allTasks.shuffle()
        
        dismissViewControllerAnimated(true) {
        
            Game.start()
            self.insertNewObject(8)
            self.navigationController?.popToRootViewControllerAnimated(true)
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
                self.displayIntro()
            }
        } else {
            
            displayGameOver()
        }
        
    }
    
    func tick() {
        
        insertNewObject()
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
            
            guard let taskData = possibleTasks.popLast() else {
                return
            }
            
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let task:Task = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Task
            
            taskData.forEach { (title, data) in
                task.timeStamp = NSDate()
                task.title = title
                task.loadData(data)
            }
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
        
        c.bgViewLeftImage = UIImage(named:"icon-checkmark")!
        c.bgViewLeftColor = Colors.scheme.success
        c.bgViewRightImage = UIImage(named:"icon-cog")!
        c.bgViewRightColor = Colors.scheme.info
        c.type = .SpringRelease
        c.delegate = self
        
        c.titleLabel.textColor = Colors.scheme.textColor
        c.titleLabel.text = task.title
        
        c.pointsLabel.alpha = 1
        c.pointsLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
        c.pointsLabel.text = task.points!.stringValue
        c.pointsLabel.textColor = Colors.scheme.textColor
        
        if task.isReadyForCompletion?.boolValue == true {
            c.revealDirection = .Left
            c.contentView.backgroundColor = Colors.scheme.base
        } else {
            c.revealDirection = .Right
            c.contentView.backgroundColor = Colors.scheme.info
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
    
}

extension MasterViewController: BWSwipeRevealCellDelegate {
    
    func swipeCellDidCompleteRelease(cell: BWSwipeCell) {
        
        guard let taskCell = cell as? TaskCell
            where taskCell.state != .Normal
            else {
                return
        }
        
        switch cell.state {
        case .PastThresholdLeft:
            
            guard let idx = tableView.indexPathForCell(cell),
                let task = fetchedResultsController.fetchedObjects![idx.row] as? Task
                else {
                    return
            }
            
            let points = Int(task.points!.intValue)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let rootView = appDelegate.window!
            
            
            let originPoint = CGPointMake(CGRectGetMaxX(taskCell.frame) - 16, taskCell.pointsLabel!.center.y)
            let from = taskCell.pointsLabel.superview!.convertPoint(originPoint, toView: rootView)
            let to = CGPointMake(from.x, 40)
            
            let result = Game.onTaskCompletion(points)
            AnimationWindow.sharedInstance.runPointsAnimation(from, to: to, points:result.points)
            if result.multiplier > 1 {
                AnimationWindow.sharedInstance.runMultiplierAnimation(from, withValue:result.multiplier)
            }
            
            Chirp.sharedManager.playSoundType(.Done)
            
            fetchedResultsController.managedObjectContext.deleteObject(task)
            
            UIView.animateWithDuration(0.2) {
                taskCell.pointsLabel.alpha = 0
                taskCell.pointsLabel.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }
            
        case .PastThresholdRight:
            
            performSegueWithIdentifier("showDetail", sender: cell)
            
        default: break
        }
        
    }
    
}