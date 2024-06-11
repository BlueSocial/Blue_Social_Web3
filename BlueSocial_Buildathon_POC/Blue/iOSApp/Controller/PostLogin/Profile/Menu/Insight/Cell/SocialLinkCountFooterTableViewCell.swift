//
//  SocialLinkCountFooterTableViewCell.swift
//  Blue
//
//  Created by PCQ158 on 10/05/21.
//  Copyright © 2021 Bluepixel Technologies. All rights reserved.
//

import UIKit

class SocialLinkCountFooterTableViewCell: UITableViewCell {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewAllButton: UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var completion: (() -> ())?
    var isExpanded: Bool? {
        didSet {
            if self.isExpanded ?? false {
                self.viewAllButton.setTitle("View Less", for: .normal)
                
            } else {
                self.viewAllButton.setTitle("View all", for: .normal)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onViewAllButton(_ sender: UIButton) {
        self.completion?()
    }
}
