//
//  OkCancel.swift
//  Pods
//
//  Created by Erez Haim on 2/7/16.
//
//

import UIKit

class OkCancelView: UIView {
    
    var onOk: (() -> Void)?
    var onCancel: (() -> Void)?
    var onClean: (() -> Void)?

    @IBAction func clean(sender: AnyObject) {
        //self.removeFromSuperview()
        //onCacnel?()
        onClean?()
    }
    @IBAction func cancel(sender: AnyObject) {
        onCancel?()
    }

    @IBAction func ok(sender: AnyObject) {
        onOk?()
    }
    
    override func awakeFromNib() {
        
    }
    
    func attachToView(view:UIView, superView: UIView){
        superView.addSubview(self)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        superView.addConstraint(widthConstraint)
        let topConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        superView.addConstraint(topConstraint)
        let centerConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        superView.addConstraint(centerConstraint)
        self.addSizeConstraints(nil, height: 80.0)
    }

}
