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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DealsCollectionViewCell
        return cell!
    }
}
