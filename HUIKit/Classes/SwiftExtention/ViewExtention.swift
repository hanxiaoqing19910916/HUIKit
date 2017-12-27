//
//  ViewExtention.swift
//
//  Created by hanxiaoqing on 2017/11/8.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//
import Cocoa

public enum HUIViewContentMode : Int {
    
    case scaleToFill
    
    case scaleAspectFit // contents scaled to fit with fixed aspect. remainder is transparent
    
    case scaleAspectFill // contents scaled to fill with fixed aspect. some portion of content may be clipped.
    
    case center // contents remain same size. positioned adjusted.
    
    public var layerContentGravity: String {
        switch self {
        case .scaleToFill: return kCAGravityResize
        case .scaleAspectFit: return kCAGravityResizeAspect
        case .scaleAspectFill: return kCAGravityResizeAspectFill
        case .center: return kCAGravityCenter
        }
    }
    
}

public extension NSView {
    
    public var contentMode: HUIViewContentMode {
        set {
            if wantsLayer {
                self.layer?.contentsGravity = newValue.layerContentGravity
            }
        }
        get {
            return self.contentMode
        }
    }
    
}

extension NSView: LayerAnimation {
    
    public var snapshot: NSImage {
        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
        cacheDisplay(in: bounds, to: bitmapRep)
        let image = NSImage()
        image.addRepresentation(bitmapRep)
        bitmapRep.size = bounds.size
        return NSImage(data: dataWithPDF(inside: bounds))!
    }
    
    public func _mouseInside() -> Bool {
        if let window = self.window {
            var location:NSPoint = window.mouseLocationOutsideOfEventStream
            location = self.convert(location, from: nil)
            if let view = window.contentView!.hitTest(window.mouseLocationOutsideOfEventStream) {
                if view == self {
                    return NSPointInRect(location, self.bounds)
                } else {
                    var s = view.superview
                    while let sv = s {
                        if sv == self {
                            return NSPointInRect(location, self.bounds)
                        }
                        s = sv.superview
                    }
                }
            }
        }
        return false
    }
    
    public var backingScaleFactor: CGFloat {
        if let window = window {
            return window.backingScaleFactor
        } else {
            return CGFloat(NSScreen.main?.backingScaleFactor ?? 2.0)
        }
    }
    
    public func removeAllSubviews() -> Void {
        while (self.subviews.count > 0) {
            self.subviews[0].removeFromSuperview();
        }
    }
    
    public func isInnerView(_ view: NSView?) -> Bool {
        var inner = false
        for i in 0 ..< subviews.count {
            inner = subviews[i] == view
            if !inner && !subviews[i].subviews.isEmpty {
                inner = subviews[i].isInnerView(view)
            }
            if inner {
                break
            }
        }
        return inner
    }
    
    public var background: NSColor {
        get {
            if let backgroundColor = layer?.backgroundColor {
                return NSColor(cgColor: backgroundColor) ?? .white
            }
            return .white
        }
        set {
            self.layer?.backgroundColor = newValue.cgColor
        }
}
    
    public func centerX(_ superView: NSView? = nil, y: CGFloat? = nil) -> Void {
        var x:CGFloat = 0
        if let sv = superView {
            x = CGFloat(roundf(Float((sv.frame.width - frame.width)/2.0)))
        } else if let sv = self.superview {
            x = CGFloat(roundf(Float((sv.frame.width - frame.width)/2.0)))
        }
        self.setFrameOrigin(NSMakePoint(x, y == nil ? NSMinY(self.frame) : y!))
    }
    
    public func centerY(_ superView: NSView? = nil, x: CGFloat? = nil) -> Void {
        var y: CGFloat = 0
        if let sv = superView {
            y = CGFloat(roundf(Float((sv.frame.height - frame.height)/2.0)))
        } else if let sv = self.superview {
            y = CGFloat(roundf(Float((sv.frame.height - frame.height)/2.0)))
        }
        self.setFrameOrigin(NSMakePoint(x ?? frame.minX, y))
    }
    
    public func focus(_ size: NSSize) -> NSRect {
        var x:CGFloat = 0
        var y:CGFloat = 0
        
        x = CGFloat(roundf(Float((frame.width - size.width)/2.0)))
        y = CGFloat(roundf(Float((frame.height - size.height)/2.0)))
        return NSMakeRect(x, y, size.width, size.height)
    }
    
