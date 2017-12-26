//
//  ColorExtention.swift
//
//  Created by hanxiaoqing on 2017/11/8.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//
import AppKit
import Foundation

public extension NSColor {
    
    convenience init(rgb: UInt32, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((rgb >> 16) & 0xff) / 255.0, green: CGFloat((rgb >> 8) & 0xff) / 255.0, blue: CGFloat(rgb & 0xff) / 255.0, alpha: alpha)
    }
    
    convenience init(argb: UInt32) {
        self.init(red: CGFloat((argb >> 16) & 0xff) / 255.0, green: CGFloat((argb >> 8) & 0xff) / 255.0, blue: CGFloat(argb & 0xff) / 255.0, alpha: CGFloat((argb >> 24) & 0xff) / 255.0)
    }
    
    var argb: UInt32 {
        let color = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB)!
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (UInt32(alpha * 255.0) << 24) | (UInt32(red * 255.0) << 16) | (UInt32(green * 255.0) << 8) | (UInt32(blue * 255.0))
    }
    
    var rgb: UInt32 {
        let color = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB)
        if let color = color {
            let red: CGFloat = color.redComponent
            let green: CGFloat = color.greenComponent
            let blue: CGFloat = color.blueComponent
            return (UInt32(red * 255.0) << 16) | (UInt32(green * 255.0) << 8) | (UInt32(blue * 255.0))
        }
        return 0x000000
    }
}


public extension NSColor {
    
    public static var random: NSColor  {
        return NSColor(rgb: arc4random_uniform(16000000))
    }
    
    public static var blueLink: NSColor {
        return NSColor(rgb: 0x2481cc)
    }
    
    public static var redUI: NSColor {
        return NSColor(rgb: 0xff3b30)
    }
    
    public static var greenUI: NSColor {
        return NSColor(rgb: 0x63DA6E)
    }
    
    public static var blackTransparent: NSColor {
        return NSColor(rgb: 0x000000, alpha: 0.6)
    }
    
    public static var grayTransparent: NSColor {
        return NSColor(rgb: 0xf4f4f4, alpha: 0.4)
    }
    
    public static var grayUI: NSColor {
        return NSColor(rgb: 0xFaFaFa)
    }

    public static var blueText: NSColor {
        return NSColor(rgb: 0x4ba3e2)
    }
    
    public static var blueSelect: NSColor  {
        return NSColor(rgb: 0x4c91c7)
    }
    
}




