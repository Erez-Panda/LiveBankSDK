//
//  LinearInterpView.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class PassiveLinearInterpView: UIView {
    
    var path : UIBezierPath?
    var enabled = false


    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        SignColors.sharedInstance.uicolorFromHex(0x000F7D).setStroke()
        path?.stroke()
        // Drawing code
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPath()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initPath()
        
    }
    
    func initPath(){
        self.multipleTouchEnabled = false
        self.backgroundColor = UIColor.clearColor()
        path = UIBezierPath()
        path?.lineWidth = 1.0
    }
    
    func moveToPoint(point: CGPoint){
        path?.moveToPoint(point)
    }
    
    func addPoint(point: CGPoint){
        path?.addLineToPoint(point)
        self.setNeedsDisplay()
    }
    
    
    func cleanView(){
        self.path?.removeAllPoints()
        self.setNeedsDisplay()
    }
    

}
