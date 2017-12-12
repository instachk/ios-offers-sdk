//
//  MessageListener.swift
//  AdViewApp
//
//  Created by Esteban on 6/7/17.
//  Copyright © 2017 Instachk. All rights reserved.
//

import UIKit

protocol MessageListener {
    func instachkOnMessageReceived(message : String);
    func onCouponActivated(advertisement_id: Int)
}
