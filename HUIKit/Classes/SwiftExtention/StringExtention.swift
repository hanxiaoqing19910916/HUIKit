//
//  StringExtention.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/7.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa


public extension NSAttributedStringKey {
    public static var preformattedCode: NSAttributedStringKey {
        return NSAttributedStringKey(rawValue: "TGPreformattedCodeAttributeName")
    }
    public static var preformattedPre: NSAttributedStringKey {
        return NSAttributedStringKey(rawValue: "TGPreformattedPreAttributeName")
    }
    public static var selectedColor: NSAttributedStringKey {
        return NSAttributedStringKey(rawValue: "KSelectedColorAttributeName")
    }
}

public extension NSAttributedString {
    
    func CTSize(_ width:CGFloat, framesetter:CTFramesetter?) -> (CTFramesetter,NSSize) {
        
        var fs = framesetter
        
        if fs == nil {
            fs = CTFramesetterCreateWithAttributedString(self);
        }
        
        var textSize:CGSize  = CTFramesetterSuggestFrameSizeWithConstraints(fs!, CFRangeMake(0,self.length), nil, NSMakeSize(width, CGFloat.greatestFiniteMagnitude), nil);
        
        textSize.width =  ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return (fs!,textSize);
        
    }
    
    public var range:NSRange {
        return NSMakeRange(0, self.length)
    }
    
    public func trimRange(_ range:NSRange) -> NSRange {
        let loc:Int = min(range.location,self.length)
        let length:Int = min(range.length, self.length - loc)
        return NSMakeRange(loc, length)
    }
    
    public static func initialize(string:String?, color:NSColor? = nil, font:NSFont? = nil, coreText:Bool = true) -> NSAttributedString {
        let attr:NSMutableAttributedString = NSMutableAttributedString()
        _ = attr.append(string: string, color: color, font: font, coreText: true)
        
        return attr.copy() as! NSAttributedString
    }
    
    
}


public extension NSMutableAttributedString {
    
    public func append(string:String?, color:NSColor? = nil, font:NSFont? = nil, coreText:Bool = true) -> NSRange {
        
        if(string == nil) {
            return NSMakeRange(0, 0)
        }
        
        let slength:Int = self.length
        
        
        var range:NSRange
        
        self.append(NSAttributedString(string: string!))
        let nlength:Int = self.length - slength
        range = NSMakeRange(self.length - nlength, nlength)
        
        if let c = color {
            self.addAttribute(NSAttributedStringKey.foregroundColor, value: c, range:range )
        }
        
        if let f = font {
            if coreText {
                self.setCTFont(font: f, range: range)
            }
            self.setFont(font: f, range: range)
        }
        
        
        return range
        
    }
    
    public func add(link:Any, for range:NSRange, color: NSColor)  {
        self.addAttribute(NSAttributedStringKey.link, value: link, range: range)
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
    public func setCTFont(font:NSFont, range:NSRange) -> Void {
        self.addAttribute(NSAttributedStringKey(kCTFontAttributeName as String), value: CTFontCreateWithFontDescriptor(font.fontDescriptor, 0, nil), range: range)
    }
    
    public func setSelected(color:NSColor,range:NSRange) -> Void {
        self.addAttribute(.selectedColor, value: color, range: range)
    }
    
    
    public func setFont(font:NSFont, range:NSRange) -> Void {
        self.addAttribute(NSAttributedStringKey.font, value: font, range: range)
    }
    
}





