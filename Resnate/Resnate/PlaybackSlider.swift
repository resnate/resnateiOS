//
//  PlaybackSlider.swift
//  Resnate
//
//  Created by Amir Moosavi on 16/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

class PlaybackSlider: UIControl
{
    var currentPosition : Float = 0.0
        {
        didSet
        {
            updateLayers()
        }
    }
    
    var currentBuffer : Float = 0.0
        {
        didSet
        {
            updateLayers()
        }
    }
    
    var backgroundLayerColor : UIColor = UIColor.lightGrayColor()
    var progressLayerColor : UIColor = UIColor.redColor()
    var bufferLayerColor : UIColor = UIColor.darkGrayColor()
    var positionRingLayerColor : UIColor = UIColor.redColor()
    
    var backgroundLayer : CAShapeLayer!
    private var progressLayer : CAShapeLayer!
    private var bufferLayer : CAShapeLayer!
    private var positionRingLayer : CAShapeLayer!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func drawRect(rect: CGRect)
    {
        updateLayers()
    }
    
    private func initialize()
    {
        self.backgroundColor = UIColor.clearColor()
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backgroundLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: self.frame.size.width - 10, height: self.frame.size.height / 4.0)).CGPath
        backgroundLayer.fillColor = backgroundLayerColor.CGColor
        backgroundLayer.backgroundColor = UIColor.clearColor().CGColor
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        bufferLayer = CAShapeLayer()
        bufferLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        positionRingLayer = CAShapeLayer()
        positionRingLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(bufferLayer)
        self.layer.addSublayer(progressLayer)
        self.layer.addSublayer(positionRingLayer)
        
        updateLayers()
    }
    
    private func updateLayers()
    {
        updateBackground()
        updateProgressLine()
        updateBufferLine()
        updatePositionRing()
    }
    
    private func updateBackground(){
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            backgroundLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: UIScreen.mainScreen().bounds.width - 10, height: self.frame.size.height / 4)).CGPath
        } else {
            backgroundLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: UIScreen.mainScreen().bounds.height - 10, height: self.frame.size.height / 4)).CGPath
        }
        
        
        
    }
    
    private func updateProgressLine()
    {
        var w = self.frame.size.width * CGFloat(currentPosition)
        
        if w > self.frame.size.width
        {
            w = self.frame.size.width
        }
        
        progressLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: w, height: self.frame.size.height / 4)).CGPath
        progressLayer.fillColor = progressLayerColor.CGColor
        progressLayer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    private func updateBufferLine()
    {
        var w = self.frame.size.width * CGFloat(currentBuffer)
        
        bufferLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: w, height: self.frame.size.height / 4)).CGPath
        bufferLayer.fillColor = bufferLayerColor.CGColor
        bufferLayer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    private func updatePositionRing()
    {
        var _x = self.frame.size.width * CGFloat(currentPosition)
        
        if _x > self.frame.size.width
        {
            _x = self.frame.size.width
        }
        
        positionRingLayer.path = UIBezierPath(ovalInRect: CGRect(x: _x, y: self.frame.size.height/8, width: self.frame.size.height/2, height: self.frame.size.height/2)).CGPath
        positionRingLayer.fillColor = positionRingLayerColor.CGColor
        positionRingLayer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        let point = touch.locationInView(self)
        
        var _xb = (self.frame.size.width * CGFloat(currentBuffer)) - self.frame.size.height
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let player = appDelegate.ytPlayer.videoPlayer
        
        if (point.x > 0)
        {
            currentPosition = Float(point.x / self.frame.size.width)
            appDelegate.ytPlayer.touches = true
            player.pause()
            self.setNeedsDisplay()
            
            player.getDuration({ (youTubeTime, doubleTime) -> () in
                let properTime = doubleTime * Double(self.currentPosition)
                appDelegate.ytPlayer.currentTime.text = timeToHHMMSS(properTime)
                player.seekTo(Float(properTime), seekAhead: true)
            })
            

        }
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        let point = touch!.locationInView(self)
        
        var _xb = (self.frame.size.width * CGFloat(currentBuffer)) - self.frame.size.height
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let player = appDelegate.ytPlayer.videoPlayer
        
        if (point.x > 0)
        {
            currentPosition = Float(point.x / self.frame.size.width)
            appDelegate.ytPlayer.touches = false
            
            player.play()
            self.setNeedsDisplay()
            appDelegate.ytPlayer.fadeOutOverlay()
            
        }
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let player = appDelegate.ytPlayer.videoPlayer
        player.play()
        appDelegate.ytPlayer.fadeOutOverlay()
    }
    
}