//
//  Deals.swift
//  InstachkOffers
//
//  Created by Naresh on 18/12/17.
//

import UIKit

public class Deals: NSObject,MessageListener {
   
    var deals = [[String: Any]]()
    let settings = UserDefaults.standard
    var service : InstachkService?
    var partnerKey: String
    var container: UIView! = nil

    public init(container: UIView,partnerKey: String) {
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
        
        print("instachkOnMessageReceived: \(message)")
        do {
            let data = message.data(using: String.Encoding.utf8)!
            guard let json = try JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any]
                else {
                    print("Could not get JSON from responseData as dictionary")
                    return
            }
            
           // if (json["type"] != nil && json["deals"] != nil && "new-deals" == json["type"] as! String) {
                
                // render new deals
                if let deals = json["deals"] as? [[String: Any]] {
                    self.deals.removeAll()
                    self.deals = deals
                    
                    
                    let vc = DealsViewController(nibName: "DealsViewController", bundle: nil)
                    UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
                    
                    // store the ads in user defaults
                    self.storeDeals()
                    settings.synchronize()
                }
           // }
        } catch  {
            print("Error parsing response 2 \(error.localizedDescription)")
           // hideAds()
            return
        }
    }
    
    func onCouponActivated(deal_id: Int) {
        print("Coupon activated: \(deal_id)")
    }
    
    /**
     Stores ads in user defaults as Data format
     */
    func storeDeals() {
        let data: NSData = self.jsonToNSData(json: self.deals)!
        let userDefaults = UserDefaults.standard
        _ = userDefaults.set(data, forKey: "deals")
    }
    
    /**
     gets ads from user defaults and converts them back to dict
     */
    func getStoredDeals() {
        
      storeDeals()
        
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
            print(dealsOld)
            self.deals = dealsOld
            print(self.deals)
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
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
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
