//
//  ShowSocialNetworkVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ShowSocialNetworkVC: UIViewController {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var imgViewSocialNetwork: UIImageView!
    @IBOutlet weak var lblSocialNetworkName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtValue: UITextField!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    internal var imgSocialNetwork: UIImage?
    internal var socialNetworkName: String?
    internal var socialNetworkTitle: String?
    internal var value: String?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgViewSocialNetwork.image = self.imgSocialNetwork
        self.lblSocialNetworkName.text = self.socialNetworkName
        self.lblTitle.text = self.socialNetworkTitle
        self.txtValue.text = self.value
        
        let blueViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blueViewTap)
    }
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    @IBAction func onBtnCopyToClipboard(_ sender: UIButton) {
        UIPasteboard.general.string = self.txtValue.text
        self.makeToast(message: "Copy to clipboard")
    }
    
    @objc func blurViewTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.dismiss(animated: true)
    }
}
