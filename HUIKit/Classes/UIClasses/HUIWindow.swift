//
//  HUIWindow.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/7.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa


public enum HandlerPriority: Int, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case modal = 3
    
}

public func <(lhs: HandlerPriority, rhs: HandlerPriority) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public enum KeyHandlerResult {
    case invoked // invoke and return
    case rejected // can invoke next priprity event
    case invokeNext // invoke and send global event
}


class KeyHandler : Comparable {
    let handler:()->KeyHandlerResult
    let object:WeakReference<NSObject>
    let priority:HandlerPriority
    let modifierFlags:NSEvent.ModifierFlags?
    
    init(_ handler:@escaping()->KeyHandlerResult, _ object:NSObject?, _ priority:HandlerPriority, _ flags:NSEvent.ModifierFlags?) {
        self.handler = handler
        self.object = WeakReference(value: object)
        self.priority = priority
        self.modifierFlags = flags
    }
}
func ==(lhs: KeyHandler, rhs: KeyHandler) -> Bool {
    return lhs.priority == rhs.priority
}
func <(lhs: KeyHandler, rhs: KeyHandler) -> Bool {
    return lhs.priority < rhs.priority
}




public enum SwipeDirection {
    case left
    case right
    case none
}

class SwipeHandler : Comparable {
    let handler:(SwipeDirection)->KeyHandlerResult
    let object:WeakReference<NSObject>
    let priority:HandlerPriority
    
    init(_ handler:@escaping(SwipeDirection)->KeyHandlerResult, _ object:NSObject?, _ priority:HandlerPriority) {
        self.handler = handler
        self.object = WeakReference(value: object)
        self.priority = priority
    }
}
func ==(lhs: SwipeHandler, rhs: SwipeHandler) -> Bool {
    return lhs.priority == rhs.priority
}
func <(lhs: SwipeHandler, rhs: SwipeHandler) -> Bool {
    return lhs.priority < rhs.priority
}




class ResponderObserver : Comparable {
    let handler:()->NSResponder?
    let object:WeakReference<NSObject>
    let priority:HandlerPriority
    
    init(_ handler:@escaping()->NSResponder?, _ object:NSObject?, _ priority:HandlerPriority) {
        self.handler = handler
        self.object = WeakReference(value: object)
        self.priority = priority
    }
}
func ==(lhs: ResponderObserver, rhs: ResponderObserver) -> Bool {
    return lhs.priority == rhs.priority
}
func <(lhs: ResponderObserver, rhs: ResponderObserver) -> Bool {
    return lhs.priority < rhs.priority
}



class MouseObserver : Comparable {
    let handler:(NSEvent)->KeyHandlerResult
    let object:WeakReference<NSObject>
    let priority:HandlerPriority
    let type:NSEvent.EventType?
    
    init(_ handler:@escaping(NSEvent)->KeyHandlerResult, _ object:NSObject?, _ priority:HandlerPriority, _ type:NSEvent.EventType) {
        self.handler = handler
        self.object = WeakReference(value: object)
        self.priority = priority
        self.type = type
    }
}

func ==(lhs: MouseObserver, rhs: MouseObserver) -> Bool {
    return lhs.priority == rhs.priority
}
func <(lhs: MouseObserver, rhs: MouseObserver) -> Bool {
    return lhs.priority < rhs.priority
}




public class HUIWindow: NSWindow {
    
    public var name: String = "HUIKit.HUIWindow"
    
    
    // private event handlers
    private var keyHandlers:[KeyboardKey:[KeyHandler]] = [:]
    
    private var swipeHandlers:[SwipeHandler] = []
    
    private var mouseHandlers:[NSEvent.EventType:[MouseObserver]] = [:]

    private var responsders:[ResponderObserver] = []
    
    private var swipePoints:[NSPoint] = []
    
    //  private var saver:WindowSaver?
    //  public var initFromSaver:Bool = false
    
    public var copyhandler:(()->Void)? = nil
    
    public var closeInterceptor:(()->Void)? = nil
    
