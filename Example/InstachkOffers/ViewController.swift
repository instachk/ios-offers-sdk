//
//  ViewController.swift
//  InstachkOffers
//
//  Created by ravi8x@gmail.com on 07/26/2017.
//  Copyright (c) 2017 ravi8x@gmail.com. All rights reserved.
//

import UIKit
import InstachkOffers
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    
    // gcloud partner key
    let PARTNER_KEY = "f92b5ef55b80407883f7e6a3c6caccd9"

    @IBOutlet weak var adViewContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            
            // initialize the instachk offers only after location permissions are granted
            Advertisement.init(container: self.adViewContainer, partnerKey: self.PARTNER_KEY)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

