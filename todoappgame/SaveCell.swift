
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
        saveButton.backgroundColor = UIColor.greenColor()
        
        // Start moving the button once we are 35% into the game
        if Game.time / Game.maxTime > 0.35 {
            animateButton()
        }
    }
    
    func animateButton() {
    
        animateDown()
    }
    
    func durationForAnimation() -> NSTimeInterval {
        
        // Start moving the button FASTER once we are 70% into the game
        if Game.time / Game.maxTime > 0.70 {
            return 0.5
        }
        return 1
    }
    
    func animateDown() {
        
        UIView.animateWithDuration(durationForAnimation(), delay: 0, options: .CurveEaseInOut, animations: {
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            this.saveButton.center = CGPointMake(this.saveButton.center.x, this.saveButton.center.y + 210)
            
            }, completion: {
                [weak self] _ in
                self?.animateUp()
            })
    }
    
    func animateUp() {
        
        UIView.animateWithDuration(durationForAnimation(), delay: 0, options: .CurveEaseInOut, animations: {
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            this.saveButton.center = CGPointMake(this.saveButton.center.x, this.saveButton.center.y - 210)
            
            }, completion: {
                [weak self] _ in
                self?.animateDown()
            })
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        
        let touchLocation = recognizer.locationInView(self)
        let buttonRect = saveButton.layer.presentationLayer()!.frame
        
        if buttonRect.contains(touchLocation) {
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
