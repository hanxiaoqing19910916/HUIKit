//
//  HUIImageView.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/11/21.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Cocoa
import ImageIO

/// `AnimatedImageView` is a subclass of `NSView` for displaying animated image.
open class HAnimatedImageView: NSView {
    
    // MARK: - Public property
    /// Whether automatically play the animation when the view become visible. Default is true.
    public var autoPlayAnimatedImage = true
    
    /// The size of the frame cache.
    public var framePreloadCount = 10
    
    /// Specifies whether the GIF frames should be pre-scaled to save memory. Default is true.
    public var needsPrescaling = true
    
    // MARK: - Private property
    /// `Animator` instance that holds the frames of a specific image in memory.
    private var animator: Animator?
    
    /// A flag to avoid invalidating the displayLink on deinit if it was never created, because displayLink is so lazy. :D
    private var isDisplayLinkInitialized: Bool = false
    
    /// A display link that keeps calling the `updateFrame` method on every screen refresh.
    private var displayLink: CVDisplayLink?
    
    private func createDisplayLink() {
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let displayLink = displayLink else {
            return
        }
        
        let callback: CVDisplayLinkOutputCallback = { (_, _, _, _, _, userInfo) -> CVReturn in
            let targetProxy = Unmanaged<HAnimatedImageView>.fromOpaque(userInfo!).takeUnretainedValue()
            DispatchQueue.main.async {
                targetProxy.updateFrame()
            }
            return kCVReturnSuccess
        }
        
        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        CVDisplayLinkSetOutputCallback(displayLink, callback, userInfo)
    }
    
    // MARK: - Override
    open var animateImageData: NSData? {
        didSet {
            if animateImageData != oldValue {
                reset()
            }
            layer?.setNeedsDisplay()
        }
    }

