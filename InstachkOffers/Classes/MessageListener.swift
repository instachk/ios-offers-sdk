//
//  MessageListener.swift
//  AdViewApp
//
//  Created by Esteban on 6/7/17.
//  Copyright © 2017 Instachk. All rights reserved.
//

import UIKit

@objc protocol MessageListener {
   @objc func instachkOnMessageReceived(message : String)
   optional @objc func onCouponActivated(advertisement_id: Int)
   optional @objc func onCouponActivated(advertisement_id: Int)
}
