//
//  SignatureTrainingView.swift
//  Pods
//
//  Created by Erez Haim on 2/4/16.
//
//

import UIKit

class SignatureTrainingView: UIView {
    
    var user = ""
    
    @IBOutlet weak var signWrapperView: UIView!
    var signView: SignDocumentPanelView?
    var okPanelView: OkCancelView?
    
    func onPanelOk(){
        signView?.disable()
        onSignViewSign(signView!.signView, origin: signView!.frame.origin)
    }
    
    func onPanelClean(){
        signView?.clean()
    }
    
    func attachToView(view: UIView){
        view.addSubview(self)
        self.addConstraintsToSuperview(view, top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func addNewSignature(){
        signView = NSBundle(forClass: LiveSign.self).loadNibNamed("SignDocumentPanelView", owner: self, options: nil)[0] as? SignDocumentPanelView
        signView?.attachToView(signWrapperView)
        signView?.onSign = onSignViewSign
        okPanelView = NSBundle(forClass: LiveSign.self).loadNibNamed("OkCancelView", owner: self, options: nil)[0] as? OkCancelView
        okPanelView?.onClean = onPanelClean
        okPanelView?.onOk = onPanelOk
        okPanelView?.attachToView(signView!, superView: self)
        
    }
    
    func onSignViewSign(signatureView: LinearInterpView, origin: CGPoint){
        var pointsStr = ""
        for line in signatureView.points {
            for point in line{
                pointsStr += "\(NSString(format: "%.3f",max(point.x,0))),\(NSString(format: "%.3f",max(point.y,0)))-"
            }
            pointsStr += "***"
        }
        let data: Dictionary<String, AnyObject> = [
            "points": pointsStr,
            "creator": user,
            "training": true]
        RemoteAPI.sharedInstance.newSignature(data) { (result) -> Void in
            //
        }
        signView?.removeFromSuperview()
        okPanelView?.removeFromSuperview()
        addNewSignature()
    }

    override func awakeFromNib() {
        addNewSignature()
        
    }
    
    @IBAction func onCancelTouch(sender: AnyObject) {
        self.fadeOut(duration: 0.325, remove: true)
    }
}
