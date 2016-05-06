
import UIKit

class BorderedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.borderWidth = 1
        layer.borderColor = titleLabel?.textColor.CGColor ?? UIColor.blackColor().CGColor
        layer.cornerRadius = 3
        
    }

}