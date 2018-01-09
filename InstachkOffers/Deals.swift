//
//  Deals.swift
//  InstachkOffers
//
//  Created by Naresh on 21/12/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

public class Deals: NSObject,MessageListener {
    
    var deals = [[String: Any]]()
    var service : InstachkService?
    var partnerKey: String
    var container: UIView! = nil
    var collectionView:UICollectionView!
    
    let MyCollectionViewCellId: String = "dealscell"
    
    var dealsDictionary = [String:Any]()

    public init(container: UIView,partnerKey: String) {
        self.container = container
        self.partnerKey = partnerKey
        super.init()
        bind(partnerKey: self.partnerKey)
        getStoredDeals()
    }
    
    public func bind(partnerKey: String) {
        self.service = InstachkService(partnerKey: partnerKey)
        service!.initialize()
        service!.setDelegate(delegate: self)
    }
    
    func instachkOnMessageReceived(message: String) {
        
     //   print("instachkOnMessageReceived: \(message)")
      do {
            let data = message.data(using: String.Encoding.utf8)!
            guard let json = try JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any]
                else {
                        print("Could not get JSON from responseData as dictionary")
                        return
                    }
            
          if (json["type"] != nil && json["deals"] != nil) {
            // render new deals
              if let deals = json["deals"] as? [[String: Any]] {
                    self.deals.removeAll()
                    self.deals = deals
                
                  let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                  layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
                  layout.itemSize = CGSize(width: 155, height: 255)
                  layout.scrollDirection = .vertical

                  collectionView = UICollectionView(frame: container.frame, collectionViewLayout: layout)
                  collectionView.isScrollEnabled = true
                  collectionView.dataSource = self
                  collectionView.delegate = self
                  collectionView.alwaysBounceVertical = true
                  collectionView.backgroundColor = UIColor.white
                  container.addSubview(collectionView)

                  collectionView.register(DealsCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCellId)

                  // store the deals in user defaults
                     storeDeals()
                }
            }
         }
       catch {
                 print("Error parsing response 2 \(error.localizedDescription)")
                 return
             }
    }
 
    /**
     Stores deals in user defaults as Data format
     */
    func storeDeals() {
        let deals: NSData = self.jsonToNSData(json: self.deals)!
        let userDefaults = UserDefaults.standard
        _ = userDefaults.set(deals, forKey: "deals")
     }
    
    /**
     gets deals from user defaults and converts them back to dict
     */
    func getStoredDeals() {        
        do {
            let dataold = UserDefaults.standard.data(forKey: "deals")
            if(dataold == nil) {
                return
            }
            guard let dealsOld = try JSONSerialization.jsonObject(with: dataold!, options: [])
                as? [[String: Any]]
                else {
                       print("Could not get JSON from responseData as dictionary")
                       return
                     }
            deals = dealsOld
        } catch {
            print("Error fetching local ads: \(error.localizedDescription)")
        }
    }
    
    /**
     Helper functions to conver json to data vice versa
     */
    func jsonToNSData(json: [[String: Any]]) -> NSData? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) as NSData
           }
        catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    func nsdataToJSON(data: NSData) -> Any? {
        do {
             return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
           }
        catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}

extension Deals : UICollectionViewDataSource,UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deals.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCellId, for: indexPath) as! DealsCollectionViewCell
        
        dealsDictionary = deals[indexPath.row]
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForItemAt section: Int) -> CGFloat {
        return 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)! as! DealsCollectionViewCell
        
        let vc = DealDetailsViewController(nibName: "DealDetailsViewController", bundle: Bundle.init(for: DealDetailsViewController.self))
                
        dealsDictionary = deals[indexPath.row]
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
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.container.parentViewController?.showDetailViewController(vc, sender: nil)
    }
}
