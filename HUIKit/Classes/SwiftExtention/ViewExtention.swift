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

extension NSView {
    
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
    
    public var backgroundColor: NSColor {
        get {
            if let backgroundColor = layer?.backgroundColor {
                return NSColor(cgColor: backgroundColor) ?? .clear
            }
            return .clear
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue.cgColor
        }
    }
    
    
    public func centerX(_ superView: NSView? = nil, y: CGFloat? = nil) {
        let sv = superView ?? self.superview!
        let centerX = (sv.frame.width - frame.width) / 2.0
        setFrameOrigin(CGPoint(x: centerX, y: y ?? frame.minY))
    }
    
    public func centerY(_ superView: NSView? = nil, x: CGFloat? = nil) {
        let sv = superView ?? self.superview!
        let centerY = (sv.frame.height - frame.height) / 2.0
        setFrameOrigin(CGPoint(x: x ?? frame.minX, y: centerY))
    }
    
    public func center(_ superView:NSView? = nil) {
        centerX()
        centerY()
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

