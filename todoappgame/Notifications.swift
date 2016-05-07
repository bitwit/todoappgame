
import Foundation

enum NotificationType: String {
    case New = "shouldStartNewGame"
    case Pause = "shouldPauseGame"
    case Resume = "shouldResumeGame"
    case Reset = "shouldResetGame"
    case End = "shouldEndGame"
    
    case Tick = "gameTick"
    
    case AddTask = "shouldAddTask"
    case TaskCompletion = "taskDidComplete"
    case IncrementPoints = "shouldIncrementPointsDisplay"
}

struct Notifications {

    static func observe(observer: AnyObject, selector: Selector, type: NotificationType) {
        
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: type.rawValue, object: nil)
    }
    
    static func post(type: NotificationType) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(type.rawValue, object: nil)
    }

}