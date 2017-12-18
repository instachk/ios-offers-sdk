//
//  MessageListener.swift
//  AdViewApp
//
//  Created by Esteban on 6/7/17.
//  Copyright © 2017 Instachk. All rights reserved.
//

import UIKit

@objc protocol MessageListener {
    func instachkOnMessageReceived(message : String);
    @objc optional  func onCouponActivated(advertisement_id: Int)
    @objc optional  func onCouponActivated(deal_id: Int)
}
