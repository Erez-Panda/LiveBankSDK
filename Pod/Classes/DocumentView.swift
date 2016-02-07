//
//  CallNewViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit




class DocumentView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate{
    
    var user: String?

    @IBOutlet weak var presentaionImage: UIImageView?
//    @IBOutlet weak var drawingView: PassiveLinearInterpView!
    @IBOutlet weak var scrollView: UIScrollView?
    
    var isDragging = false
    var isFirstLoad = true
    var currentImage: UIImage?
    var currentImageUrl: String?
    var showIncoming = true
    var signView: SignDocumentPanelView?
    var signedImageView: UIImageView?
    var controlPanelView: ControlPanelView?
    var controlPanelTimer: NSTimer?
    
    var preLoadedImages: Array<Dictionary<Int, UIImage?>> = []
    var signatureBoxes:Dictionary<Int, Array<Dictionary<String, AnyObject>>> = [:]
    var currentDocument: Int?
    var currentPage: Int?
    var currentBox: Int?
    
    
    var oldPreLoadedImages: Dictionary<String, UIImage?> = [:]
    var modifiedImages: Dictionary<String, UIImage?> = [:]
    
    var lastSignatureData: Dictionary<String, AnyObject>?

    
    
    
    override func awakeFromNib() {
        
        if (isFirstLoad){
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"tap:"))
            let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
            swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            swipeRight.cancelsTouchesInView = false
            self.addGestureRecognizer(swipeRight)
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
            swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            swipeLeft.cancelsTouchesInView = false
            self.addGestureRecognizer(swipeLeft)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
            if ((currentImage) != nil){
                presentaionImage?.image = currentImage
            }
            scrollView?.delegate = self
            addControlPanel()
            registerForMessages()
            isFirstLoad = false
        }

        // Do any additional setup after loading the view.
    }
    
    func attachToView(view: UIView){
        view.addSubview(self)
        self.addConstraintsToSuperview(view, top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return presentaionImage
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scale == 1 {
            scrollView.scrollEnabled = false
        } else {
            scrollView.scrollEnabled = true
        }
    }
    
    func onSignViewClose(sender: UIView){
        self.signView = nil
        if scrollView?.zoomScale > 1{
            scrollView?.scrollEnabled = true
        }
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }

    func sendSignaturePoints(signatureView: LinearInterpView, origin: CGPoint, imgSize: CGSize, scaleRatio: CGFloat, zoom: CGFloat){
        var user = "USER-ID"
        if self.user != nil {
            user = self.user!
        } else if let creator = Session.sharedInstance.currentCall?["callee"] as? String{
            user = creator
        }
        var data = [
            // TODO: add the actucal userId
            "creator": user,
            "width": signatureView.frame.width,
            "height": signatureView.frame.height,
            "left": origin.x/imgSize.width,
            "top": origin.y/imgSize.height,
            "image_width": imgSize.width*(zoom/scaleRatio),
            "image_height": imgSize.height*(zoom/scaleRatio),
            "call": Session.sharedInstance.currentCall!["id"] as! Int,
            "page_number": self.currentPage!,
            "document_id": self.currentDocument!,
            "tracking": randomAlphaNumericString(6),
            "type": "signature",
            "tag": self.signatureBoxes[currentPage!]![currentBox!]["type"] as! String + "-signed"
        ] as Dictionary<String, AnyObject>
//        var pointsStr = "width=\()&height=\(signatureView.frame.height)&originX=\(origin.x/imgSize.width)&originY=\(origin.y/imgSize.height)&screenWidth=\(imgSize.width/scaleRatio)&screenHeight=\(imgSize.height/scaleRatio)&zoom=\(zoom)&points="
        var pointsStr = ""
        for line in signatureView.points {
            for point in line{
                pointsStr += "\(NSString(format: "%.3f",max(point.x,0))),\(NSString(format: "%.3f",max(point.y,0)))-"
            }
            pointsStr += "***"
        }
        data["points"] = pointsStr
        Session.sharedInstance.sendMessage("signature_points", data: data)
    }
    
    func addSignatureToImage(){
        if let data = lastSignatureData{
            let scaledSignView = data["scaledSignView"] as! PassiveLinearInterpView
            let X = data["X"] as! CGFloat
            let Y = data["Y"] as! CGFloat
            if nil != currentBox {
                self.signatureBoxes[currentPage!]![currentBox!]["originaltype"] = self.signatureBoxes[currentPage!]![currentBox!]["type"]
                self.signatureBoxes[currentPage!]![currentBox!]["type"] =  self.signatureBoxes[currentPage!]![currentBox!]["type"] as! String + "-signed"
            }
            let screen =  UIScreen.mainScreen().bounds
            let document = presentaionImage!.image!
            let scaleRatio = max(document.size.width/screen.width, document.size.height/screen.height)
            //One of these has to be 0
            let heightDiff = (screen.height*scaleRatio) - document.size.height
            let widthDiff = (screen.width*scaleRatio) - document.size.width

            let scaledSignImage = takeScreenshot(scaledSignView)
            UIGraphicsBeginImageContext(document.size)
            document.drawInRect(CGRectMake(0,0,document.size.width, document.size.height))
            scaledSignImage.drawInRect(CGRectMake((X*scaleRatio)-widthDiff/2,(Y*scaleRatio)-heightDiff/2,scaledSignView.frame.width, scaledSignView.frame.height))
            let signedDoc = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let image: UIImage = signedDoc
            self.presentaionImage?.image = image
            if currentImageUrl != nil {
                modifiedImages[currentImageUrl!] = image
            }
            if currentPage != nil && currentDocument != nil {
                setImageAtIndex(image, document: currentDocument!, page: currentPage!)
            }
            self.signView?.removeFromSuperview()
            self.signView = nil
            scrollView?.scrollEnabled = false
            self.scrollView?.setZoomScale(1, animated: false)
        }
    }
    
    func onSignViewSign(signatureView: LinearInterpView, origin: CGPoint){
        let screen =  UIScreen.mainScreen().bounds
        let zoom = scrollView!.zoomScale
        //let offset = scrollView!.contentOffset
        let document = presentaionImage!.image!
        //Image is aspect fit, scale factor will be the biggest change on image
        let scaleRatio = max(document.size.width/screen.width, document.size.height/screen.height)
        let X = (origin.x+scrollView!.contentOffset.x)/zoom
        let Y = (origin.y+scrollView!.contentOffset.y)/zoom
        
        let scaledSignView = PassiveLinearInterpView(frame: CGRectMake(0,0,signatureView.frame.width*scaleRatio/zoom, signatureView.frame.height*scaleRatio/zoom))
        //scaledSignView.path?.lineWidth *= scaleRatio/zoom
        for line in signatureView.points {
            for i in 0 ..< line.count{
                if i==0 {
                    scaledSignView.moveToPoint(CGPoint(x: line[i].x*scaleRatio/zoom , y: line[i].y*scaleRatio/zoom))
                } else {
                    scaledSignView.addPoint(CGPoint(x: line[i].x*scaleRatio/zoom , y: line[i].y*scaleRatio/zoom))
                }
            }
        }
        //One of these has to be 0
        let heightDiff = (screen.height*scaleRatio) - document.size.height
        let widthDiff = (screen.width*scaleRatio) - document.size.width
        
        sendSignaturePoints(signatureView, origin:CGPointMake((X*scaleRatio)-widthDiff/2,(Y*scaleRatio)-heightDiff/2), imgSize:CGSizeMake( document.size.width, document.size.height), scaleRatio: scaleRatio, zoom:zoom)
        
        lastSignatureData = [
            "scaledSignView": scaledSignView,
            "X": X,
            "Y": Y
        ]
        
    }
    
    func takeScreenshot(view: UIView) -> UIImage{
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func closeOpenPanels(){
        signView?.removeFromSuperview()
        signView = nil
        if scrollView?.zoomScale > 1{
            scrollView?.scrollEnabled = true
        }
    }
    
    func rotated(){
        if signView != nil && currentBox != nil {
            let box = self.signatureBoxes[self.currentPage!]![currentBox!]
            var bounds = UIScreen.mainScreen().bounds.size
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                bounds = CGSizeMake(bounds.height, bounds.width)
            }
            //let h: CGFloat = 120
            let w: CGFloat = 0.8*bounds.width
            let document = self.presentaionImage!.image!
            let top = box["top"] as! CGFloat*document.size.height
            let left = (box["left"] as! CGFloat)*document.size.width
            let width = box["width"] as! CGFloat*document.size.width
            let height = box["height"] as! CGFloat*document.size.height
            
            let scale = w/width
            //Image is aspect fit, scale factor will be the biggest change on image
            let scaleRatio = max(document.size.width/bounds.width, document.size.height/bounds.height)
            self.scrollView?.setZoomScale(scaleRatio*scale, animated: false)
            
            //One of these has to be 0
            let heightDiff = (bounds.height*scaleRatio) - document.size.height
            let widthDiff = (bounds.width*scaleRatio) - document.size.width
            
            let X = left*scale+widthDiff-((bounds.width-(4/3)*w)/2)
            let Y = top*scale+heightDiff-((bounds.height-height*scale)/2)
            self.scrollView?.contentOffset = CGPointMake(X, Y)
            signView!.frame = CGRectMake(0.5*(bounds.width-w), 0.5*(bounds.height-height*scale), w, height*scale)
            
        }
    }
    
    
    func signDocument(box: Dictionary<String, AnyObject>?){
        if nil==box{
            return
        }
        scrollView?.scrollEnabled = false
        let bounds = UIScreen.mainScreen().bounds
        //let h: CGFloat = 120
        let w: CGFloat = 0.8*bounds.width
        let document = self.presentaionImage!.image!
        let top = box!["top"] as! CGFloat*document.size.height
        let left = (box!["left"] as! CGFloat)*document.size.width
        let width = box!["width"] as! CGFloat*document.size.width
        let height = box!["height"] as! CGFloat*document.size.height

        let scale = w/width
        //Image is aspect fit, scale factor will be the biggest change on image
        let scaleRatio = max(document.size.width/bounds.width, document.size.height/bounds.height)
        self.scrollView?.setZoomScale(scaleRatio*scale, animated: false)
        
        //One of these has to be 0
        let heightDiff = (bounds.height*scaleRatio) - document.size.height
        let widthDiff = (bounds.width*scaleRatio) - document.size.width
        
        let X = left*scale+widthDiff-((bounds.width-(4/3)*w)/2)
        let Y = top*scale+heightDiff-((bounds.height-height*scale)/2)
        
        self.scrollView?.contentOffset = CGPointMake(X, Y)
        closeOpenPanels()
        signView = NSBundle(forClass: LiveSign.self).loadNibNamed("SignDocumentPanelView", owner: self, options: nil)[0] as? SignDocumentPanelView
        signView!.frame = CGRectMake(0.5*(bounds.width-w), 0.5*(bounds.height-height*scale), w, height*scale)
        signView?.onClose = onSignViewClose
        signView?.onSign = onSignViewSign
        self.addSubview(signView!)
    }

    func signDocument() {
        closeOpenPanels()
        signView = NSBundle(forClass: LiveSign.self).loadNibNamed("SignDocumentPanelView", owner: self, options: nil)[0] as? SignDocumentPanelView
        let bounds = UIScreen.mainScreen().bounds
        signView!.frame = CGRectMake(20, 0.5*bounds.height, 250, 120)
        signView?.onClose = onSignViewClose
        signView?.onSign = onSignViewSign
        self.addSubview(signView!)
        
    }

    func tap(sender:  UITapGestureRecognizer) {
        if signView != nil {
            if (!CGRectContainsPoint(signView!.frame, sender.locationInView(self))){
                signView?.removeFromSuperview()
                signView = nil
                if scrollView?.zoomScale > 1{
                    scrollView?.scrollEnabled = true
                }
            }
        } else if nil != controlPanelView && controlPanelView!.isVisible(){
            controlPanelView?.hide()
            controlPanelTimer?.invalidate()
        } else {
            controlPanelView?.show()
            controlPanelTimer?.invalidate()
            controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControlPanel"), userInfo: AnyObject?(), repeats: false)
        }
    }
    
    func hideControlPanel(){
        controlPanelView?.hide()
    }
    
    func openNextBox(){
        self.signDocument(self.getNextBox())
    }
    
    func addControlPanel(){
        controlPanelView = NSBundle(forClass: LiveSign.self).loadNibNamed("ControlPanelView", owner: self, options: nil)[0] as? ControlPanelView
        controlPanelView?.onLeft = swipeRight
        controlPanelView?.onRight = swipeLeft
        controlPanelView?.onSign = openNextBox
        controlPanelView?.attachToView(self)
        controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControlPanel"), userInfo: AnyObject?(), repeats: false)
    }
    
    
    func requestForCurrentSlide(){
        Session.sharedInstance.sendMessage("send_current_res", data: [:])
    }
    
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func swipeRight(){
        if signView==nil && self.currentPage != nil && self.currentPage > 0{
            selectPage(self.currentPage!-1)
        }
    }
    
    func swipeLeft(){
        if signView==nil && self.currentPage != nil && self.currentPage < preLoadedImages.count-1{
            selectPage(self.currentPage!+1)
        }
    }
    
    func animateImageView(image: UIImage, toRight: Bool) {
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(0.25)
        
        let transition = CATransition()
//        transition.type = kCATransitionFade
        
        transition.type = kCATransitionPush
        if toRight{
            transition.subtype = kCATransitionFromRight
        } else {
            transition.subtype = kCATransitionFromLeft
        }
        self.presentaionImage?.layer.addAnimation(transition, forKey: kCATransition)
        self.presentaionImage?.image = image
        
        CATransaction.commit()
        
    }
    
    func selectPage(index: Int){
        self.signedImageView?.removeFromSuperview()
        self.signedImageView = nil
        self.scrollView?.setZoomScale(1.0, animated: false)
        scrollView?.scrollEnabled = false
        let prevIndex = currentPage
        self.currentPage = index
        if let image = self.getImageAtIndex(self.currentDocument!, page: self.currentPage!){
            if let pImg = self.presentaionImage {
                dispatch_async(dispatch_get_main_queue()){
                    //pImg.image = image
                    self.animateImageView(image, toRight: prevIndex<index)
                }
            } else {
                self.currentImage = image
            }
        }
    }
    
    func duplicateBoxes(){
        for (page, boxes) in self.signatureBoxes{
            var newBoxes: Array<Dictionary<String, AnyObject>> = []
            for box in boxes{
                var newBox:Dictionary<String, AnyObject> = box
                if nil == box["duplicated"]{
                    newBox["duplicated"] = true
                    if nil != box["originaltype"]{
                        newBox["type"] = box["originaltype"]
                    } else {
                        newBox["type"] = box["type"] as! String + "-duplicated"
                    }
                    if let left = box["left"] as? CGFloat{
                        if left < 0.5 {
                            newBox["left"] = left + (box["width"] as! CGFloat)
                        } else {
                            newBox["left"] = left - (box["width"] as! CGFloat)
                        }
                    }
                newBoxes.append(newBox)
                }
            }
            self.signatureBoxes[page]?.appendContentsOf(newBoxes)
        }
    }
    
    func registerForMessages(){
        Session.sharedInstance.onMessage("load_res_with_index") { (message) -> Void in
            self.signedImageView?.removeFromSuperview()
            self.signedImageView = nil
            self.scrollView?.setZoomScale(1.0, animated: false)
            self.scrollView?.scrollEnabled = false
            if let data = message {
                self.currentDocument = data["document"] as? Int
                self.currentPage = data["page"] as? Int
                if let metaData = data["metaData"] as? Array<Dictionary<String, AnyObject>>{
                    if nil ==  self.signatureBoxes[self.currentPage!]{
                        self.signatureBoxes[self.currentPage!] = metaData
                    }
                }
                if let image = self.getImageAtIndex(self.currentDocument!, page: self.currentPage!){
                    if let pImg = self.presentaionImage {
                        dispatch_async(dispatch_get_main_queue()){
                            pImg.image = image
                        }
                    } else {
                        self.currentImage = image
                    }
                } else {
                    self.setImageAtIndex(data["url"] as! String, document: self.currentDocument!, page: self.currentPage!, completion: { (result) -> Void in
                        if let pImg = self.presentaionImage {
                            dispatch_async(dispatch_get_main_queue()){
                                pImg.image = result
                            }
                        } else {
                            self.currentImage = result
                        }
                    })
                }
            }
        }
        
        Session.sharedInstance.onMessage("preload_res_with_index") { (message) -> Void in
            if let data = message{
                if let metaData = data["metaData"] as? Array<Dictionary<String, AnyObject>>{
                    if nil ==  self.signatureBoxes[data["page"] as! Int]{
                        self.signatureBoxes[data["page"] as! Int] = metaData
                    }
                }
                if nil == self.getImageAtIndex(data["document"] as! Int, page: data["page"] as! Int){
                    self.setImageAtIndex(data["url"] as! String, document: data["document"] as! Int, page: data["page"] as! Int, completion: nil)
                }
            }
        }
        
        Session.sharedInstance.onMessage("zoom_scale") { (message) -> Void in
            if let data = message{
                self.scrollView?.setZoomScale(data["scale"] as! CGFloat, animated: false)
                let x = data["x"] as! CGFloat
                let y = data["y"] as! CGFloat
                if let size =  self.scrollView?.contentSize {
                    self.scrollView?.contentOffset = CGPoint(x: CGFloat(x) * size.width ,y: CGFloat(y) * size.height)
                }
            }
        }
        
        Session.sharedInstance.onMessage("open_next_box") { (message) -> Void in
            if nil != message{
                self.signDocument(self.getNextBox())
            }
        }
        
        Session.sharedInstance.onMessage("connection_created") { (message) -> Void in
            if nil != message {
                if let firstTime = message!["firstTime"] as? Bool{
                    if firstTime{
                        Session.sharedInstance.sendMessage("connection_created", data: ["firstTime": false])
                    }
                }
                
            }
        }
        
        Session.sharedInstance.onMessage("signature_accepted") { (message) -> Void in
            if let data = message{
                if let success = data["success"] as? Bool{
                    if success{
                        self.addSignatureToImage()
                        self.signDocument(self.getNextBox())
                    } else{
                        if nil != data["retry"] as? Bool{
                            self.closeOpenPanels()
                            self.signDocument(self.getNextBox())
                        } else {
                            self.closeOpenPanels()
                            self.scrollView?.setZoomScale(1, animated: false)
                            self.scrollView?.scrollEnabled = false
                        }
                    }
                }
            }
        }
        
        Session.sharedInstance.onMessage("duplicate_boxs") { (message) -> Void in
            if nil != message{
                self.duplicateBoxes()
                self.signDocument(self.getNextBox())
            }
        }
        
    }
    
    func getNextBox(page: Int) -> Dictionary<String, AnyObject>?{
        if nil != self.signatureBoxes[page]{
            for index in 0..<self.signatureBoxes[page]!.count{
                if !(self.signatureBoxes[page]![index]["type"] as! String).containsString("-signed"){
                    currentBox = index
                    return self.signatureBoxes[page]![index]
                }
            }
            return nil
        }
        return nil
    }
    
    func getNextBox() -> Dictionary<String, AnyObject>?{
        var index = 0
        while index < preLoadedImages.count{
            let box = getNextBox(index)
            if nil != box {
                selectPage(index)
                return box
            } else {
                index++
            }
        }
        return nil
    }
    
    
    func setImageAtIndex(url: String, document: Int, page: Int, completion: ((result: UIImage) -> Void)?) -> Void{
        while preLoadedImages.count < document+1{
            preLoadedImages.append([:])
        }
        if let url = NSURL(string: url.stringByReplacingOccurrencesOfString("10.0.2.2", withString: "127.0.0.1")){
            self.getDataFromUrl(url) { data in
                if let image = UIImage(data: data!){
                    self.preLoadedImages[document][page] = image
                    completion?(result: image)
                }
            }
        }
    }
    
    func setImageAtIndex(image: UIImage, document: Int, page: Int){
        while preLoadedImages.count < document+1{
            preLoadedImages.append([:])
        }

        self.preLoadedImages[document][page] = image
    }
    
    func getImageAtIndex(document: Int, page: Int) -> UIImage?{
        if preLoadedImages.count > document{
            if let value = self.preLoadedImages[document][page]{
                return value
            }
        }
        return nil
    }
}

