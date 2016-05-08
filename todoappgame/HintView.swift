
import UIKit

class HintView: UIView {
    
    @IBOutlet weak var animateableImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func animateImage() {
        
        UIView.animateWithDuration(0.65, delay: 0.2, options: .CurveEaseInOut, animations: {
            
            [weak self] in
            
            guard let this = self else {
                return
            }
            
            let translation:CGFloat = this.restorationIdentifier == "hint2" ? -50 : 50
            
            this.animateableImageView.transform = CGAffineTransformMakeTranslation(translation, 0)
            
            }, completion: {
                
                [weak self] _ in
                
                guard let this = self else {
                    return
                }
                
                this.animateableImageView.transform = CGAffineTransformMakeTranslation(0, 0)
                this.animateImage()
            })
    }
    
}