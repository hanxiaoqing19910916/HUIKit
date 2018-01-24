//
//  ViewController.swift
//  HUIKit-Example
//
//  Created by hanxiaoqing on 2017/12/21.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa
import HUIKit

class ViewController: NSViewController {

    @IBOutlet weak var fontLabel: NSTextField!
    let clayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        testFontWithView(view: view)
        //        testColorWithView(view: view)
        
        clayer.backgroundColor = NSColor.redUI.cgColor
        clayer.frame = CGRect(x: 120, y: 120, width: 200, height: 30)
        view.layer?.addSublayer(clayer)
        
        let loginBtn = HUIButton(frame: CGRect(x: 30, y: 100, width: 40, height: 50))
        loginBtn.isTrackingEnabled = true
        loginBtn.isEnabled  = false
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.setTitleColor(NSColor.white, for: .normal)
        loginBtn.setTitleColor(NSColor.yellow, for: .mouseIn)
        loginBtn.set(background: .red, for: .normal)
        loginBtn.set(background: .blue, for: .mouseIn)
        loginBtn.set(background: .gray, for: .disabled)


        view.addSubview(loginBtn)
    }

    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
  
    override func mouseDown(with event: NSEvent) {
        
        //        fontLabel.alphaAnimate(from: 1.0, to: 0.5, duration: 4.0)
        //        fontLabel.rotateCenterAnimate(from: 0, to: -90, duration: 5.0)
        
//        clayer.frameAnimate(from: CGRect(), to:CGRect(x: 100, y: 100, width: 100, height: 100), duration: 5.0)
//        clayer.scaleAnimate(from: 1.0, to: 0.5, duration: 10.0)
       fontLabel.shake(0.12)
       
//         fontLabel.positionAnimate(from: CGPoint(x: -20, y: 0), to: CGPoint(x: 20, y: 0), duration: 2.0)
        
        
        fontLabel.center()
        
    }

}

