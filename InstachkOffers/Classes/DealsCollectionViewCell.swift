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
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        viewDeals = UIView(frame: CGRect(x: 0, y: 0, width: 162, height: 255))
        viewDeals.contentMode = UIViewContentMode.scaleAspectFit
        viewDeals.viewShadow()
        viewDeals.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(viewDeals)
        
        imageViewDeal = UIImageView(frame: CGRect(x: 0, y: 0, width: 162, height:176))
        imageViewDeal.contentMode = UIViewContentMode.scaleAspectFit
        viewDeals.addSubview(imageViewDeal)
                
        lblNameDeal = UILabel(frame:CGRect(x: 10, y: 174, width: 135, height: 34))
        lblNameDeal.numberOfLines = 2
        lblNameDeal.textColor = UIColor.black
        lblNameDeal.font = UIFont.boldSystemFont(ofSize: 14)
        viewDeals.addSubview(lblNameDeal)

        lblDealDescription = UILabel(frame:CGRect(x: 10, y: 215, width: 135, height: 20))
        lblNameDeal.numberOfLines = 2
        lblDealDescription.textColor = UIColor.darkGray
        lblDealDescription.font = UIFont.systemFont(ofSize: 12)
        viewDeals.addSubview(lblDealDescription)

//        imageViewDeal.translatesAutoresizingMaskIntoConstraints = false
//
//        imageViewDeal.heightAnchor.constraint(equalToConstant: 155)
//        imageViewDeal.widthAnchor.constraint(equalToConstant: 176)
//
//        imageViewDeal.leadingAnchor.constraint(equalTo: viewDeals.leadingAnchor).isActive = true
//        imageViewDeal.trailingAnchor.constraint(equalTo: viewDeals.trailingAnchor).isActive = true
//        imageViewDeal.topAnchor.constraint(equalTo:viewDeals.topAnchor, constant:-10).isActive = true
//        imageViewDeal.bottomAnchor.constraint(equalTo: lblNameDeal.bottomAnchor, constant:-10).isActive = true
//        print(imageViewDeal.frame)
//
//        lblNameDeal.translatesAutoresizingMaskIntoConstraints = false
//        lblNameDeal.heightAnchor.constraint(equalToConstant: 135)
//        lblNameDeal.widthAnchor.constraint(equalToConstant: 36)
//
//        lblNameDeal.leadingAnchor.constraint(equalTo: viewDeals.leadingAnchor).isActive = true
//        lblNameDeal.trailingAnchor.constraint(equalTo: viewDeals.trailingAnchor).isActive = true
//        lblNameDeal.topAnchor.constraint(equalTo: imageViewDeal.topAnchor ,constant:5).isActive = true
//        lblNameDeal.bottomAnchor.constraint(equalTo: lblDealDescription.bottomAnchor,constant:10).isActive = true
//        print(lblNameDeal.frame)
//
//        lblDealDescription.translatesAutoresizingMaskIntoConstraints = false
//        lblDealDescription.heightAnchor.constraint(equalToConstant: 135)
//        lblDealDescription.widthAnchor.constraint(equalToConstant: 21)
//
//        lblDealDescription.leadingAnchor.constraint(equalTo: viewDeals.leadingAnchor).isActive = true
//        lblDealDescription.trailingAnchor.constraint(equalTo: viewDeals.trailingAnchor).isActive = true
//        lblDealDescription.topAnchor.constraint(equalTo: lblNameDeal.topAnchor,constant:5).isActive = true
//        lblDealDescription.bottomAnchor.constraint(equalTo: viewDeals.bottomAnchor,constant:5).isActive = true
//        print(lblDealDescription.frame)

    }
    
     required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
