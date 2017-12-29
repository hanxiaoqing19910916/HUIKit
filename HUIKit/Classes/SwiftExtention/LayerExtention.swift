//
//  LayerExtention.swift
//
//  Created by hanxiaoqing on 2017/11/7.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

//https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1


extension CALayer: LayerAnimation { }
extension NSView: LayerAnimation { }



public typealias completionBlock = ((Bool, CAAnimation) -> Void)?

@objc public class CALayerAnimationDelegate: NSObject, CAAnimationDelegate {
    var completion: completionBlock
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


public class AnimationConfig: NSObject {
    var removeOnCompletion: Bool
    var additive: Bool
    public override init() {
        self.removeOnCompletion  = true
        self.additive  = true
        super.init()
    }
}

public protocol LayerAnimation { }

public extension LayerAnimation {

    public func rotateCenterAnimate(from: CGFloat, to: CGFloat, duration: Double, bounce: Bool = true, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        let fromValue = from * CGFloat.pi / 180
        let toValue = to * CGFloat.pi / 180
        let animation = animate(keyPath: "transform.rotation.z", from: fromValue, to: toValue, duration: duration, bounce: bounce, completion: completion, config: config)
        addAnimation(anmi: animation, key: "animateRotateCenter")
    }
    
    public func alphaAnimate(from: CGFloat, to: CGFloat, duration: Double, bounce: Bool = false, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        let animation = animate(keyPath: "opacity", from: from, to: to, duration: duration, bounce: bounce, completion: completion, config: config)
        addAnimation(anmi: animation, key: "alphaAnimate")
    }
    
    
    public func scaleAnimate(from: CGFloat, to: CGFloat, duration: Double, bounce: Bool = true, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        let animation = animate(keyPath: "transform.scale", from: from, to: to, duration: duration, bounce: bounce, completion: completion, config: config)
        addAnimation(anmi: animation, key: "saleAnimate")
    }
    
    
    public func positionAnimate(from: CGPoint, to: CGPoint, duration: Double, bounce: Bool = true, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        let animation = animate(keyPath: "position", from: from, to: to, duration: duration, bounce: bounce, completion: completion, config: config)
        addAnimation(anmi: animation, key: "positionAnimate")
    }
    
    
    public func sizeAnimate(from: CGSize, to: CGSize, duration: Double, bounce: Bool = true, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        let animation = animate(keyPath: "bounds.size", from: from, to: to, duration: duration, bounce: bounce, completion: completion, config: config)
        addAnimation(anmi: animation, key: "sizeAnimate")
    }
    
    public func frameAnimate(from: CGRect, to: CGRect, duration: Double, bounce: Bool = true, completion: completionBlock = nil, config: AnimationConfig = AnimationConfig()) {
        positionAnimate(from: CGPoint(x: from.midX, y: from.midY), to: CGPoint(x: to.midX, y: to.midY), duration: duration, bounce: bounce, completion: completion, config: config)
        sizeAnimate(from: from.size, to: to.size, duration: duration, bounce: bounce, completion: completion, config: config)
    }
    
    
    public func shake(_ duration: Double) {
        var positionX: CGFloat = 0.0
        var positionY: CGFloat = 0.0
        
        if let layer = self as? CALayer {
            positionX = layer.position.x
            positionY = layer.position.y
        }
        if let view = self as? NSView {
            view.wantsLayer = true
            positionX = (view.layer?.position.x)!
            positionY = (view.layer?.position.y)!
        }
        
        let a: CGFloat = 6
        let fromP = CGPoint(x: -a + positionX, y: positionY)
        let toP = CGPoint(x: a + positionX, y: positionY)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration;
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.autoreverses = true
        animation.fromValue = fromP
        animation.toValue = toP
        addAnimation(anmi: animation, key: "shake")
    }
    
    
    
    public func makeCAnimation(_ path:String, bounce: Bool) -> CABasicAnimation {
        if bounce == false {
            return CABasicAnimation(keyPath: path)
        } else {
            if #available(OSX 10.11, *) {
                let springAnimation: CASpringAnimation = CASpringAnimation(keyPath: path)
                springAnimation.mass = 10
                springAnimation.stiffness = 700.0
                springAnimation.damping = 60.0
                return springAnimation;
            } else {
                return CABasicAnimation(keyPath: path)
            }
        }
    }
    
    public func animate(keyPath: String, from: Any, to: Any, duration: Double, bounce: Bool, completion: completionBlock, config: AnimationConfig) -> CABasicAnimation {
        let animation = makeCAnimation(keyPath, bounce: bounce)
        animation.fromValue = from
        animation.toValue = to
        animation.fillMode = kCAFillModeForwards
        animation.duration = duration
        animation.isRemovedOnCompletion = config.removeOnCompletion
        animation.isAdditive = config.additive
        animation.delegate = CALayerAnimationDelegate(completion: completion)
        return animation
    }
    
    
    private func addAnimation(anmi: CAAnimation, key: String) {
        if let layer = self as? CALayer {
            layer.add(anmi, forKey: key)
        }
        if let view = self as? NSView {
            view.wantsLayer = true
            view.layer?.add(anmi, forKey: key)
        }
    }
    
}

