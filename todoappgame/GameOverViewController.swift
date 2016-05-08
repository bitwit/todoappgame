
import UIKit

class GameOverViewController: MenuViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var quitButton: BorderedButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        
        pointsLabel.alpha = 0
        highScoreLabel.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let isNewHighScore = Score.total > Score.highScore
        
        Score.saveFinalScore()
        pointsLabel.text = String(Score.total)
        highScoreLabel.text = isNewHighScore ? "NEW HIGH SCORE!" : "Highscore: \(Score.highScore)"
        
        UIView.animateWithDuration(0.3) {
            
            self.pointsLabel.alpha = 1.0
            self.highScoreLabel.alpha = 1.0
        }
    }
    
    @IBAction func quit(sender: AnyObject) {
        
        Game.end()
    }
}
