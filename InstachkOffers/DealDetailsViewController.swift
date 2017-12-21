//
//  DealDetailsViewController.swift
//  InstachkOffers
//
//  Created by Naresh on 18/12/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

class DealDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dealDetailsView: UIView!
    @IBOutlet weak var imageViewDeal: UIImageView!
    @IBOutlet weak var imageViewD: UIImageView!
    @IBOutlet weak var lblDealName: UILabel!
    @IBOutlet weak var lblDealDescription: UILabel!
    @IBOutlet weak var lblTimeValidity: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTermsAndConditions: UILabel!
    @IBOutlet weak var activateBtn: UIButton!
    @IBOutlet weak var viewActivateDeal: UIView! {
        didSet {
            viewActivateDeal.isHidden = true
        }
    }
    @IBOutlet weak var imageViewActivateDeal: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func activateNoBtnClicked(_ sender: UIButton) {
    }
    
    @IBAction func activateYesBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
       // self.delegate?.onActivateCouponConfirmed()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func activateBtnClicked(_ sender: UIButton) {
        viewActivateDeal.isHidden = false
    }
    @IBAction func backBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func shareBtnClicked(_ sender: UIButton) {
        
    }
}
