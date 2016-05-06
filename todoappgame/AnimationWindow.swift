
import UIKit

final class AnimationWindow: UIWindow {
    
    static let sharedInstance = AnimationWindow()
    
    init () {
        let bounds = UIScreen.mainScreen().bounds
        super.init(frame: bounds)
        self.windowLevel = UIWindowLevelStatusBar
        self.hidden = false
        self.rootViewController = UIViewController()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return nil
    }
    
    func runPointsAnimation(from:CGPoint, to:CGPoint, points:Int) {
        guard points >= 1 else {
            return
        }
        let view = self.rootViewController!.view
        let degrees = 360 / points
        for i in 0..<points {
            let angle:Double = Double(i * degrees)
            //TODO: Proportional duration. Get all distances first then set desired proportional durations from a max value.
            let particle = PointsParticleAnimation(from: from, to: to, angle: angle)
            view.addSubview(particle)
        }
    }
    
}


