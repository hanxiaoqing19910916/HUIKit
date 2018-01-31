//
//  FontExtention.swift
//
//  Created by hanxiaoqing on 2017/10/31.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//


import Cocoa

public extension NSFont {
    
    public static func systemRegularFont(_ size: CGFloat) -> NSFont {
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: size, weight: .regular)
        } else {
            return NSFont(name: "HelveticaNeue", size: size)!
        }
    }
    
    public static func systemMediumFont(_ size: CGFloat) -> NSFont {
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: size, weight: .semibold)
        } else {
            return NSFont(name: "HelveticaNeue-Medium", size: size)!
        }
    }
    
    public static func systemBoldFont(_ size: CGFloat) -> NSFont {
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: size, weight: .bold)
        } else {
            return NSFont(name: "HelveticaNeue-Bold", size: size)!
        }
    }
    public static func systemThinFont(_ size: CGFloat) -> NSFont {
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: size, weight: .thin)
        } else {
            return NSFont(name: "HelveticaNeue-Thin", size: size)!
        }
    }
    
    public static func compactRoundFont(_ size: CGFloat) -> NSFont {
        return NSFont(name: ".SFCompactRounded-Thin", size: size)!
    }
    
    public static func menloRegularFont(_ size: CGFloat) -> NSFont {
        return NSFont(name: "Menlo-Regular", size: size)!
    }
    
    public func italic() -> NSFont {
        return NSFontManager.shared.convert(self, toHaveTrait: .italicFontMask)
    }
}

