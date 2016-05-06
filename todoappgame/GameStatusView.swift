
import UIKit

class GameStatusView: UIView {

    @IBOutlet weak var progressView: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Notifications.observe(self, selector: #selector(onReset), type: .New)
        Notifications.observe(self, selector: #selector(onTick), type: .Tick)
    }
    
    func onReset() {
        progressView.setProgress(0, animated: true)
    }
    
    func onTick() {
        let newProgress = Float(Game.time / Game.maxTime)
        progressView.setProgress(newProgress, animated: true)
    }
}
