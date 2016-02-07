//
//  ControlPanelView.swift
//  Pods
//
//  Created by Erez Haim on 2/2/16.
//
//

import UIKit

class ControlPanelView: UIView {
    
    let HEIGHT:CGFloat = 100
    var frameConstraints: Dictionary<String, NSLayoutConstraint>?
    var sizeConstraints: Dictionary<String, NSLayoutConstraint>?
    var onLeft: (() -> Void)?
    var onRight: (() -> Void)?
    var onSign: (() -> Void)?
    
    
    func addGradientLayer(topColor: UIColor, bottomColor: UIColor) -> CAGradientLayer{
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        // Yes, this is ugly...
        layer.frame.size.width = UIScreen.mainScreen().bounds.width
        layer.frame.origin = CGPointMake(0.0,0.0)
        layer.colors = [topColor.CGColor,bottomColor.CGColor]
        self.layer.insertSublayer(layer, atIndex: 0)
        return layer
    }
    
    func attachToView(view: UIView){
        view.addSubview(self)
        sizeConstraints = self.addSizeConstraints(nil, height: HEIGHT)
        frameConstraints = self.addConstraintsToSuperview(view, top: nil, left: 0, bottom: 0, right: 0)
        self.layoutIfNeeded()
        addGradientLayer(UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.0),
            bottomColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.9))
    }
    
    
    func setBottomConstraint(bottom: CGFloat){
        if nil != frameConstraints?["bottom"]{
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frameConstraints!["bottom"]!.constant = bottom
                self.layoutIfNeeded()
            })
        }
    }
    
    func isVisible() -> Bool{
        if let bottom = frameConstraints?["bottom"]{
            if bottom.constant == 0 {
                return true
            }
        }
        return false
    }
    
    func hide(){
        setBottomConstraint(self.HEIGHT)
    }
    
    func show(){
        setBottomConstraint(0)
    }

    @IBAction func onLeftTouch(sender: AnyObject) {
        onLeft?()
    }
    
    
    @IBAction func onRightTouch(sender: AnyObject) {
        onRight?()
    }
    
    
    @IBAction func onSignTouch(sender: AnyObject) {
        onSign?()
    }
    
    
    override func awakeFromNib() {
    
    }

}
