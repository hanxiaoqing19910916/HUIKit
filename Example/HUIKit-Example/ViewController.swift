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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testFontWithView(view: view)
        testColorWithView(view: view)

        
        
    }

    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

