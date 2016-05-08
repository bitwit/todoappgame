
import UIKit

class HintView: UIView {
    
    @IBOutlet weak var animateableImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func animateImage() {
        
        UIView.animateWithDuration(0.65, delay: 0.5, options: .CurveLinear, animations: {
            
            let translation:CGFloat = self.restorationIdentifier == "hint2" ? -50 : 50
            
            self.animateableImageView.transform = CGAffineTransformMakeTranslation(translation, 0)
            
        }, completion: nil)
    }
    
}