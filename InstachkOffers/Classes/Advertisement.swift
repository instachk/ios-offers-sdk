//
//  Advertisement.swift
//  offers
//
//  Created by Ravi Tamada on 15/07/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

public class Advertisement: NSObject, MessageListener, AdDialogDelegate, UIScrollViewDelegate,  UIGestureRecognizerDelegate {
    // partner key
    // let PARTNER_KEY = "f92b5ef55b80407883f7e6a3c6caccd9"
    
    // carousel height
    let AD_HEIGHT = 100
    
    // ad priorities
    let PRIORTY_HIGH_INTERVAL = 8
    let PRIORTY_STANDARD_INTERVAL = 4
    let PAUSE_INTERVAL = 3 // slider pause interval
    var AUTO_SCROLL_INTERVAL: Int = 0
    
    // interval to show the carousel again once the cycle is over
    let CAROUSEL_HIDDEN_INTERVAL = 20
    
    // carousel container
    var container: UIView! = nil
    var partnerKey: String
    var adVertisements = [[String: Any]]()
    var timer: Timer?
    let scrollView = UIScrollView()
    var currentSlide: Int = 0
    var isHidden: Bool = false
    var service : InstachkService?
    let settings = UserDefaults.standard
    
    public init(container: UIView, partnerKey: String) {
        self.container = container
        self.partnerKey = partnerKey
        super.init()
        
        // default to standard priority interval
        AUTO_SCROLL_INTERVAL = PRIORTY_STANDARD_INTERVAL
        
        bind(partnerKey: self.partnerKey)
        
        print("isSliderTimedOut: \(self.isSliderTimedOut())")
        
        if(self.isSliderTimedOut()){
            // show ad slider
            loadLocalAds()
        }else{
            // hide ads
            self.minimizeAds()
        }
    }
    
    public func bind(partnerKey: String) {
        self.service = InstachkService(partnerKey: partnerKey)
        service!.initialize()
        service!.setDelegate(delegate: self)
    }
    