    public func set(responder:@escaping() -> NSResponder?, with object:NSObject?, priority:HandlerPriority) {
        responsders.append(ResponderObserver(responder, object, priority))
    }
    
    
    public func removeObserver(for object:NSObject) {
        var copy:[ResponderObserver] = []
        for observer in responsders {
            copy.append(observer)
        }
        for i in stride(from: copy.count - 1, to: -1, by: -1) {
            if copy[i].object.value == object || copy[i].object.value == nil  {
                responsders.remove(at: i)
            }
        }
    }
    
    
    public func set(handler:@escaping() -> KeyHandlerResult, with object:NSObject, for key:KeyboardKey, priority:HandlerPriority = .low, modifierFlags:NSEvent.ModifierFlags? = nil) -> Void {
        var handlers:[KeyHandler]? = keyHandlers[key]
        if handlers == nil {
            handlers = []
            keyHandlers[key] = handlers
        }
        keyHandlers[key]?.append(KeyHandler(handler, object, priority, modifierFlags))
        
    }
    
    public func add(swipe handler:@escaping(SwipeDirection) -> KeyHandlerResult, with object:NSObject, priority:HandlerPriority = .low) -> Void {
        swipeHandlers.append(SwipeHandler(handler, object, priority))
    }
    
    public func removeAllHandlers(for object:NSObject) {
        
        var newKeyHandlers:[KeyboardKey:[KeyHandler]] = [:]
        for (key, handlers) in keyHandlers {
            newKeyHandlers[key] = handlers
        }
        
        for (key, handlers) in keyHandlers {
            var copy:[KeyHandler] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == object  {
                    newKeyHandlers[key]?.remove(at: i)
                }
            }
        }
        self.keyHandlers = newKeyHandlers
        
        var newMouseHandlers:[NSEvent.EventType:[MouseObserver]] = [:]
        for (key, handlers) in mouseHandlers {
            newMouseHandlers[key] = handlers
        }
        
