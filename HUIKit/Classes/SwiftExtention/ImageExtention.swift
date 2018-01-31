//
//  ImageExtention.swift
//
//  Created by hanxiaoqing on 2017/11/7.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa

public extension CGImage {
    
    var backingSize:NSSize {
        return NSMakeSize(CGFloat(width) / 2.0, CGFloat(height) / 2.0)
    }
    
    var size:NSSize {
        return NSMakeSize(CGFloat(width), CGFloat(height))
    }
    
    var scale:CGFloat {
        return 2.0
    }
    
    /// translate CGImage to NSImage, have not tested
    func toNSImage() -> NSImage {
        let image = NSImage(size: CGSize(width: CGFloat(width), height: CGFloat(height)))
        image.lockFocus()
        let context = NSGraphicsContext.current?.graphicsPort as! CGContext
        context.draw(self, in: CGRect(origin: CGPoint(), size: image.size))
        image.unlockFocus()
        return image
    }
    
}


public extension NSImage {
    
    public var cgImage: CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    func saveImageToFile(path: String, compressFactor: CGFloat) {
        let JPEGdata = NSImageJPEGRepresentation(self, compressFactor)
        try? JPEGdata?.write(to: URL(fileURLWithPath: path))
    }
    
    func scaleImageTo(width: CGFloat) -> NSImage? {
        // scale aspect ratio
        let height = size.height * (width / size.width)
        
        // creat a new NSImage init with scaled size
        let scaleImage = NSImage(size: CGSize(width: width, height: height))
        
        //  lockFocus and draw
        let scaleRect = CGRect(x: 0, y: 0, width: width, height: height)
        scaleImage.lockFocus()
        draw(in: scaleRect, from: CGRect(), operation: .sourceOver, fraction: 1.0)
        scaleImage.unlockFocus()
        
        return scaleImage
    }
    
    public var cgImageSource: CGImageSource? {
        if size.width == 0 ||  size.height == 0 {
            return nil
        }
        if let imageData = tiffRepresentation {
            return CGImageSourceCreateWithData(imageData as CFData, nil)
        } else {
            return nil
        }
    }
    
}



public func NSImagePNGRepresentation(_ image: NSImage) -> Data? {
    guard let cgimage = image.cgImage else {
        return nil
    }
    let rep = NSBitmapImageRep(cgImage: cgimage)
    return rep.representation(using: .png, properties: [:])
}

public func NSImageJPEGRepresentation(_ image: NSImage, _ compressionQuality: CGFloat) -> Data? {
    
    let data: Data? = image.tiffRepresentation(using: .jpeg, factor: Float(compressionQuality))
    if let data = data {
        // creat this NSBitmapImageRep object has two ways:
        // one: init by data form NSImage tiffRepresentation
        let imageRep = NSBitmapImageRep(data: data)
        
        // two: init by cgImage form NSImage cgImage
        // imageRep = NSBitmapImageRep(cgImage: image.cgImage)
        
        // unknow which is best, use the first way above....
        let properties: [NSBitmapImageRep.PropertyKey : Any] = [.compressionFactor : compressionQuality]
        return imageRep?.representation(using: .jpeg, properties: properties)
    } else {
        return nil;
    }
}