    public func focus(_ size: NSSize, inset: NSEdgeInsets) -> NSRect {
        let x:CGFloat = CGFloat(roundf(Float((frame.width - size.width + (inset.left + inset.right))/2.0)))
        let y:CGFloat = CGFloat(roundf(Float((frame.height - size.height + (inset.top + inset.bottom))/2.0)))
        return NSMakeRect(x, y, size.width, size.height)
    }

    
    public func center(_ superView:NSView? = nil) -> Void {
        var x:CGFloat = 0
        var y:CGFloat = 0
        if let sv = superView {
            x = CGFloat(roundf(Float((sv.frame.width - frame.width)/2.0)))
            y = CGFloat(roundf(Float((sv.frame.height - frame.height)/2.0)))
        } else if let sv = self.superview {
            x = CGFloat(roundf(Float((sv.frame.width - frame.width)/2.0)))
            y = CGFloat(roundf(Float((sv.frame.height - frame.height)/2.0)))
        }
        self.setFrameOrigin(NSMakePoint(x, y))
    }
    
    
    public func _change(pos position: NSPoint, animated: Bool, _ save:Bool = true, removeOnCompletion: Bool = true, duration: Double = 0.2, timingFunction: String = kCAMediaTimingFunctionEaseOut, completion: ((Bool)->Void)? = nil) -> Void {
        if animated {
            var presentX = NSMinX(self.frame)
            var presentY = NSMinY(self.frame)
            let presentation: CALayer? = self.layer?.presentation()
            if let presentation = presentation, self.layer?.animation(forKey:"position") != nil {
                presentY =  NSMinY(presentation.frame)
                presentX = NSMinX(presentation.frame)
            }
//            self.layer?.animatePosition(from: NSMakePoint(presentX, presentY), to: position, duration: duration, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, completion: completion)
        } else {
            self.layer?.removeAnimation(forKey: "position")
        }
        if save {
            self.setFrameOrigin(position)
            if let completion = completion, !animated {
                completion(true)
            }
        }
        
    }
    
    public func shake() {
        let a:CGFloat = 3
        if let layer = layer {
//            self.layer?.shake(0.04, from:NSMakePoint(-a + layer.position.x,layer.position.y), to:NSMakePoint(a + layer.position.x, layer.position.y))
        }
        NSSound.beep()
    }
    
//    public func _change(size: NSSize, animated: Bool, _ save:Bool = true, removeOnCompletion: Bool = true, duration:Double = 0.2, timingFunction: String = kCAMediaTimingFunctionEaseOut, completion:((Bool)->Void)? = nil) {
//        if animated {
//            var presentBounds:NSRect = self.layer?.bounds ?? self.bounds
//            let presentation = self.layer?.presentation()
//            if let presentation = presentation, self.layer?.animation(forKey:"bounds") != nil {
//                presentBounds.size.width = NSWidth(presentation.bounds)
//                presentBounds.size.height = NSHeight(presentation.bounds)
//            }
//            
//            self.layer?.animateBounds(from: presentBounds, to: NSMakeRect(0, 0, size.width, size.height), duration: duration, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, completion: completion)
//            
//        } else {
//            self.layer?.removeAnimation(forKey: "bounds")
//        }
//        if save {
//            self.frame = NSMakeRect(NSMinX(self.frame), NSMinY(self.frame), size.width, size.height)
//        }
//    }
//    
//    public func _changeBounds(from: NSRect, to: NSRect, animated: Bool, _ save:Bool = true, removeOnCompletion: Bool = true, duration:Double = 0.2, timingFunction: String = kCAMediaTimingFunctionEaseOut, completion:((Bool)->Void)? = nil) {
//        
//        if save {
//            self.bounds = to
//        }
//        
//        if animated {
//            self.layer?.animateBounds(from: from, to: to, duration: duration, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, completion: completion)
//            
//        } else {
//            self.layer?.removeAnimation(forKey: "bounds")
//        }
//        
//        if !animated {
//            completion?(true)
//        }
//    }
//    
    public func _change(opacity to: CGFloat, animated: Bool = true, _ save:Bool = true, removeOnCompletion: Bool = true, duration:Double = 0.2, timingFunction: String = kCAMediaTimingFunctionEaseOut, completion:((Bool)->Void)? = nil) {
        if animated {
            if let layer = self.layer {
                var opacity:CGFloat = CGFloat(layer.opacity)
                if let presentation = self.layer?.presentation(), self.layer?.animation(forKey:"opacity") != nil {
                    opacity = CGFloat(presentation.opacity)
                }
                
//                layer.animateAlpha(from: opacity, to: to, duration:duration, timingFunction: timingFunction, removeOnCompletion: removeOnCompletion, completion: completion)
            }
            
        } else {
            layer?.removeAnimation(forKey: "opacity")
        }
        if save {
            self.layer?.opacity = Float(to)
            if let completion = completion, !animated {
                completion(true)
            }
        }
    }
    
}

extension NSView {
    
    // MARK: - 常用位置属性
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newLeft) {
            var frame = self.frame
            frame.origin.x = newLeft
            self.frame = frame
        }
    }
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set(newTop) {
            var frame = self.frame
            frame.origin.y = newTop
            self.frame = frame
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set(newWidth) {
            var frame = self.frame
            frame.size.width = newWidth
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newHeight) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return self.left + self.width
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.top + self.height
        }
    }
}

