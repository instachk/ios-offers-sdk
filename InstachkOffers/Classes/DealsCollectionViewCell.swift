//
//  DealsCollectionViewCell.swift
//  InstachkOffers
//
//  Created by Naresh on 21/12/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

class DealsCollectionViewCell: UICollectionViewCell {

    @IBOutlet  var viewDeals: UIView!
    @IBOutlet  var imageViewDeal: UIImageView!
    @IBOutlet  var lblNameDeal: UILabel!
    @IBOutlet  var lblDealDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewDeals.layer.shadowColor = UIColor.black.cgColor
        viewDeals.layer.shadowOpacity = 1
        viewDeals.layer.shadowOffset = CGSize.zero
        viewDeals.layer.shadowRadius = 10
    }
}
