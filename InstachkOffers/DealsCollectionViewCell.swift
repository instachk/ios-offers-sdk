//
//  DealsCollectionViewCell.swift
//  InstachkOffers
//
//  Created by Naresh on 18/12/17.
//

import UIKit

class DealsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewDeals: UIView!
    @IBOutlet weak var imageViewDeal: UIImageView!
    @IBOutlet weak var lblNameDeal: UILabel!
    @IBOutlet weak var lblDealDescription: UILabel!
    
    override func awakeFromNib() {
        viewDeals.layer.shadowColor = UIColor.black.cgColor
        viewDeals.layer.shadowOpacity = 1
        viewDeals.layer.shadowOffset = CGSize.zero
        viewDeals.layer.shadowRadius = 10
    }
}
