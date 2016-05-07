
import UIKit

class MenuViewController: UIViewController {
    
    var modalTransitioner: PartialModalTransitioner = PartialModalTransitioner()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalTransitioner.presentedViewSize = preferredContentSize
        transitioningDelegate = modalTransitioner
        modalPresentationStyle = .Custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.borderColor = Colors.scheme.inactive.CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
    }
    
}
