//
//  TGFont.swift
//  TGUIKit
//
//  Created by keepcoder on 07/09/16.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa


public func systemFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.regular)
    } else {
        return NSFont.init(name: "HelveticaNeue", size: size)!
    }
}

public func systemMediumFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.semibold)
    } else {
        return NSFont.init(name: "HelveticaNeue-Medium", size: size)!
    }
    
}

public func systemBoldFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.bold)
    } else {
        return NSFont.init(name: "HelveticaNeue-Bold", size: size)!
    }
}

public extension NSFont {
    public static func normal(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.regular)
        } else {
            return NSFont(name: "HelveticaNeue", size: convert(from:size))!
        }
    }
    
    public static func italic(_ size: FontSize) -> NSFont {
        return NSFontManager.shared.convert(.normal(size), toHaveTrait: .italicFontMask)
    }
    
    public static func avatar(_ size: FontSize) -> NSFont {
        
        if let font = NSFont(name: ".SFCompactRounded-Semibold", size: convert(from:size)) {
            return font
        } else {
            return .medium(size)
        }
    }
    
    public static func medium(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.medium)
        } else {
            return NSFont(name: "HelveticaNeue-Medium", size: convert(from:size))!
        }
        
    }
    
    public static func bold(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.bold)
        } else {
            return NSFont(name: "HelveticaNeue-Bold", size: convert(from:size))!
        }
    }
    
    public static func code(_ size:FontSize) ->NSFont {
        return NSFont(name: "Menlo-Regular", size: convert(from:size)) ?? NSFont.systemFont(ofSize: 17.0)
    }
}

public enum FontSize {
    case small
    case short
    case text
    case title
    case header
    case huge
    case custom(CGFloat)
}

fileprivate func convert(from s:FontSize) -> CGFloat {
    switch s {
    case .small:
        return 11.0
    case .short:
        return 12.0
    case .text:
        return 13.0
    case .title:
        return 14.0
    case .header:
        return 15.0
    case .huge:
        return 18.0
    case let .custom(size):
        return size
    }
}


