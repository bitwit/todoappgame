
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
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let view = self.rootViewController!.view
            let degrees = 360 / points
            
            for i in 0..<points {
                // calculate random angle if there arent many points, or uniform circular for more than 4
                let angle:Double = points > 4 ? Double(i * degrees): Double(arc4random_uniform(360))
                let particle = PointsParticleAnimation(from: from, to: to, angle: angle)
                view.addSubview(particle)
            }
        }
    }
    
    func runPositionedAnimation(from:CGPoint, withText text:String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let label = UILabel(frame: CGRectMake(from.x - 50, from.y - 20, 100, 40))
            label.font = UIFont.systemFontOfSize(32)
            label.text = text
            label.textColor = Colors.scheme.danger
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
    
    func runAnnouncementAnimation(text:String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let screenRect = UIScreen.mainScreen().bounds
            let label = UILabel(frame: CGRectMake(0, 0, screenRect.width, screenRect.height))
            label.center = CGPointMake(CGRectGetMidX(screenRect), CGRectGetMidY(screenRect) / 2)
            
            label.font = UIFont.systemFontOfSize(64)
            label.text = text
            label.textColor = Colors.scheme.danger
            label.textAlignment = .Center
            label.alpha = 0
            self.rootViewController!.view.addSubview(label)
            
            UIView.animateWithDuration(0.2, animations: {
                
                label.alpha = 1
                label.transform = CGAffineTransformMakeTranslation(0, -4)
                
                }, completion: { _ in
                    
                    UIView.animateWithDuration(2, animations: {
                        
                        label.alpha = 0
                        label.transform = CGAffineTransformMakeTranslation(0, -20)
                        }, completion: { _ in
                            label.removeFromSuperview()
                    })
            })
        }
    }
    
}


