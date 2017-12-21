//
//  UIControl.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/13.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

public struct HUIControlState : OptionSet {
    public let rawValue: Int
    public static let normal = HUIControlState(rawValue: 0)
    public static let highlighted = HUIControlState(rawValue: 1 << 0)
    public static let disabled = HUIControlState(rawValue: 1 << 1)
    public static let selected = HUIControlState(rawValue: 1 << 2)
    public static let mouseIn = HUIControlState(rawValue: 1 << 3)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct HUIControlHandler: Equatable {
    public var target: Any? = nil
    public var action: Selector? = nil
}

public func ==(lhs: HUIControlHandler, rhs: HUIControlHandler) -> Bool {
    return lhs.target as! NSObject == rhs.target as! NSObject
}



open class HUIControl: HUIView {
    
    /// default is true. if false, ignores mouse/key events and subclasses may draw differently
    open var isEnabled: Bool = true {
        didSet {
            if isEnabled != oldValue {
                state = isEnabled ? .normal : .disabled
            }
        }
    }
    
    /// default is false may be used by some subclasses or by application
    open var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                state = isSelected ? .selected : .normal
            }
        }
    }
    
    /// default is true. during mouse down inside has highlighted effects, once set false, all highlighted state setting is invaild
    open var isHighlightedEnabled: Bool = true
    
    /// default is false. this gets set/cleared automatically when touch enters/exits during tracking and cleared on up
    open var isHighlighted: Bool = false
    
    
    /// default is false. if set true , when updateTrackingAreas, will creat a NSTrackingArea within this HUIControl object
    open var isTrackingEnabled: Bool = false
    
    /// synthesized from currrent event.
    open var state: HUIControlState = .normal {
        didSet {
            if state != oldValue && window != nil {
                apply(state: state)
            }
        }
    }
    
    /// a trackingArea that can respone mouseEntered or Exited event
    open var trackingArea: NSTrackingArea?
    
    
    /// use a dic to storage backgroundColor for each controlState
    fileprivate var stateBackgroundMap: [Int : NSColor] = [:]
    
    /// use a dic to storage controlHandler object for each event
    fileprivate var eventHandlerMap: [NSEvent.EventType : HUIControlHandler] = [:]
    
    // default is the view backgroundColor
    open func set(background color: NSColor?, for state: HUIControlState) {
        var backColor: NSColor = self.backgroundColor
        if let bgColor = color {
            backColor = bgColor
        }
        stateBackgroundMap[state.rawValue] = backColor
    }
    
    
    /// add target/action for particular event. you can call this multiple times and you can specify multiple target/actions for a particular event.
    /// - Parameters:
    ///   - target: anyObject better inherit from NSObject
    ///   - action: the action cannot be NULL. Note that the target is not retained.
    ///   - controlEvents: any cocoa event
    open func addTarget(_ target: Any?, action: Selector, for controlEvents: NSEvent.EventType) {
        var handler = HUIControlHandler()
        handler.target = target
        handler.action = action
        if handler != eventHandlerMap[controlEvents] {
            eventHandlerMap[controlEvents] = handler
        }
    }
    
    
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        let currentState = self.state
        
        // make sure normal state has one backgroundColor
        if let color = stateBackgroundMap[HUIControlState.normal.rawValue] {
            set(background:color, for: .normal)
        } else {
            set(background:backgroundColor, for: .normal)
        }
    
        // when button move to window , it maybe has different sate, self.state value Influenced by
        // isEnabled or isSelected property. so must apply state at this time.
        apply(state: currentState)
    }
    
    
    
    public override init() {
        super.init()
    }

    public required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas();
        
        // if user didn't call addTarget(action:for:) function for mouseEntered event
        // neednt addTrackingArea
        guard isTrackingEnabled == true else {
            return
        }
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        trackingArea = nil
        if let _ = window {
            let options: NSTrackingArea.Options = [.cursorUpdate, .mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow,.inVisibleRect]
            trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
            addTrackingArea(trackingArea!)
        }
    }
    
    deinit {
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
    }
    
    public func apply(state: HUIControlState) {
        if let color = stateBackgroundMap[state.rawValue] {
            backgroundColor = color
        }
    }
    
}


extension HUIControl {
    open override func becomeFirstResponder() -> Bool {
        if let window = kitWindow {
            return window.makeFirstResponder(self)
        }
        return false
    }
}


extension HUIControl {
    
    open func send(with event: NSEvent) {
        if let handler = eventHandlerMap[event.type] {
            let targetObj = handler.target as! NSObject
            targetObj.perform(handler.action, with: self)
        }
    }
    
    
    open override func mouseDown(with event: NSEvent) {
        if isEnabled == false {
            super.mouseDown(with: event)
            return
        }
        
        // highighted state begin
        if isHighlightedEnabled && state != .mouseIn {
            state = .highlighted
            isHighlighted = true
        }
        send(with: event)
    }
    
    open override func mouseUp(with event: NSEvent) {
        if isEnabled == false {
            super.mouseUp(with: event)
            return
        }
        
        // restore normal state
        if state != .mouseIn {
            state = .normal
        }
        isHighlighted = false
        
        send(with: event)
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        if isEnabled == false {
            super.rightMouseDown(with: event)
            return
        }
        send(with: event)
    }
    
    override open func mouseEntered(with event: NSEvent) {
        if isEnabled == false {
            super.mouseEntered(with: event)
            return
        }
        state = .mouseIn
        send(with: event)
    }
    
    override open func mouseExited(with event: NSEvent) {
        if isEnabled == false {
            super.mouseExited(with: event)
            return
        }
        state = .normal
        send(with: event)
    }
}

