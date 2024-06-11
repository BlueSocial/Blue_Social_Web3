//
//  DeleteSocialNetworkVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class DeleteSocialNetworkVC: UIViewController {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewBlur: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        let blueViewTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.viewBlur.addGestureRecognizer(blueViewTap)
    }

    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnDelete(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onBtnCancle(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
    }
}
