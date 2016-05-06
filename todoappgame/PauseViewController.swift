
import UIKit

class PauseViewController: MenuViewController {

    @IBOutlet weak var resumeButton: BorderedButton!
    @IBOutlet weak var quitButton: BorderedButton!
    
    
    @IBAction func resume(sender: AnyObject) {
        
        Notifications.post(.Resume)
    }
    
    @IBAction func quit(sender: AnyObject) {
    
        Notifications.post(.End)
    }
    
}