/*:
# PartialModalAnimatedTransitioning
- Handles the in and out animation sequence for the partial modal
*/
import UIKit
class PartialModalAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation: Bool!
    
    weak var toVC: UIViewController!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.7
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Here, we perform the animations necessary for the transition
        let fromVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView: UIView = fromVC.view
        toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView: UIView = toVC.view
        
        toVC.beginAppearanceTransition(true, animated: true)
        
        let containerView: UIView = transitionContext.containerView()!
        let isPresentation: Bool = self.isPresentation
        if isPresentation {
            containerView.addSubview(toView)
        }
        let animatingVC: UIViewController = isPresentation ? toVC : fromVC
        let animatingView: UIView = animatingVC.view
        let appearedFrame: CGRect = transitionContext.finalFrameForViewController(animatingVC)
        
        // Our dismissed frame is the same as our appeared frame, but off the right edge of the container
        var dismissedFrame: CGRect = appearedFrame
        dismissedFrame.origin.y += containerView.frame.height //dismissedFrame.size.width
        
        let initialFrame: CGRect = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame: CGRect = isPresentation ? appearedFrame : dismissedFrame
        animatingView.frame = initialFrame
        
        // Animate using the duration from -transitionDuration:
        UIView.animateWithDuration(
            self.transitionDuration(transitionContext),
            delay: 0,
            usingSpringWithDamping: 10.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {() -> Void in
                animatingView.frame = finalFrame
            }, completion: {(finished: Bool) -> Void in
                // If we're dismissing, remove the presented view from the hierarchy
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                // We need to notify the view controller system that the transition has finished
                transitionContext.completeTransition(true)
        })
    }
    
    func animationEnded(transitionCompleted: Bool) {
        toVC.endAppearanceTransition()
    }
}