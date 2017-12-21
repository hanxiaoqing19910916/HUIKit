//
//  UIButton.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/14.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

public enum ImagePosition : UInt {
    
    case left
    
    case right
    
    case below
    
    case above
    
    case overlaps
}


open class HUIButton: HUIControl {
    
    /// default is UIEdgeInsetsZero
    open var titleEdgeInsets: NSEdgeInsets = NSEdgeInsetsZero
    
    /// default is UIEdgeInsetsZero
    open var imageEdgeInsets: NSEdgeInsets = NSEdgeInsetsZero
    
    /// set when titleLabel and imageView exsit at the same time, default left.
    open var imagePosition: ImagePosition = .left
    
    
    // you can set the image, title color and background image to use for each state. you can specify data
    // for a combined state by using the flags added together. in general, you should specify a value for the normal state to be used
    // by other states which don't have a custom value set
    
    /// default is nil. title is assumed to be single line
    open func setTitle(_ title: String?, for state: HUIControlState) {
        stateTitleMap[state.rawValue] = title
    }
    
    /// default if nil. use opaque white
    open func setTitleColor(_ color: NSColor?, for state: HUIControlState) {
        stateTitleColorMap[state.rawValue] = color
    }
    
    /// default is nil. should be same size if different for different states
    open func setImage(_ image: NSImage?, for state: HUIControlState) {
        stateImageMap[state.rawValue] = image
    }
    
    /// default is nil
    open func setBackgroundImage(_ image: NSImage?, for state: HUIControlState) {
        stateBackgroundImageMap[state.rawValue] = image
    }
    
    /// default is nil. title is assumed to be single line
    open func setAttributedTitle(_ title: NSAttributedString?, for state: HUIControlState) {
        stateAttributedTitleMap[state.rawValue] = title
    }
    
    // these getters only take a single state value
    
    open func title(for state: HUIControlState) -> String? {
        return stateTitleMap[state.rawValue]
    }
    
    open func titleColor(for state: HUIControlState) -> NSColor? {
        return stateTitleColorMap[state.rawValue]
    }
    
    open func image(for state: HUIControlState) -> NSImage? {
        return stateImageMap[state.rawValue]
    }
    
    open func backgroundImage(for state: HUIControlState) -> NSImage? {
        return stateBackgroundImageMap[state.rawValue]
    }
    
    open func attributedTitle(for state: HUIControlState) -> NSAttributedString? {
        return stateAttributedTitleMap[state.rawValue]
    }
    
    
    // these are the values that will be used for the current state. you can also use these for overrides. a heuristic will be used to
    // determine what image to choose based on the explict states set. For example, the 'normal' state value will be used for all states
    // that don't have their own image defined.
    
    /// normal/highlighted/selected/disabled/mouseIn. can return nil
    open var currentTitle: String? {
        get { return title(for: self.state) ?? title(for: .normal) }
    }
    
    /// normal/highlighted/selected/disabled. always returns non-nil. default is white(1,1)
    open var currentTitleColor: NSColor? {
        get { return titleColor(for: self.state) ?? titleColor(for: .normal) }
    }
    
    
    /// normal/highlighted/selected/disabled. can return nil
    open var currentImage: NSImage? {
        get { return image(for: self.state) ?? image(for: .normal) }
    }
    
    /// normal/highlighted/selected/disabled. can return nil
    open var currentBackgroundImage: NSImage? {
        get { return backgroundImage(for: self.state) ?? backgroundImage(for: .normal) }
    }
    
    /// normal/highlighted/selected/disabled. can return nil
    open var currentAttributedTitle: NSAttributedString? {
        get { return attributedTitle(for: self.state) ?? attributedTitle(for: .normal) }
    }
    
    
    /// return title and image views. will always create them if necessary. always returns nil for system buttons

    lazy open var titleLabel: NSTextField? = {
        let label = NSTextField()
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.font = NSFont.systemFont(ofSize: 13.5)
        label.textColor = NSColor.black
        label.drawsBackground = false
        return label
    }()
    
    
    lazy open var imageView: NSImageView? = {
        let imgView = NSImageView()
        return imgView
    }()
    

    /// use a dic to storage title for each controlState
    fileprivate var stateTitleMap: [Int : String] = [:]
    
    /// use a dic to storage titleColor for each controlState
    fileprivate var stateTitleColorMap: [Int : NSColor] = [:]
    
    /// use a dic to storage Image for each controlState
    fileprivate var stateImageMap: [Int : NSImage] = [:]
    
    /// use a dic to storage backgroundImage for each controlState
    fileprivate var stateBackgroundImageMap: [Int : NSImage] = [:]
    
    /// use a dic to storage attributedTitle for each controlState
    fileprivate var stateAttributedTitleMap: [Int : NSAttributedString] = [:]
    
    
    public override init() {
        super.init()
        setUpViews()
    }

    public required init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpViews()
    }
    
    fileprivate func setUpViews() {
        
        addSubview(imageView!)
        addSubview(titleLabel!)
        
        layoutHandlers.layoutSubViews = { [weak self] view in
            
            let currentImage = self?.currentImage
            let currentTitle = self?.currentTitle
            let titleLabel = (self?.titleLabel)!
            let imageView = (self?.imageView)!
            
            // only title
            if currentTitle != nil {
                titleLabel.sizeToFit()
                titleLabel.center()
            }
            
            // only image
            if currentImage != nil  {
                imageView.setFrameSize((currentImage?.size)!)
                imageView.center()
            }
            
            // image && title
            if currentImage != nil && currentTitle != nil {
                
                let currentImagePos = self?.imagePosition
                let totalWidth = titleLabel.width + imageView.width
                
                // ImagePosition left
                if currentImagePos == .left {
                    imageView.left = ((self?.width)! - totalWidth) * 0.5
                    titleLabel.left = imageView.right
                }
                
                // ImagePosition right
                if currentImagePos == .right {
                    titleLabel.left = ((self?.width)! - totalWidth) * 0.5
                    imageView.left = titleLabel.right
                }
                
                // ImagePosition above
                let totalHeight = titleLabel.height + imageView.height
                if currentImagePos == .above {
                    imageView.top = ((self?.height)! - totalHeight) * 0.5
                    titleLabel.top = imageView.bottom
                }
                
                // ImagePosition below
                if currentImagePos == .below {
                    titleLabel.top = ((self?.height)! - totalHeight) * 0.5
                    imageView.top = titleLabel.bottom
                }

                // if ImagePosition set overlap, this will do nothing, because it is already overlap,
                // after titleLabel.center() imageView.center() called
                
                
                // apply titleInsets and imageInsets
                let titleInsets = (self?.titleEdgeInsets)!
                titleLabel.left = titleLabel.left + titleInsets.left
                titleLabel.left = titleLabel.left - titleInsets.right
                titleLabel.top = titleLabel.top + titleInsets.top
                titleLabel.top = titleLabel.top - titleInsets.bottom
                
                let imageInsets = (self?.imageEdgeInsets)!
                imageView.left = imageView.left + imageInsets.left
                imageView.left = imageView.left - imageInsets.right
                imageView.top = imageView.top + imageInsets.top
                imageView.top = imageView.top - imageInsets.bottom
            }
        }
    }
    

    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
    
    public override func apply(state: HUIControlState) {
        super.apply(state: state)
        
        if let title = currentTitle {
            titleLabel?.stringValue = title
        }
        if let attributedTitle = currentAttributedTitle {
            titleLabel?.attributedStringValue = attributedTitle
        }
        titleLabel?.textColor = currentTitleColor
        
        if let image = currentImage {
            imageView?.image = image
        }
        needsLayout = true
    }

    
}

