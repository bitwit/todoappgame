
import UIKit

class IntroductionViewController: MenuViewController {
    
    @IBOutlet weak var startButton: BorderedButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        highScoreLabel.text = "Highscore: \(Score.highScore)"
    }

    @IBAction func startGame(sender: AnyObject) {
        
        Game.new()
    }
}
