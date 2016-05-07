
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
    
    func runMultiplierAnimation(from:CGPoint, withValue value:Int) {
        
        let label = UILabel(frame: CGRectMake(from.x - 50, from.y - 20, 100, 40))
        label.font = UIFont.systemFontOfSize(32)
        label.text = "x\(value)"
        label.textColor = UIColor.orangeColor()
        label.textAlignment = .Center
        label.alpha = 0
        self.rootViewController!.view.addSubview(label)
        
        UIView.animateWithDuration(0.2, animations: {
            
            label.alpha = 1
            label.transform = CGAffineTransformMakeTranslation(0, -4)
            
            }, completion: { _ in
        
            UIView.animateWithDuration(1, animations: {
                
                label.alpha = 0
                label.transform = CGAffineTransformMakeTranslation(0, -20)
                }, completion: { _ in
                    label.removeFromSuperview()
            })
        })
    }
    
}


