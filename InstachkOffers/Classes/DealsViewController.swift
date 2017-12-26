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
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var viewDeals: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    var dealsDictionary :[String:Any] = [String:Any]()
    let MyCollectionViewCellId: String = "dealscell"
    var dealsArr = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(DealsCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCellId)

      //  let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
      //  layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
      //  layout.itemSize = CGSize(width: 155, height: 255)
        
      //  collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
       // self.view.addSubview(collectionView)
    }
    
    @IBAction func backBtnClicked(_ sender: UIButton) {
       // dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DealsViewController : UICollectionViewDelegate,UICollectionViewDataSource {
        
      func numberOfSections(in collectionView: UICollectionView) -> Int {
                return 1
         }
        
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return dealsArr.count
         }
        
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCellId, for: indexPath) as! DealsCollectionViewCell

            dealsDictionary = dealsArr[indexPath.row]
            cell.lblNameDeal?.text = dealsDictionary["title"] as? String
            cell.lblDealDescription?.text = dealsDictionary["description"] as? String

            let imageUrl = dealsDictionary["image_url"] as! String
            let url = URL(string: imageUrl)
            let data = try? Data(contentsOf: url!)

            DispatchQueue.main.async {
                cell.imageViewDeal?.image = UIImage(data: data!)
            }
            
            return cell
     }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForItemAt section: Int) -> CGFloat {
          return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)! as! DealsCollectionViewCell
        
        let vc = DealDetailsViewController(nibName: "DealDetailsViewController", bundle: Bundle.init(for: DealDetailsViewController.self))
        
        let imageUrl = dealsDictionary["image_url"] as! String
        let strTerms = dealsDictionary["terms_and_conditions"] as! String
        let str1 = strTerms.replacingOccurrences(of: "<br/>", with:"\n" )
        let startTime = dealsDictionary["start_time"] as? String
        let endTime = dealsDictionary["end_time"] as? String
        let imageActivateDealURL = dealsDictionary["action_url"] as? String
        
        vc.dealName = cell.lblNameDeal.text
        vc.dealDescription = cell.lblDealDescription.text
        vc.imageDealURL = imageUrl
        vc.dealTermsAndConditions = strTerms
        vc.startTime = startTime
        vc.endTime = endTime
        vc.imageVD = imageUrl
        vc.dealTermsAndConditions = str1
        vc.imageActivateDealURL = imageActivateDealURL
        
        present(vc, animated: true, completion: nil)
    }
}


