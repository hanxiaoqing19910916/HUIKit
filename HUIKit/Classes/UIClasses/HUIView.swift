//
//  HXView.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/6.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa


public struct BorderPosition: OptionSet {
    public var rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let top = BorderPosition(rawValue: 1)
    public static let bottom = BorderPosition(rawValue: 2)
    public static let left = BorderPosition(rawValue: 4)
    public static let right = BorderPosition(rawValue: 8)
}


public class LayoutHandlers {
    public var size: ((NSSize) -> Void)?
    public var origin: ((NSPoint) -> Void)?
    public var layoutSubViews: ((HUIView) -> Void)?
}


open class HUIView: NSView {
    
    public var flip: Bool = true
    
    open override var isFlipped: Bool {
        return flip
    }
    
    public let layoutHandlers: LayoutHandlers = LayoutHandlers()
    
    open var viewTag: Int = 0
    
    public var borderPosition: BorderPosition?
    public var borderWidth: CGFloat = 1
    
    open var borderColor: NSColor = NSColor.clear {
        didSet {
            if oldValue != backgroundColor {
                needsDisplay = true
            }
        }
    }
    
    open override func draw(_ dirtyRect: NSRect) {
        guard let contextPtr = NSGraphicsContext.current?.graphicsPort else { return }
        let ctx = unsafeBitCast(contextPtr, to: CGContext.self)
        guard let borderPos = borderPosition else { return }
        
        ctx.setFillColor(borderColor.cgColor)
        
        let selfWidth = NSWidth(frame)
        let selfHeight = NSHeight(frame)
        
        var fillRect: CGRect = CGRect()
        if borderPos.contains(.top) {
            let borderY = isFlipped ? 0 : selfHeight - borderWidth
            fillRect = CGRect(x: 0, y: borderY, width: selfWidth, height: borderWidth)
        }
        if borderPos.contains(.bottom) {
            let borderY = self.isFlipped ? selfHeight - borderWidth : 0
            fillRect = CGRect(x: 0, y: borderY, width: selfWidth, height: borderWidth)
        }
        if borderPos.contains(.left) {
            fillRect = CGRect(x: 0, y: 0, width: borderWidth, height: selfHeight)
        }
        if borderPos.contains(.right) {
            fillRect = CGRect(x: selfWidth - borderWidth, y: 0, width: borderWidth, height: selfHeight)
        }
        ctx.fill(fillRect)
    }
    


    public init() {
        super.init(frame: NSZeroRect)
        assertOnMainThread()
        wantsLayer = true
        acceptsTouchEvents = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    override required public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        assertOnMainThread()
        wantsLayer = true
        acceptsTouchEvents = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    
    open func mouseInside() -> Bool {
        return super._mouseInside()
    }
    

    
    open override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        
        if let size = layoutHandlers.size {
            size(newSize)
        }
        guard #available(OSX 10.12, *) else {
            needsLayout = true
            return
        }
    }
    
    open override func setFrameOrigin(_ newOrigin: NSPoint) {
        super.setFrameOrigin(newOrigin)
        if let origin = layoutHandlers.origin {
            origin(newOrigin)
        }
        guard #available(OSX 10.12, *) else {
            needsLayout = true
            return
        }
    }
    
    
    open override func layout() {
        super.layout()
        if let layout = layoutHandlers.layoutSubViews {
            layout(self)
        }
    }
    
    open override var needsDisplay: Bool {
        willSet {
            if newValue {
                self.layer?.setNeedsDisplay()
                assertOnMainThread()
            }
        }
    }
    
    
    open override var needsLayout: Bool {
        willSet {
            if newValue {
                guard #available(OSX 10.12, *) else {
                    layout()
                    for sub in self.subviews {
                        sub.needsLayout = true
                    }
                    return
                }
            }
        }
    }


    required public init?(coder: NSCoder) {
       super.init(coder: coder)
    }
    
    
    open var kitWindow: HUIWindow? {
        return super.window as? HUIWindow
    }
    
    
    deinit {
        assertOnMainThread()
    }
    
}




