
import UIKit

class PartialModalTransitioner: NSObject, UIViewControllerTransitioningDelegate {
    
    var presentedViewSize = CGSizeMake(320, 568)
    var blurEffectStyle = UIBlurEffectStyle.Dark
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let pc = PartialModalPresentationController(presentedViewController: presented, presentingViewController: presenting, blurStyle: blurEffectStyle)
        pc.presentedViewSize = presentedViewSize
        return pc
    }
    
    func animationController() -> PartialModalAnimatedTransitioning {
        let animationController: PartialModalAnimatedTransitioning = PartialModalAnimatedTransitioning()
        return animationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: PartialModalAnimatedTransitioning = self.animationController()
        animationController.isPresentation = true
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: PartialModalAnimatedTransitioning = self.animationController()
        animationController.isPresentation = false
        return animationController
    }
}

