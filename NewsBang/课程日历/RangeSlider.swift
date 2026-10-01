//
//  RangeSlider.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/20.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//
import UIKit
import QuartzCore

class RangeSlider:UIControl{
    /**滑块最小可选择的值*/
    var mininumValue:Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    /**滑块最大可选择的值*/
    var maxnumValue :Double = 12.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    /**当前第一个滑块的值*/
    var lowerValue:Double = 3.0 {
        didSet {
            updateLayerFrames()
        }
    }
    /**当前第二个滑块的值*/
    var upperValue:Double = 4.0 {
        didSet {
            updateLayerFrames()
        }
    }
    var previousLocation = CGPoint()
    
    var trackTintColor :UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var trackHighlightTintColor:UIColor = UIColor(red: 0, green: 0.45, blue: 0.94, alpha: 1) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var thumbTintColor:UIColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
        
    }
    
    var curvaceousness:CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
        
    }
    
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumberLayer()
    let upperThumbLayer = RangeSliderThumberLayer()
    
    /**等同于view的高度*/
    var thumbeWidth:CGFloat {
        return CGFloat(self.bounds.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //trackLayer.backgroundColor = UIColor.blueColor().CGColor
        trackLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(trackLayer)
        
        //lowerThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(lowerThumbLayer)
        
        //upperThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        upperThumbLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(upperThumbLayer)
        
        trackLayer.rangeSlider = self
        lowerThumbLayer.rangeSlider = self
        upperThumbLayer.rangeSlider = self
        
        updateLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //print("self.frame:\(self.frame)")
        trackLayer.frame = self.bounds.insetBy(dx: self.frame.height/2.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowThumbXposition = CGFloat(positionForValue(value: self.lowerValue) )
        lowerThumbLayer.frame = CGRect(x: lowThumbXposition, y: 0, width: thumbeWidth, height: thumbeWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbXposition = CGFloat(positionForValue(value: self.upperValue) )
        upperThumbLayer.frame = CGRect(x: upperThumbXposition, y: 0, width: thumbeWidth, height: thumbeWidth)
        upperThumbLayer.setNeedsDisplay()
        CATransaction.commit()
        
    }
    
    func positionForValue(value:Double) -> Double {
        return Double(self.bounds.width - thumbeWidth) * (value - mininumValue) / ( maxnumValue - mininumValue )
    }
    
    override var frame:CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        }
        else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    func boundValue(value:Double, toLowerValue lowValue:Double, upperValue:Double) -> Double {
        let fixedValue = min(max(value, lowValue), upperValue)
        //print("fixedValue:\(fixedValue)")
        return fixedValue
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maxnumValue - mininumValue) * deltaLocation  /  Double(( self.bounds.width - thumbeWidth ))
        
        previousLocation = location
        
        if lowerThumbLayer.highlighted == true {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: mininumValue, upperValue: upperValue)
        }
        else if upperThumbLayer.highlighted == true {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maxnumValue)
        }
        
        
        updateLayerFrames()
        
        sendActions(for: UIControl.Event.valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
        lowerValue = Double(lround(lowerValue))
        upperValue = Double(lround(upperValue))
        updateLayerFrames()
    }
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */

}
