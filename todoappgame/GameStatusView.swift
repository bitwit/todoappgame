
import UIKit

class GameStatusView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextTaskProgressView: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Notifications.observe(self, selector: #selector(onReset), type: .New)
        Notifications.observe(self, selector: #selector(onTick), type: .Tick)
    }
    
    deinit {
        Notifications.removeObserver(self)
    }
    
    func prepare() {
    
        titleLabel.textColor = Colors.scheme.textColor
        let newProgress = Float(Game.time / Game.maxTime)
        progressView.setProgress(newProgress, animated: false)
    }
    
    func onReset() {
        
        progressView.setProgress(0, animated: true)
    }
    
    func onTick() {
        
        let newProgress = Float(Game.time / Game.maxTime)
        progressView.setProgress(newProgress, animated: true)
        
        let newTaskProgress = Float(Game.timeSinceLastTaskAdded / Game.addTaskInterval)
        nextTaskProgressView.setProgress(newTaskProgress, animated: false )
    }
}
