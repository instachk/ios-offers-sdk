//
//  DealsViewController.swift
//  InstachkOffers
//
//  Created by Naresh on 21/12/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

class DealsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let MyCollectionViewCellId: String = "dealscell"
    var dealsArr = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DealsCollectionViewCell", bundle: bundle)

        collectionView.register(nib, forCellWithReuseIdentifier: MyCollectionViewCellId)

      //  collectionView.register(DealsCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCellId)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DealsViewController : UICollectionViewDelegate,UICollectionViewDataSource {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
               return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
               return dealsArr.count
         }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCellId, for: indexPath) as! DealsCollectionViewCell

            let dict = dealsArr[indexPath.row]
            
            print(dict["mall_name"] as! String)
            print(dict["image_url"] as! String)
            print(dict["description"] as! String)
            print(cell.lblNameDeal)
            cell.lblNameDeal?.text = dict["mall_name"] as? String
            let imageUrl = dict["image_url"] as! String
            let url = URL(string: imageUrl)
            let data = try? Data(contentsOf: url!)

            DispatchQueue.main.async {
                cell.imageViewDeal?.image = UIImage(data: data!)
            }
            cell.lblDealDescription?.text = dict["description"] as? String
            return cell
        }
}


