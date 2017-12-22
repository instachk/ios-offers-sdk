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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName:"DealsViewController", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        //or if you use class:
        collectionView.register(DealsCollectionViewCell.self, forCellWithReuseIdentifier: "dealcell")
        
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
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 10
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dealcell", for: indexPath) as? DealsCollectionViewCell
            return cell!
        }
}