    func instachkOnMessageReceived(message : String) {
        // print("instachkOnMessageReceived: \(message)")
        do {
            let data = message.data(using: String.Encoding.utf8)!
            guard let json = try JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any]
                else {
                    print("Could not get JSON from responseData as dictionary")
                    return
            }
            
            
            if (json["type"] != nil && json["advertisements"] != nil && "new-ads" == json["type"] as! String) {
                
                // render new ads
                if let ads = json["advertisements"] as? [[String: Any]] {
                    self.adVertisements.removeAll()
                    self.adVertisements = ads
                    
                    currentSlide = 0
                    self.renderAds()
                    
                    // store the ads in user defaults
                    self.storeAds()
                    settings.synchronize()
                }
            }
        } catch  {
            print("Error parsing response 2 \(error.localizedDescription)")
            hideAds()
            return
        }
    }
    
    func calCurrentIndex(){
        self.currentSlide = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
    }
    
    func storeLastSliderShownTime(){
        let start = NSDate()
        settings.set(start, forKey: "last_shown")
        
        print("Last shown:\(String(describing: settings.value(forKey: "last_shown")))")
    }
    
    func isSliderTimedOut() -> Bool{
        let start = NSDate()
        let end = settings.value(forKey: "last_shown") as? NSDate
        
        if(end == nil){
            return true
        }
        
        let duration = Int(start.timeIntervalSince(end! as Date))
        
        return duration > CAROUSEL_HIDDEN_INTERVAL
    }
    
    func startTimer() {
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(AUTO_SCROLL_INTERVAL), target: self, selector: #selector(Advertisement.timerFunc), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerFunc() {
        // check for last slide
        if(currentSlide == adVertisements.count - 1){
            // stop the ad carousel
            slideDownAds()
            return
        }
        
        currentSlide += 1
        if currentSlide == scrollView.subviews.count-2 {
            currentSlide = 0
        }
        print("values are = subCount: \(scrollView.subviews.count), currentSlide: \(currentSlide), mainWidth: \(CGFloat(currentSlide) * UIScreen.main.bounds.size.width)")
        
        var frame = scrollView.frame
        frame.origin.x = CGFloat(currentSlide) * UIScreen.main.bounds.size.width
        frame.origin.y = 0
        DispatchQueue.global(qos: .userInteractive).sync {
            scrollView.setContentOffset(CGPoint.init(x: frame.origin.x, y: 0), animated: true)
        }
    }
    
    private func stopTimer(){
        print("stopTimer")
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    /**
     priority 0 = standard
     priority 1 = high
     */
    private func calculateInterval(){
        calculateInterval(adPause: false)
    }
    
    private func calculateInterval(adPause: Bool){
        if(adVertisements.count == 0){
            return
        }
        
        // get the current ad
        let ad = adVertisements[currentSlide] as [String: Any]
        let coupons = ad["coupons"] as! [[String: Any]]
        let priority: Int = (coupons[0])["priority"] as! Int
        
        AUTO_SCROLL_INTERVAL = priority == 0 ? PRIORTY_STANDARD_INTERVAL : PRIORTY_HIGH_INTERVAL
        
        if(adPause){
            AUTO_SCROLL_INTERVAL += PAUSE_INTERVAL
        }
    }
    
    private func loadLocalAds(){
        self.getStoredAds()
        self.renderAds()
    }
    
    func convertToDictionary(text: String) -> [String: AnyObject]? {
        if let data = text.replacingOccurrences(of: "\n", with: "").data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func onCouponActivated(advertisement_id: Int) {
        print("Coupon activated: \(advertisement_id)")
        
        deleteAd(advertisement_id: advertisement_id)
        
        DispatchQueue.main.async {
            self.renderAds(reset: true)
        }
    }
    
    private func renderAds(){
        renderAds(reset: false)
    }
    
    /**
     Renders ads in carousel and enables auto scrolling
     */
    private func renderAds(reset: Bool) {
        // check for nil ads
        if(adVertisements.count == 0){
            // no ads to display, hide the carousel
            hideAds()
            return
        }
        
        
        print("advertisements size: \(adVertisements.count) \(type(of: adVertisements))")
        
        
        // appen page or remove all views
        if(reset){
            scrollView.subviews.forEach { $0.removeFromSuperview() }
        }
        
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(AD_HEIGHT))
        for i in 0..<adVertisements.count {
            let imageView = UIImageView()
            let xOffset = UIScreen.main.bounds.size.width * CGFloat(i)
            scrollView.contentSize.width = UIScreen.main.bounds.size.width * CGFloat(i + 1)
            imageView.frame = CGRect(x: xOffset, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(AD_HEIGHT))
            let ad = adVertisements[i] as [String: Any]
            imageView.downloadedFrom(link: ad["image_url"] as! String)
            
            // assign click listener
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Advertisement.imageTapped))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
            imageView.isUserInteractionEnabled = true
            imageView.tag = ad["id"] as! Int
            
            // adding view to scroll view
            scrollView.insertSubview(imageView, at: i)
        }
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor(rgb: 0x38a976)
        container.addSubview(scrollView)
        self.container.isHidden = false
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        
        swipeRight.direction = .right
        swipeRight.delegate = self
        
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        
        self.scrollView.addGestureRecognizer(swipeRight)
        self.scrollView.addGestureRecognizer(swipeLeft)
        
        // check the carousel hidden state
        // start the timer if it is visible
        if(!isHidden){
            calculateInterval()
            self.startTimer()
        }
    }
    
    private func removeAdFromScrollView(advertisement_id: Int){
        let subViews = self.scrollView.subviews
        for subview in subViews {
            if subview.tag == advertisement_id  {
                print("Removing subview ad id: \(advertisement_id)")
                subview.removeConstraints(subview.constraints)
                subview.removeFromSuperview()
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentSlide = Int(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
    }
    
    
    // image view click callback
    @objc func imageTapped()
    {
        if isHidden{
            slideUpAds()
        }else{
            showConfirmation()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        calculateInterval(adPause: true)
        stopTimer()
        startTimer()
    }
    
    private func slideUpAds(){
        // slide down the carousel
        self.container.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.container.frame.origin.y = self.container.frame.origin.y - self.scrollView.frame.height + CGFloat(10)
            self.isHidden = false
            self.calculateInterval()
            self.startTimer()
        })
    }
    
    private func slideDownAds(){
        self.slideDownAds(duration: 0.4)
    }

    
    private func slideDownAds(duration: Double){
        // minimized ads, shows 10pt heights bar at the bottom
        // this will be done when there are ads in local db
        
        // stop the timer
        stopTimer()
        
        print("container Y: \(self.container.frame.origin.y) height: \(self.container.frame.height)")
        
        // slide down the carousel
        UIView.animate(withDuration: duration, animations: {
            self.container.frame.origin.y = self.container.frame.origin.y + self.scrollView.frame.height - CGFloat(10)
        }, completion: {
            (value: Bool) in
            self.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            self.currentSlide = 0
            self.isHidden = true
            self.storeLastSliderShownTime()
        })
    }
    
    private func hideAds(){
        print("No ads to show. Stopping timers and hiding the carousel")
        // removes the ad scrollview completely from the view
        // this will be done when there are no ads in local db
        scrollView.setContentOffset(CGPoint.init(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y + scrollView.frame.height), animated: true)
        stopTimer()
        self.isHidden = true
        self.container.isHidden = true
    }
    
    private func minimizeAds(){
        self.getStoredAds()
        
        if(adVertisements.count == 0){
            hideAds()
            return
        }
        
        // minimize the ads showing 10pt bar at the bottom
        print("minimize ads")
        self.container.frame.origin.y = self.container.frame.origin.y + CGFloat(self.AD_HEIGHT - 10)
        self.currentSlide = 0
        self.isHidden = false
        self.container.isHidden = false
        self.stopTimer()
        self.container.backgroundColor = UIColor(rgb: 0x38a976)
        isHidden = true
        
        renderAds()
    }
    
    private func showConfirmation(){
        let vc = AdDialogViewController(nibName: "AdDialogViewController", bundle: Bundle.init(for: AdDialogViewController.self))
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        let ad = adVertisements[currentSlide] as [String: Any]
        if (ad["image_url"] != nil) {
            vc.imageUrl = ad["image_url"] as! String
        }
        self.container.parentViewController?.showDetailViewController(vc, sender: nil)
        pauseSlider()
    }
    
    func onActivateCouponConfirmed() {
        print("onActivateCouponConfirmed")
        activateCoupon()
    }
    
    func onAdDialogDismissed(){
        self.resumeSlider()
    }
    
    private func activateCoupon(){
        let ad = adVertisements[currentSlide] as [String: Any]
        if (ad["action_url"] != nil) {
            if let url = URL(string: ad["action_url"]! as! String) {
                DispatchQueue.global(qos: .background).async {
                    // open the url in browser
                    UIApplication.shared.open(url)
                
                    // make activate coupon request
                    self.service?.activateCoupon(advertisement_id: ad["id"] as! Int)
                }
            }
        }
    }
    
    private func pauseSlider(){
        print("Pause slider")
        stopTimer()
    }
    
    private func resumeSlider(){
        print("Resume slider")
        self.startTimer()
    }
    
    /**
     Stores ads in user defaults as Data format
     */
    func storeAds(){
        let data: NSData = self.jsonToNSData(json: self.adVertisements)!
        
        UserDefaults.standard.set(data, forKey: "ads")
    }
    
    
    /**
     gets ads from user defaults and converts them back to dict
     */
    func getStoredAds(){
        do{
            let dataold = UserDefaults.standard.data(forKey: "ads")
            
            if(dataold == nil){
                return
            }
            
            guard let adsOld = try JSONSerialization.jsonObject(with: dataold!, options: [])
                as? [[String: Any]]
                else {
                    print("Could not get JSON from responseData as dictionary")
                    return
            }
            
            self.adVertisements = adsOld
        }catch{
            print("Error fetching local ads: \(error.localizedDescription)")
        }
    }
    
    
    /**
     deleting ad from local memory
     */
    func deleteAd(advertisement_id: Int){
        for (i, ad) in self.adVertisements.enumerated() {
            if(ad["id"] as! Int == advertisement_id){
                print("Deleting ad id: \(advertisement_id)")
                self.adVertisements.remove(at: i)
            }
        }
        
        storeAds()
        getStoredAds()
        
        // calculate the current slide index
        if(adVertisements.count == 1){
            currentSlide = 0
        }else if(currentSlide < adVertisements.count - 1){
            currentSlide += 1
        }else{
            currentSlide = adVertisements.count - 1
        }
    }
    
    /**
     Helper functions to conver json to data vice versa
     */
    func jsonToNSData(json: [[String: Any]]) -> NSData?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) as NSData
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    func nsdataToJSON(data: NSData) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}

// TODO
// Slider position is not correct sometimes - moving up
// Activate coupon on image click - http call - DONE
// Add pause interval - DONE
// Test the widget in other app - resolve depedency
// deploy the library to pod
// keep proper ad intervals - DONE
// keep green background color to scrollview - currently its purple - use hex code - DONE
// Carousel hidden interval, should not open on app launch - show only when interval exceeds
