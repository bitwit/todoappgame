
import Foundation

struct QueuedTask {
    let title:String
    let subtasks:[String]
    let points:Int
}

class TaskManager {
    
    enum Error: ErrorType {
        case CanNotLoad(String)
    }
    
    static let sharedInstance = TaskManager()
    
    // Data
    private(set) var allLoadedTasks: [QueuedTask] = []
    
    private(set) var simpleTasks:[QueuedTask] = []
    private(set) var complexTasks:[QueuedTask] = []
    
    init() {
        
        let path = NSBundle.mainBundle().pathForResource("data.json", ofType: nil)!
        let fileManager = NSFileManager.defaultManager()
        let data:NSData? = fileManager.contentsAtPath(path)
        let jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        
        let allTasks = (jsonData as! Array<[String:AnyObject]>)
        
        
        allLoadedTasks = allTasks.flatMap {
            taskDict in
            return taskDict.flatMap {
                (title, data) in
                return try! self.loadData(title, data: data)
            }
        }
    }
    
    func reset() {
        
        let tasks = allLoadedTasks.shuffle()
        
        simpleTasks = tasks.filter { $0.points == 1 }
        complexTasks = tasks.filter { $0.points > 1 }
    }
    
    func pop() -> QueuedTask {
        
        // 25% chance to pop a complex task, until depleted
        if arc4random_uniform(100) <= 25 {
            return complexTasks.popLast() ?? simpleTasks.removeLast()
        }
        
        return simpleTasks.removeLast()
    }
    
    func loadData(title:String, data:AnyObject) throws -> QueuedTask {
        
        guard let d = data as? [String: AnyObject] else {
            throw Error.CanNotLoad(title + " does not fit format")
        }
        
        let points:Int
        if let p = d["points"] as? Int {
            points = p
        } else {
            points = 1
        }
        
        let subtasks:[String]
        if let s = d["subtasks"] as? [String] {
            
            subtasks = s
        } else {
            
            subtasks = []
        }
        
        return QueuedTask(title: title, subtasks: subtasks, points: points)
    }
    
}
