
import UIKit

class IntroductionViewController: MenuViewController {
    
    @IBOutlet weak var startButton: BorderedButton!

    @IBAction func startGame(sender: AnyObject) {
        
        Notifications.post(.New)
    }
}
