
import UIKit

class PauseViewController: MenuViewController {

    @IBOutlet weak var resumeButton: BorderedButton!
    @IBOutlet weak var quitButton: BorderedButton!
    
    
    @IBAction func resume(sender: AnyObject) {
        
        Game.resume()
    }
    
    @IBAction func quit(sender: AnyObject) {
    
        Game.end()
    }
    
}