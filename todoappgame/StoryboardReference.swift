
import UIKit

public struct StoryboardReference {
    
    let storyboard:String
    let controller:String
    
    init(_ s:String, _ c:String) {
        
        storyboard = s
        controller = c
    }
    
    func instantiate() -> UIViewController {
    
        let storyboard = UIStoryboard(name: self.storyboard, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(self.controller)
    }
}