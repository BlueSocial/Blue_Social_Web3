//
//  WelcomeGiftVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class WelcomeGiftVC: UIViewController {

    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewWelcomeGift: UIImageView!
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var lblToken: UILabel!
    @IBOutlet weak var btnClaim: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnClaim(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
