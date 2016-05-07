
import Foundation
import UIKit

func sqr(x:CGFloat) -> CGFloat { return x * x }

func distance(points:[CGPoint]) -> CGFloat {
    var distance:CGFloat = 0
    for i in 0..<(points.count - 1) {
        let a = points[i]
        let b = points[i+1]
        distance += sqrt( sqr(b.x - a.x) + sqr(b.y - a.y))
    }
    return distance
}

func degreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func createCurvePoint(a:CGPoint, b:CGPoint, angle:Double) -> CGPoint {
    let radians = CGFloat(degreesToRadians(angle))
    var newX = a.x
    newX += (b.x - a.x) * cos(radians)
    newX -= (b.y - a.y) * sin(radians)
    var newY = a.y
    newY += (b.x - a.x) * sin(radians)
    newY += (b.y - a.y) * cos(radians)
    return CGPointMake(newX, newY)
}

func createBezierPath(from:CGPoint, to:CGPoint, curve:CGPoint) -> UIBezierPath {
    let bezierPath = UIBezierPath()
    bezierPath.moveToPoint(from)
    bezierPath.addQuadCurveToPoint(to, controlPoint: curve)
    return bezierPath
}

func createShapeLayer(path:CGPath) -> CAShapeLayer {
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path
    shapeLayer.fillColor = UIColor.whiteColor().CGColor
    shapeLayer.strokeColor = UIColor.blackColor().CGColor
    shapeLayer.lineWidth = 1.0
    return shapeLayer
}

class PointsParticleAnimation: UIView {
    
    var animationGroup:CAAnimationGroup?
    var path:CGPath!
    var duration:Double!
    
    init(from:CGPoint, to:CGPoint, angle:Double) {
        super.init(frame: CGRectMake(from.x, from.y, 10, 10))
        
        let curve = createCurvePoint(from, b: CGPointMake(from.x, from.y - 45), angle: angle)
        
        self.duration = 0.2 + min(Double(distance([from, curve, to]) / 500), 1) // - Double(arc4random()) / 2 / Double(UINT32_MAX)
        self.path = createBezierPath(from, to: to, curve: curve).CGPath
        self.center = from
        self.backgroundColor = Colors.scheme.warning
        self.layer.borderColor = Colors.scheme.danger.CGColor
        self.layer.borderWidth = 1
        self.createAnimation(path, layer: self.layer)
        self.layer.position = to
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //print("Points animation deinit")
    }
    
    func createAnimation(path:CGPath, layer:CALayer) {
        let animationGroup = CAAnimationGroup()
        animationGroup.delegate = self
        animationGroup.duration = self.duration
        animationGroup.repeatCount = 0;
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        animation.rotationMode = kCAAnimationRotateAuto
        animation.duration = self.duration
        
        //tweak help here: http://netcetera.org/camtf-playground.html
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.42, 0.58, 0)
        animation.timingFunction = timingFunction
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        animationGroup.animations = [animation]
        
        layer.addAnimation(animationGroup, forKey: "Burst")
        self.animationGroup = animationGroup
    }
    
    override func animationDidStart(anim: CAAnimation) {
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        self.animationGroup?.delegate = nil
        self.removeFromSuperview()
        
        Notifications.post(.IncrementPoints)
    }
    
}