    open var animateImageName: String? {
        didSet {
            if animateImageName != oldValue {
                let resPath = Bundle.main.path(forResource: animateImageName, ofType: nil)!
                animateImageData = NSData(contentsOfFile: resPath)
            }
        }
    }

    
    open var isAnimating: Bool {
        if isDisplayLinkInitialized {
            return CVDisplayLinkIsRunning(displayLink!)
        } else {
            return false
        }
    }
    

    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        didMove()
    }
    
    override open func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        didMove()
    }
    
    
    // MARK: - Private method
    /// Reset the animator.
    private func reset() {
        animator = nil
        let imageSource = CGImageSourceCreateWithData(animateImageData as! CFData, nil)
        animator = Animator(imageSource: imageSource!, contentMode: 0, size: bounds.size, framePreloadCount: framePreloadCount)
        animator?.needsPrescaling = needsPrescaling
        animator?.prepareFramesAsynchronously()
        didMove()
    }
    
    private func didMove() {
        if autoPlayAnimatedImage && animator != nil {
            if let _ = superview, let _ = window {
                createDisplayLink()
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    /// Starts the animation.
    open func startAnimating() {
        if self.isAnimating {
            return
        } else {
            CVDisplayLinkStart(displayLink!)
        }
    }
    
    /// Stops the animation.
    open func stopAnimating() {
        if isDisplayLinkInitialized {
            CVDisplayLinkStop(displayLink!)
        }
    }
    
    
    /// Update the current frame with the displayLink duration.
    private func updateFrame() {
        let duration: CFTimeInterval = CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLink!)
        if animator?.updateCurrentFrame(duration: duration) ?? false {
            needsDisplay = true
        }
    }
    
    override open func updateLayer() {
        if let currentFrame = animator?.currentFrame {
            layer?.contents = currentFrame.cgImage
        }
    }
    

    override open var wantsUpdateLayer: Bool {
        return true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    deinit {
        if isDisplayLinkInitialized {
            CVDisplayLinkStop(displayLink!)
        }
    }
}

/// Keeps a reference to an `Image` instance and its duration as a GIF frame.
struct AnimatedFrame {
    var image: NSImage?
    let duration: TimeInterval
    static let null: AnimatedFrame = AnimatedFrame(image: .none, duration: 0.0)
}

// MARK: - Animator
class Animator {
    // MARK: Private property
    fileprivate let size: CGSize
    fileprivate let maxFrameCount: Int
    fileprivate let imageSource: CGImageSource
    
    fileprivate var animatedFrames = [AnimatedFrame]()
    fileprivate let maxTimeStep: TimeInterval = 1.0
    fileprivate var frameCount = 0
    fileprivate var currentFrameIndex = 0
    fileprivate var currentPreloadIndex = 0
    fileprivate var timeSinceLastFrameChange: TimeInterval = 0.0
    fileprivate var needsPrescaling = true
    
    /// Loop count of animated image.
    private var loopCount = 0
    
    var currentFrame: NSImage? {
        return frame(at: currentFrameIndex)
    }
    
    
    private lazy var preloadQueue: DispatchQueue = {
        return DispatchQueue(label: "com.onevcat.Kingfisher.Animator.preloadQueue")
    }()
    
    /**
     Init an animator with image source reference.
     
     - parameter imageSource: The reference of animated image.
     - parameter contentMode: Content mode of AnimatedImageView.
     - parameter size: Size of AnimatedImageView.
     - parameter framePreloadCount: Frame cache size.
     
     - returns: The animator object.
     */
    init(imageSource source: CGImageSource, contentMode mode: Int, size: CGSize, framePreloadCount count: Int) {
        self.imageSource = source
        self.size = size
        self.maxFrameCount = count
    }
    
    func frame(at index: Int) -> NSImage? {
        return animatedFrames[safe: index]?.image
    }
    
    func prepareFramesAsynchronously() {
        preloadQueue.async { [weak self] in
            self?.prepareFrames()
        }
    }
    
    private func prepareFrames() {
        frameCount = CGImageSourceGetCount(imageSource)
        
        if let properties = CGImageSourceCopyProperties(imageSource, nil),
            let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
            let loopCount = gifInfo[kCGImagePropertyGIFLoopCount as String] as? Int {
            self.loopCount = loopCount
        }
        
        let frameToProcess = min(frameCount, maxFrameCount)
        animatedFrames.reserveCapacity(frameToProcess)
        animatedFrames = (0..<frameToProcess).reduce([]) { $0 + pure(prepareFrame(at: $1))}
        currentPreloadIndex = (frameToProcess + 1) % frameCount
    }
    
    private func prepareFrame(at index: Int) -> AnimatedFrame {
        
        guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
            return AnimatedFrame.null
        }
        
        let defaultGIFFrameDuration = 0.100
        let frameDuration = imageSource.gifProperties(at: index).map {
            gifInfo -> Double in
            
            let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as Double?
            let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as Double?
            let duration = unclampedDelayTime ?? delayTime ?? 0.0
            
            /**
             http://opensource.apple.com/source/WebCore/WebCore-7600.1.25/platform/graphics/cg/ImageSourceCG.cpp
             Many annoying ads specify a 0 duration to make an image flash as quickly as
             possible. We follow Safari and Firefox's behavior and use a duration of 100 ms
             for any frames that specify a duration of <= 10 ms.
             See <rdar://problem/7689300> and <http://webkit.org/b/36082> for more information.
             
             See also: http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser.
             */
            return duration > 0.011 ? duration : defaultGIFFrameDuration
            } ?? defaultGIFFrameDuration
        
        let image = NSImage(cgImage: imageRef, size: size)
        let scaledImage: NSImage?
        
        if needsPrescaling {
            scaledImage = image
        } else {
            scaledImage = image
        }
        
        return AnimatedFrame(image: scaledImage, duration: frameDuration)
    }
    
    /**
     Updates the current frame if necessary using the frame timer and the duration of each frame in `animatedFrames`.
     */
    func updateCurrentFrame(duration: CFTimeInterval) -> Bool {
        timeSinceLastFrameChange += min(maxTimeStep, duration)
        guard let frameDuration = animatedFrames[safe: currentFrameIndex]?.duration, frameDuration <= timeSinceLastFrameChange else {
            return false
        }
        
        timeSinceLastFrameChange -= frameDuration
        
        let lastFrameIndex = currentFrameIndex
        currentFrameIndex += 1
        currentFrameIndex = currentFrameIndex % animatedFrames.count
        
        if animatedFrames.count < frameCount {
            preloadFrameAsynchronously(at: lastFrameIndex)
        }
        return true
    }
    
    private func preloadFrameAsynchronously(at index: Int) {
        preloadQueue.async { [weak self] in
            self?.preloadFrame(at: index)
        }
    }
    
    private func preloadFrame(at index: Int) {
        animatedFrames[index] = prepareFrame(at: currentPreloadIndex)
        currentPreloadIndex += 1
        currentPreloadIndex = currentPreloadIndex % frameCount
    }
}

extension CGImageSource {
    func gifProperties(at index: Int) -> [String: Double]? {
        let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as Dictionary?
        return properties?[kCGImagePropertyGIFDictionary] as? [String: Double]
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

private func pure<T>(_ value: T) -> [T] {
    return [value]
}
