//
//  DealsViewController.swift
//  InstachkOffers
//
//  Created by Naresh on 18/12/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

class DealsViewController: UIViewController {

    
    @IBOutlet weak var viewNavigation: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewNavigation.addSubview(blurEffectView)    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
