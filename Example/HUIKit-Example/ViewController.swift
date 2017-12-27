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
    }

    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
  
    override func mouseDown(with event: NSEvent) {

//         clayer.animateFrame(from: clayer.frame, to: CGRect(x: 0, y: 0, width: 400, height: 40), duration: 3.0, timingFunction:kCAMediaTimingFunctionSpring)
//        clayer.animateRotateCenter(from: 0, to: -90, duration: 2.0)
        
        fontLabel.animateRotateCenter(from: 0, to: -90, duration: 2.0)
    }

}

