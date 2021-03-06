//
//  ScoreView.swift
//  todoappgame
//
//  Created by Kyle Newsome on 2016-05-06.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    
    var pointsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    
    var navigationBar:UINavigationBar?
    var currentPoints:Int = 0 //What's currently displayed to the user, not necessarily what is the full amount
    
    init (navigationBar:UINavigationBar?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        
        pointsLabel.textColor = Colors.scheme.textColor
        pointsLabel.text = String(self.currentPoints)
        pointsLabel.textAlignment = .Center
        
        addSubview(self.pointsLabel)
        
        self.navigationBar = navigationBar
        navigationBar?.addSubview(self)
        
        calculatePosition()
        
        Notifications.observe(self, selector: #selector(onIncrementPointsDisplay), type: .IncrementPoints)
        Notifications.observe(self, selector: #selector(onDecrementPointsDisplay), type: .DecrementPoints)
        Notifications.observe(self, selector: #selector(onReset), type: .Reset)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(navigationBar:nil)
    }
    
    func calculatePosition () {
        self.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: self.superview, attribute: .TopMargin, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: self.superview, attribute: .TrailingMargin, multiplier: 1.0, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 32)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 32)
        self.superview?.addConstraints([topConstraint, rightConstraint, widthConstraint, heightConstraint])
    }
    
    func onReset() {
        currentPoints = 0
        pointsLabel.text = String(currentPoints)
    }
    
    func onIncrementPointsDisplay () {
        currentPoints += 1
        pointsLabel.text = String(currentPoints)
        animatePointsScaleUp()
        Chirp.sharedManager.playSoundType(.Point)
    }
    
    func onDecrementPointsDisplay () {
        
        currentPoints -= 1
        pointsLabel.text = String(currentPoints)
        shakeEffect()
        
        // Chirp.sharedManager.playSoundType(.Point)
    }
    
    private func shakeEffect() {
        
        let animation = CABasicAnimation(keyPath: "position")
        
        animation.duration = 0.1
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(center.x - 5, center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(center.x + 5, center.y))
        
        layer.addAnimation(animation, forKey: "position")
    }
    
    func animatePointsScaleUp() {
        UIView.animateWithDuration(0.06,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.pointsLabel.transform = CGAffineTransformMakeScale(1.5, 1.5)
            },
                                   completion: { finished in
                                    self.animatePointsScaleDown()
        })
    }
    
    func animatePointsScaleDown() {
        UIView.animateWithDuration(0.06,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.pointsLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
            },
                                   completion: nil)
    }
    
}