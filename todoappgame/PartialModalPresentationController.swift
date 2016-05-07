
import UIKit

class PartialModalPresentationController: UIPresentationController {
    
    var dimmingView: UIView!
    var presentedViewSize = CGSizeMake(320, 568)
    
    init(presentedViewController: UIViewController, presentingViewController: UIViewController, blurStyle:UIBlurEffectStyle) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        self.prepareDimmingView(blurStyle)
    }
    
    //MARK: Background View related
    
    func prepareDimmingView(blurEffectStyle:UIBlurEffectStyle) {
        dimmingView = UIView(frame: UIScreen.mainScreen().bounds)
        dimmingView.backgroundColor = Colors.scheme.base
//        dimmingView = UIImageView(image: AppUtility.getCurrentScreenShot())
//        AppUtility.addBlur(dimmingView, style: blurEffectStyle)
        dimmingView.userInteractionEnabled = true
    }
    
    func dimmingViewTapped(gesture: UIGestureRecognizer) {
        if gesture.state == .Recognized {
            self.presentingViewController.dismissViewControllerAnimated(true) {}
        }
    }
    
    
    //MARK: Overrides
    
    override func presentationTransitionWillBegin() {
        // Here, we'll set ourselves up for the presentation
        let containerView: UIView = self.containerView!
        let presentedViewController: UIViewController = self.presentedViewController
        // Make sure the dimming view is the size of the container's bounds, and fully transparent
        self.dimmingView.frame = containerView.bounds
        self.dimmingView.alpha = 0.0
        // Insert the dimming view below everything else
        containerView.insertSubview(self.dimmingView, atIndex: 0)
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext) -> Void in
                // Fade the dimming view to be fully visible
                self.dimmingView.alpha = 0.80
                }, completion: nil)
        }
        else {
            self.dimmingView.alpha = 0.80
        }
    }
    
    override func dismissalTransitionWillBegin() {
        // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView.alpha = 0.0
                }) { _ in }
        }
        else {
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        // When we adapt to a compact width environment, we want to be over full screen
        return .OverFullScreen
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewSize
    }
    
    override func containerViewWillLayoutSubviews() {
        // Before layout, make sure our dimmingView and presentedView have the correct frame
        self.dimmingView.frame = self.containerView!.bounds
        self.presentedView()!.frame = self.frameOfPresentedViewInContainerView()
        
        // Do configuration for the presented view here
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        // This is a full screen presentation
        return true
    }

    override func frameOfPresentedViewInContainerView() -> CGRect {
        // Return a rect with the same size as -sizeForChildContentContainer:withParentContainerSize:, and centered
        var presentedViewFrame: CGRect = CGRectZero
        let containerBounds: CGRect = self.containerView!.bounds
        presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerBounds.size)
        
        //Center on screen
        presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
        presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height) / 2
        
        return presentedViewFrame
    }

}