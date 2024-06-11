//
//  ShowProfilePhotoVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ShowProfilePhotoVC: UIViewController {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    internal var imgProfile: UIImage?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imgViewProfile.image = self.imgProfile
    }
}
