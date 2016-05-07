
import UIKit

class SaveCell: UITableViewCell {

    @IBOutlet weak var saveButton: UIButton!
    
    var tapRecognizer: UITapGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        let r = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        r.delegate = self
        tapRecognizer = r
        contentView.addGestureRecognizer(r)
    }
    
    func enable() {
        
        guard !saveButton.enabled else {
            return
        }
        
        saveButton.enabled = true
        saveButton.userInteractionEnabled = false
        saveButton.backgroundColor = Colors.scheme.success
        
        // Start moving the button once we are 35% into the game
        if Game.stage >= 2 {
            animateButton()
        }
    }
    
    func animateButton() {
    
        animateDown()
    }
    
    func durationForAnimation() -> NSTimeInterval {
        if Game.stage >= 3 {
            return 0.6
        }
        return 1
    }
    
    func animateDown() {
        
        UIView.animateWithDuration(durationForAnimation(), delay: 0, options: .CurveLinear, animations: {
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            this.saveButton.center = CGPointMake(this.saveButton.center.x, this.saveButton.center.y + 210)
            
            if Game.stage >= 3 {
                this.saveButton.transform = CGAffineTransformMakeRotation(CGFloat(180.degreesToRadians))
            }
            
            }, completion: {
                [weak self] _ in
                self?.animateUp()
            })
    }
    
    func animateUp() {
        
        UIView.animateWithDuration(durationForAnimation(), delay: 0, options: .CurveLinear, animations: {
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            this.saveButton.center = CGPointMake(this.saveButton.center.x, this.saveButton.center.y - 210)
            
            if Game.stage >= 3 {
                this.saveButton.transform = CGAffineTransformMakeRotation(CGFloat(0.degreesToRadians))
            }
            
            }, completion: {
                [weak self] _ in
                self?.animateDown()
            })
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        
        guard saveButton.enabled else {
            return
        }
        
        let touchLocation = recognizer.locationInView(self)
        let buttonRect = saveButton.layer.presentationLayer()!.frame
        
        if buttonRect.contains(touchLocation) {
            saveButton.backgroundColor = Colors.scheme.info
            saveButton.sendActionsForControlEvents(.TouchUpInside)
        }
    }
}

extension SaveCell {
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }

}
