//
//  ViewController.swift
//  LiveSignSDK
//
//  Created by Erez Haim on 01/04/2016.
//  Copyright (c) 2016 Erez Haim. All rights reserved.
//

import UIKit
import LiveSignSDK

class ViewController: UIViewController {

    @IBOutlet weak var userId: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func training(sender: AnyObject) {
        LiveSign.sharedInstance.openTrainingPanel(userId.text!, superView: self.view)
    }
    @IBAction func sign(sender: AnyObject) {
        LiveSign.sharedInstance.startSession("1", superView: self.view, user: userId.text)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

