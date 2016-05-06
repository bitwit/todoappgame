
import UIKit

class GameOverViewController: MenuViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tryAgainButton: BorderedButton!
    @IBOutlet weak var quitButton: BorderedButton!
    
    override func viewWillAppear(animated: Bool) {
        
        pointsLabel.text = String(Game.score)
    }
    
    @IBAction func tryAgain(sender: AnyObject) {
        
        Notifications.post(.New)
    }
    
    @IBAction func quit(sender: AnyObject) {
        
        Notifications.post(.End)
    }
}
