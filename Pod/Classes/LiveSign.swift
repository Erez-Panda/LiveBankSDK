//
//  LiveSign.swift
//  Pods
//
//  Created by Erez Haim on 1/4/16.
//
//

import Foundation

public class LiveSign: NSObject {
    
    public static let sharedInstance = LiveSign()
    
    public func startSession(id: String, superView: UIView, user: String? = nil, completion: ((view: UIView) -> Void)? = nil) -> Void{
        Session.sharedInstance.connect(id) { (result) -> Void in
            let documentView = NSBundle(forClass: LiveSign.self).loadNibNamed("DocumentView", owner: self, options: nil)[0] as! DocumentView
            documentView.attachToView(superView)
            documentView.user = user
            completion?(view: documentView)
        }
    }
    
    public func openTrainingPanel(user: String , superView: UIView, completion: ((view: UIView) -> Void)? = nil) -> Void{
        let trainingView = NSBundle(forClass: LiveSign.self).loadNibNamed("SignatureTrainingView", owner: self, options: nil)[0] as! SignatureTrainingView
        trainingView.attachToView(superView)
        trainingView.user = user
        completion?(view: trainingView)
    }

}

extension UIView{
    func addConstraintsToSuperview(superView: UIView, top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?) -> Dictionary<String, NSLayoutConstraint> {
        var result : Dictionary<String, NSLayoutConstraint> = [:]
        self.translatesAutoresizingMaskIntoConstraints = false
        if let t = top {
            let topConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: t)
            superView.addConstraint(topConstraint)
            result["top"] = topConstraint
        }
        if let l = left {
            let leftConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: l)
            superView.addConstraint(leftConstraint)
            result["left"] = leftConstraint
        }
        if let b = bottom {
            let bottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: b)
            superView.addConstraint(bottomConstraint)
            result["bottom"] = bottomConstraint
        }
        
        if let r = right {
            let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: r)
            superView.addConstraint(rightConstraint)
            result["right"] = rightConstraint
        }
        return result
    }
    
    func addSizeConstraints (width: CGFloat?, height: CGFloat?) -> Dictionary<String, NSLayoutConstraint>{
        self.translatesAutoresizingMaskIntoConstraints = false
        var widthConstraint:NSLayoutConstraint = NSLayoutConstraint()
        var hightConstraint:NSLayoutConstraint = NSLayoutConstraint()
        if let w = width {
            widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: w)
            self.addConstraint(widthConstraint)
        }
        if let h = height {
            hightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: h)
            self.addConstraint(hightConstraint)
        }
        return ["width":widthConstraint, "height":hightConstraint]
    }
}