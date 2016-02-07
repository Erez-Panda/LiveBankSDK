//
//  Colors.swift
//  Pods
//
//  Created by Erez Haim on 1/4/16.
//
//

import Foundation

class SignColors {
    
    static let sharedInstance = SignColors()
    
    init(){
        
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func mainColor()-> UIColor{
        return uicolorFromHex(0x464567)
    }
    
    func buttonColor()-> UIColor{
        return uicolorFromHex(0x67CA94)
    }
    
}
