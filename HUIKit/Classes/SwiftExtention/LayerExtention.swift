//
//  LayerExtention.swift
//
//  Created by hanxiaoqing on 2017/11/7.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

//https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1

public class AnimationConfig: NSObject {
    
    var removeOnCompletion: Bool
    var additive: Bool
    
    public override init() {
        self.removeOnCompletion  = true
        self.additive  = true
        super.init()
    }
    
}

public protocol LayerAnimation {
    
    typealias completionBlock = ((Bool, CAAnimation) -> Void)?
    func animateRotateCenter(from: CGFloat, to: CGFloat, duration: Double, completion: completionBlock, config: AnimationConfig)
    
}

public extension LayerAnimation {
    
    private func addAnimation(anmi: CAAnimation) {
        if let layer = self as? CALayer {
            layer.add(anmi, forKey: "transform")
        }
        if let view = self as? NSView {
            view.wantsLayer = true
            view.layer?.add(anmi, forKey: "transform")
        }
    }
    
    
    public func animateRotateCenter(from: CGFloat, to: CGFloat, duration: Double, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        
        let animation = makeSpringBounceAnimation("transform.rotation.z")
        
        animation.fromValue = from * CGFloat.pi / 180
        animation.toValue = to * CGFloat.pi / 180
        
        animation.isRemovedOnCompletion = config.removeOnCompletion
        animation.fillMode = kCAFillModeForwards
        if let completion = completion {
            animation.delegate = CALayerAnimationDelegate(completion: completion)
        }
        animation.speed = Float(animation.duration / duration)
        animation.isAdditive = config.additive
        addAnimation(anmi: animation)
   
    }
    
}

public extension CALayer {
    
    public func disableActions() -> Void {
        self.actions = ["onOrderIn":NSNull(),"sublayers":NSNull(),"bounds":NSNull(),"frame":NSNull(),"position":NSNull(),"contents":NSNull(),"backgroundColor":NSNull(),"border":NSNull(), "shadowOffset": NSNull()]
    }
    
    public func animateBackground() ->Void {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.duration = 0.2
        self.add(animation, forKey: "backgroundColor")
    }
    
    
    public func animateBorder() ->Void {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.2
        self.add(animation, forKey: "borderWidth")
    }
    
    public func animateContents() ->Void {
        let animation = CABasicAnimation(keyPath: "contents")
        animation.duration = 0.2
        self.add(animation, forKey: "contents")
    }
    
}



public let kCAMediaTimingFunctionSpring = "CAAnimationUtilsSpringCurve"

@objc public class CALayerAnimationDelegate: NSObject, CAAnimationDelegate {
    
    var completion: ((Bool, CAAnimation) -> Void)?
    
    public init(completion: ((Bool, CAAnimation) -> Void)?) {
        self.completion = completion
        
        super.init()
    }
    
    @objc public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completion = self.completion {
            completion(flag,anim)
        }
    }
}


public func makeSpringBounceAnimation(_ path:String, _ initialVelocity: CGFloat = 0.0, _ damping: CGFloat = 88.0) -> CABasicAnimation {
    if #available(OSX 10.11, *) {
        let springAnimation: CASpringAnimation = CASpringAnimation(keyPath: path)
        springAnimation.mass = 5.0
        springAnimation.stiffness = 900.0
        springAnimation.damping = damping
        springAnimation.initialVelocity = initialVelocity
        springAnimation.duration = springAnimation.settlingDuration
        springAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        return springAnimation;
    } else {
        let anim:CABasicAnimation = CABasicAnimation(keyPath: path)
        anim.duration = 0.2
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        return anim
    }
}




