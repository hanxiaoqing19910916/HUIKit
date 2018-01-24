//
//  HXWindowBuilder.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/10/31.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Foundation
import AppKit

open class HXWindowBuilder: NSObject {
    
    /// 可以通过属性配置之后得到的window
    open lazy var configedWindow = {
       return HXWindowBuilder.defaultWindow
    }()
    
    
    /// 提供一个默认的window
    /// 顶部栏左边（关闭，最小化，全屏）按钮，中间可显示标题文字，有一个灰色的背景
    open static var defaultWindow: NSWindow {
        get {
            let window = NSWindow()
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            return window
        }
    }
    
    /// 是否显示整个顶部栏（包括那些可配置的按钮（关闭，最小化，全屏）,标题文字）
    /// 如果设为NO，整个window顶部栏消失
    var showEntireTopBar: Bool = true {
        willSet {
            if newValue == true {
                let style: NSWindow.StyleMask = configedWindow.styleMask.union([.titled])
                configedWindow.styleMask = style
            } else {
                _ = configedWindow.styleMask.remove([.titled])!
            }
        }
    }
    
    /// 是否显示顶部栏标题文字
    var topBarTitleHidden: Bool? {
        willSet {
            configedWindow.titleVisibility = newValue == true ? .hidden : .visible
        }
    }
    
    /// 默认情况下window的整个顶部栏有一个灰色的背景，
    /// 这里可设置topBarBackGroundTransparent == YES
    /// 让这个背景变透明
    var topBarBackGroundTransparent: Bool? {
        willSet {
             configedWindow.titlebarAppearsTransparent = newValue!
        }
    }
    
}


