//
//  Font-Color.swift
//  HUIKit-Example
//
//  Created by hanxiaoqing on 2017/12/26.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

func testFontWithView(view: NSView) {
    
    let fonts: [NSFont] = [NSFont.systemRegularFont(17), NSFont.systemMediumFont(17), NSFont.systemBoldFont(17), NSFont.systemThinFont(17), NSFont.compactRoundFont(17), NSFont.menloRegularFont(17)]
    let fontNames = ["systemRegularFont", "systemMediumFont", "systemBoldFont", "systemThinFont", "compactRoundFont", "menloRegularFont"]
    
    for i in 0 ..< fonts.count {
        let label = createLabel()
        label.font = fonts[i]
        label.stringValue = fontNames[i]
        label.height = 32
        label.width = 180
        label.left = CGFloat(i) * label.width
        label.top = 80
        view.addSubview(label)
    }
    
    for i in 0 ..< fonts.count {
        let label = createLabel()
        label.font = fonts[i].italic()
        label.stringValue = fontNames[i]
        label.height = 32
        label.width = 180
        label.left = CGFloat(i) * label.width
        label.top = 30
        view.addSubview(label)
    }
}



func testColorWithView(view: NSView) {
    let colors = [NSColor.random, NSColor.blueLink, NSColor.redUI, NSColor.greenUI, NSColor.blackTransparent,
                  NSColor.grayTransparent, NSColor.grayUI, NSColor.blueText, NSColor.blueSelect]
    let colorString = ["random", "blueLink","redUI","greenUI","blackTransparent","grayTransparent","grayUI","blueText","blueSelect"]
    
    for i in 0 ..< colors.count {
        let label = createLabel()
        label.font = NSFont.compactRoundFont(16)
        label.backgroundColor = colors[i]
        label.stringValue = colorString[i]
        label.height = 32
        label.width = 100
        label.left = CGFloat(i) * label.width
        label.top = 130
        view.addSubview(label)
    }    
}

func createLabel() -> NSTextField  {
    let label = NSTextField()
    label.isBordered = false
    label.isEditable = false
    label.isSelectable = false
    label.alignment = .center
    return label
}

