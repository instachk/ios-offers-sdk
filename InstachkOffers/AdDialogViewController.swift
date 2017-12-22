//
//  AdDialogViewController.swift
//  offers
//
//  Created by Ravi Tamada on 18/07/17.
//  Copyright © 2017 Ravi Tamada. All rights reserved.
//

import UIKit

protocol AdDialogDelegate {
    func onActivateCouponConfirmed();
    func onAdDialogDismissed();
}

public class AdDialogViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var adImage: UIImageView!
    
    public var imageUrl: String = ""
    
    var delegate: AdDialogDelegate!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.delegate = self
        viewBackground.addGestureRecognizer(tap)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        self.view.superview?.backgroundColor = UIColor.clear
        self.view.superview?.isOpaque = false
        self.modalPresentationStyle = .overCurrentContext
        self.displayAdImage()
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: nil)
        self.delegate?.onAdDialogDismissed()
    }

    @IBAction func dismissClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.delegate?.onAdDialogDismissed()
    }
    
    
    @IBAction func onConfirmClicked(_ sender: UIButton) {
            dismiss(animated: true, completion: nil)
            self.delegate?.onActivateCouponConfirmed()
    }
    
    func displayAdImage(){
        print("displayAdImage \(imageUrl) \(self.adImage)")
        self.adImage.imageFromUrl(urlString: imageUrl)
    }
}