        for (key, handlers) in mouseHandlers {
            var copy:[MouseObserver] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == object  {
                    newMouseHandlers[key]?.remove(at: i)
                }
            }
        }
        self.mouseHandlers = newMouseHandlers
        
        
        var copyGesture:[SwipeHandler] = []
        for gesture in swipeHandlers {
            copyGesture.append(gesture)
        }
        for i in stride(from: swipeHandlers.count - 1, to: -1 , by: -1) {
            if copyGesture[i].object.value == object {
                copyGesture.remove(at: i)
            }
        }
        self.swipeHandlers = copyGesture
    }
    
    
    public func remove(object:NSObject, for key:KeyboardKey) {
        let handlers = keyHandlers[key]
        if let handlers = handlers {
            var copy:[KeyHandler] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == object || copy[i].object.value == nil  {
                    keyHandlers[key]?.remove(at: i)
                }
            }
        }
    }
    
    private func cleanUndefinedHandlers() {
        var newKeyHandlers:[KeyboardKey:[KeyHandler]] = [:]
        for (key, handlers) in keyHandlers {
            newKeyHandlers[key] = handlers
        }
        
        for (key, handlers) in keyHandlers {
            var copy:[KeyHandler] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == nil  {
                    newKeyHandlers[key]?.remove(at: i)
                }
            }
        }
        self.keyHandlers = newKeyHandlers
        
        var newMouseHandlers:[NSEvent.EventType:[MouseObserver]] = [:]
        for (key, handlers) in mouseHandlers {
            newMouseHandlers[key] = handlers
        }
        
        for (key, handlers) in mouseHandlers {
            var copy:[MouseObserver] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == nil  {
                    newMouseHandlers[key]?.remove(at: i)
                }
            }
        }
        self.mouseHandlers = newMouseHandlers
        
        var copyGesture:[SwipeHandler] = []
        for gesture in swipeHandlers {
            copyGesture.append(gesture)
        }
        for i in stride(from: swipeHandlers.count - 1, to: -1 , by: -1) {
            if copyGesture[i].object.value == nil {
                copyGesture.remove(at: i)
            }
        }
        self.swipeHandlers = copyGesture
        
    }
    
    public func set(mouseHandler:@escaping(NSEvent) -> KeyHandlerResult, with object:NSObject, for type:NSEvent.EventType, priority:HandlerPriority = .low) -> Void {
        var handlers:[MouseObserver]? = mouseHandlers[type]
        if handlers == nil {
            handlers = []
            mouseHandlers[type] = handlers
        }
        mouseHandlers[type]?.append(MouseObserver(mouseHandler, object, priority, type))
    }
    
    public func remove(object:NSObject, for type:NSEvent.EventType) {
        let handlers = mouseHandlers[type]
        if let handlers = handlers {
            var copy:[MouseObserver] = []
            for handle in handlers {
                copy.append(handle)
            }
            for i in stride(from: copy.count - 1, to: -1, by: -1) {
                if copy[i].object.value == object || copy[i].object.value == nil  {
                    mouseHandlers[type]?.remove(at: i)
                }
            }
        }
    }

    
    
    public func applyResponderIfNeeded() ->Void {
        let sorted = responsders.sorted(by: >)
        
        for observer in sorted {
            if let responder = observer.handler() {
                if self.firstResponder != responder {
                    let _ = self.resignFirstResponder()
                    if responder.responds(to: NSSelectorFromString("window")) {
                        let window:NSWindow? = responder.value(forKey: "window") as? NSWindow
                        if window != self {
                            continue
                        }
                    }
                    self.makeFirstResponder(responder)
                    if let responder = responder as? NSTextField {
//                        responder.setCursorToEnd()
                    }
                }
                break
            }
        }
    }
    
    
    public override func close() {
        if let closeInterceptor = closeInterceptor {
            closeInterceptor()
            return
        }
        if isReleasedWhenClosed {
            super.close()
        } else {
            super.close()
        }
    }
    
    @objc public func pasteToFirstResponder(_ sender: Any) {
        
        applyResponderIfNeeded()
        
        if let firstResponder = firstResponder, firstResponder.responds(to: NSSelectorFromString("paste:")) {
            firstResponder.performSelector(onMainThread: NSSelectorFromString("paste:"), with: sender, waitUntilDone: false)
        }
    }
    
    @objc public func copyFromFirstResponder(_ sender: Any) {
        if let copyhandler = copyhandler {
            copyhandler()
        } else {
            if let firstResponder = firstResponder, firstResponder.responds(to: NSSelectorFromString("copy:")) {
                firstResponder.performSelector(onMainThread: NSSelectorFromString("copy:"), with: sender, waitUntilDone: false)
            }
        }
    }
    
    

    public override func sendEvent(_ event: NSEvent) {
        
        if sheets.isEmpty {
            if event.type == .keyDown {
                
                if KeyboardKey(rawValue:event.keyCode) != KeyboardKey.Escape {
                    applyResponderIfNeeded()
                }
                
                cleanUndefinedHandlers()
                
                if let globalHandler = keyHandlers[.All]?.sorted(by: >).first, let keyCode = KeyboardKey(rawValue:event.keyCode) {
                    if let handle = keyHandlers[keyCode]?.sorted(by: >).first {
                        if globalHandler.object.value != handle.object.value {
                            if (handle.modifierFlags == nil || event.modifierFlags.contains(handle.modifierFlags!)) {
                                switch globalHandler.handler() {
                                case .invoked:
                                    return
                                case .rejected:
                                    break
                                case .invokeNext:
                                    super.sendEvent(event)
                                    return
                                }
                            } else {
                                // super.sendEvent(event)
                                // return
                            }
                        }
                    }
                }
                
                if let keyCode = KeyboardKey(rawValue:event.keyCode), let handlers = keyHandlers[keyCode]?.sorted(by: >) {
                    loop: for handle in handlers {
                        
                        if (handle.modifierFlags == nil || event.modifierFlags.contains(handle.modifierFlags!))  {
                            
                            switch handle.handler() {
                            case .invoked:
                                return
                            case .rejected:
                                continue
                            case .invokeNext:
                                break loop
                            }
                            
                        }
                    }
                }
                
            } else if let handlers = mouseHandlers[event.type] {
                let sorted = handlers.sorted(by: >)
                loop: for handle in sorted {
                    switch handle.handler(event) {
                    case .invoked:
                        return
                    case .rejected:
                        continue
                    case .invokeNext:
                        break loop
                    }
                }
            }
            super.sendEvent(event)
        } else {
            //super.sendEvent(event)
        }
    }
    
    
    public func set(escape handler:@escaping() -> KeyHandlerResult, with object:NSObject, priority:HandlerPriority = .low, modifierFlags:NSEvent.ModifierFlags? = nil) -> Void {
        set(handler: handler, with: object, for: .Escape, priority:priority, modifierFlags:modifierFlags)
    }
    
    public override var canBecomeKey: Bool {
        return true
    }
    
    public func windowImageShot() -> CGImage? {
        return CGWindowListCreateImage(CGRect.null, [.optionIncludingWindow], CGWindowID(windowNumber), [.boundsIgnoreFraming])
    }
    
    
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
        
        self.acceptsMouseMovedEvents = true
        self.contentView?.wantsLayer = true
        self.contentView?.acceptsTouchEvents = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
