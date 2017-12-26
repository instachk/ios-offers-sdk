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
                
                    let vc = DealsViewController(nibName: "DealsViewController", bundle: Bundle.init(for: DealsViewController.self))
                    vc.dealsArr = deals
                    self.container.parentViewController?.showDetailViewController(vc, sender: nil)
                
                  // store the deals in user defaults
                   self.storeDeals()
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
            print(dealsOld)
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
        } catch let myJSONError {
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
