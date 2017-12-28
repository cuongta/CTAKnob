//
//  CTAKnobView.swift
//  CTAKnob
//
//  Created by Cuong Ta on 12/26/17.
//  Copyright © 2017 Cuong Ta. All rights reserved.
//

import UIKit

@IBDesignable
public class CTAKnobView: UIControl {

    // MARK: Public
    
    public var clockwise: Bool = true
    @IBInspectable public var ringColor: UIColor = UIColor.init(white: 0.9, alpha: 1.0)
    @IBInspectable public var handleColor: UIColor = UIColor.init(white: 0.9, alpha: 1.0)
    
    public var value: Float {
        get { return _value }
        set (newValue) {
            
            _value = newValue
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            updateHandle()
            CATransaction.commit()
            
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }
    
    // MARK: Private
    
    private var _value: Float = 0
    
    private var containerLayer = CALayer()
    private var ringLayer = CAShapeLayer()
    private var handleLayer = CALayer()
    private var dotLayer = CALayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContainer()
        setupRing()
        setupHandle()
        setupDot()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupContainer()
        setupRing()
        setupHandle()
        setupDot()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContainer()
        updateRing()
        updateHandle()
        updateDot()
    }
    
    // MARK: Setup
    
    func setupContainer(){
        layer.addSublayer(containerLayer)
    }
    
    func setupRing(){
        ringLayer.borderWidth = 4
        
        ringLayer.backgroundColor = UIColor.clear.cgColor
        ringLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        containerLayer.addSublayer(ringLayer)
    }
    
    func setupHandle(){
        containerLayer.addSublayer(handleLayer)
    }
    
    func setupDot(){
        dotLayer.borderWidth = 5
        
        dotLayer.backgroundColor = UIColor.white.cgColor
        dotLayer.shadowColor = UIColor.black.cgColor
        dotLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        dotLayer.shadowRadius = 2
        dotLayer.shadowOpacity = 0.3

        handleLayer.addSublayer(dotLayer)
    }
    
    // MARK: Update
    
    func updateContainer(){
        containerLayer.frame = bounds
    }
    
    func updateRing(){
        ringLayer.frame = CGRect.init(
            x: containerLayer.bounds.origin.x,
            y: containerLayer.bounds.origin.y,
            width: containerLayer.bounds.size.width*0.75,
            height: containerLayer.bounds.size.height*0.75)
        ringLayer.cornerRadius = ringLayer.bounds.width/2.0
        ringLayer.borderColor = ringColor.cgColor
        ringLayer.position = containerLayer.position
    }
    
    func updateHandle(){
        let handleWidth = containerLayer.bounds.size.width*0.25
        
        handleLayer.bounds.size = CGSize.init(width: handleWidth, height: ringLayer.bounds.size.width)
        handleLayer.cornerRadius = handleLayer.bounds.size.width/2.0
        handleLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        handleLayer.position = ringLayer.position
        handleLayer.transform = valueToPostion()
    }
    
    func updateDot(){
        let width = handleLayer.bounds.width
        
        dotLayer.bounds.size = CGSize.init(width: width, height: width)
        dotLayer.cornerRadius = dotLayer.bounds.size.width/2.0
        dotLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        dotLayer.borderColor = handleColor.cgColor
        
        dotLayer.position = CGPoint.init(
            x: handleLayer.bounds.width/2.0,
            y: handleLayer.bounds.height/2.0-handleLayer.bounds.height/2.0)
    }
    
    // MARK: Util

    func valueToPostion() -> CATransform3D {
        
        var angle = value
        if !clockwise {
            angle *= -1
        }
        
        return CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
    }
    
    func valueFromPosition(position: CGPoint) -> Float {
        
        let newX = position.x-bounds.width/2
        let newY = (-position.y)+bounds.height/2
        
        let offset: Float = Float(Double.pi/2.0)
        var angle: Float = Float(atan(newY/newX)) - offset
        if newX >= 0 && newY >= 0 { // 1
            angle = Float(Double.pi * 2.0) + angle
        } else if newX >= 0 && newY <= 0 { // 4
            angle = Float(Double.pi * 2.0) + angle
        } else if newX <= 0 && newY >= 0 { // 2
            angle = Float(Double.pi) + angle
        } else { // 3
            angle = angle + Float(Double.pi)
        }
        
        if clockwise {
            angle = (Float(Double.pi * 2.0)-angle)
        }
        
        return angle
    }
    
    // MARK: Touches

    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isHighlighted = true
        dotLayer.transform = CATransform3DMakeScale(1.25, 1.25, 1)
        let position = touch.location(in: self)
        value = valueFromPosition(position: position)
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let position = touch.location(in: self)
        value = valueFromPosition(position: position)
        return true
    }
    
    open override func cancelTracking(with event: UIEvent?) {
        dotLayer.transform = CATransform3DIdentity
        self.isHighlighted = false
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        dotLayer.transform = CATransform3DIdentity
        self.isHighlighted = false
    }
    
}
