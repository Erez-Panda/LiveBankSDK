//
//  SignDocumentPanelView.swift
//  Panda4doctor
//
//  Created by Erez Haim on 9/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class SignDocumentPanelView: UIView {
    
    var onSign: ((signatureView: LinearInterpView, origin: CGPoint) -> ())?
    var onClose: ((sender: UIView) -> ())?

    @IBOutlet weak var watingLabel: UILabel!
    @IBOutlet weak var buttonleadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var signView: LinearInterpView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.layer.borderColor = SignColors.sharedInstance.buttonColor().CGColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        self.signView.blockTouches = true
    }
    
    func attachToView(view: UIView){
        view.addSubview(self)
        self.addConstraintsToSuperview(view, top: 0, left: 0, bottom: 0, right: 0)
    }

    @IBAction func sign(sender: AnyObject) {
        watingLabel.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.buttonTrailingConstraint.constant = -300
            self.buttonleadingConstraint.constant = 300
            self.layoutIfNeeded()
        })
        let offset = CGPointMake(frame.origin.x + signView.frame.origin.x, frame.origin.y + signView.frame.origin.y)
        onSign?(signatureView:signView, origin: offset)
    }
    @IBAction func cancel(sender: AnyObject) {
        self.removeFromSuperview()
        onClose?(sender: self)
    }

}