extension CALayer: LayerAnimation {
    
    
    
//    public func animate(from: AnyObject, to: AnyObject, keyPath: String, timingFunction: String, duration: Double, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
//        if timingFunction == kCAMediaTimingFunctionSpring {
//            let animation = makeSpringBounceAnimation(keyPath)
//            animation.fromValue = from
//            animation.toValue = to
//            animation.isRemovedOnCompletion = removeOnCompletion
//            animation.fillMode = kCAFillModeForwards
//            if let completion = completion {
//                animation.delegate = CALayerAnimationDelegate(completion: completion)
//            }
//            animation.speed = 1.0
//            animation.isAdditive = additive
//            self.add(animation, forKey: keyPath)
//        } else {
//            let animation = CABasicAnimation(keyPath: keyPath)
//            animation.fromValue = from
//            animation.toValue = to
//            animation.duration = duration
//            animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
//            animation.isRemovedOnCompletion = removeOnCompletion
//            animation.fillMode = kCAFillModeForwards
//            animation.speed = 1.0
//            animation.isAdditive = additive
//            if let completion = completion {
//                animation.delegate = CALayerAnimationDelegate(completion: completion)
//            }
//            self.add(animation, forKey: keyPath)
//        }
//    }
//
//
//    public func animateRotateCenter(from: CGFloat, to: CGFloat, duration: Double, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
//
//        //  can select keypath for rotate： transform.rotation.x, transform.rotation.y, transform.rotation.z
//        let animation = makeSpringBounceAnimation("transform.rotation.z")
//
//        animation.fromValue = from * CGFloat.pi / 180
//        animation.toValue = to * CGFloat.pi / 180
//
//        animation.isRemovedOnCompletion = removeOnCompletion
//        animation.fillMode = kCAFillModeForwards
//        if let completion = completion {
//            animation.delegate = CALayerAnimationDelegate(completion: completion)
//        }
//
//        animation.speed = Float(animation.duration / duration)
//        animation.isAdditive = additive
//        self.add(animation, forKey: "transform")
//    }
//
//
//    public func animateAlpha(from: CGFloat, to: CGFloat, duration: Double, timingFunction: String = kCAMediaTimingFunctionEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> ())? = nil) {
//        self.animate(from: NSNumber(value: Float(from)), to: NSNumber(value: Float(to)), keyPath: "opacity", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, completion: completion)
//    }
//
//
//    public func animateScale(from: CGFloat, to: CGFloat, duration: Double, timingFunction: String = kCAMediaTimingFunctionEaseInEaseOut, removeOnCompletion: Bool = true, completion: ((Bool) -> Void)? = nil) {
//        self.animate(from: NSNumber(value: Float(from)), to: NSNumber(value: Float(to)), keyPath: "transform.scale", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, completion: completion)
//    }
//
//    func animatePosition(from: NSPoint, to: NSPoint, duration: Double = 0.2, timingFunction: String = kCAMediaTimingFunctionEaseOut, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
//        self.animate(from: NSValue(point: from), to: NSValue(point: to), keyPath: "position", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
//    }
//
//
//
//    public func animateFrame(from: CGRect, to: CGRect, duration: Double, timingFunction: String, removeOnCompletion: Bool = true, additive: Bool = false, completion: ((Bool) -> Void)? = nil) {
//        self.animatePosition(from: CGPoint(x: from.midX, y: from.midY), to: CGPoint(x: to.midX, y: to.midY), duration: duration, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, additive: additive, completion: nil)
//        self.animate(from: NSValue(size: from.size), to: NSValue(size: to.size), keyPath: "bounds.size", timingFunction: timingFunction, duration: duration, removeOnCompletion: removeOnCompletion, additive: additive, completion: completion)
//    }
    
//    public func shake(_ duration: CFTimeInterval, from: NSPoint, to: NSPoint) {
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = duration;
//        animation.repeatCount = 4
//        animation.autoreverses = true
//        animation.isRemovedOnCompletion = true
//
//        animation.fromValue = NSValue(point: from)
//        animation.toValue = NSValue(point: to)
//
//        self.add(animation, forKey: "position")
//    }
}
