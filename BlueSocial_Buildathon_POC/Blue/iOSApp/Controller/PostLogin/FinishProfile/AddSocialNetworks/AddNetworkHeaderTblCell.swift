//
//  AddNetworkHeaderTblCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddNetworkHeaderTblCell: UITableViewHeaderFooterView {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet  weak var lblSocialNetworkCategory         : UILabel!
    @IBOutlet  weak var imgViewExpandCollapseArrow       : UIImageView!
    @IBOutlet  weak var stackViewSampleNetwork           : UIStackView!
    @IBOutlet  weak var imgSocialNetwork1                : UIImageView!
    @IBOutlet  weak var imgSocialNetwork2                : UIImageView!
    @IBOutlet  weak var imgSocialNetwork3                : UIImageView!
    @IBOutlet  weak var btnExapand                       : UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var completion: ((_ toggleSection: Int) -> ())?
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onExpanViewBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.completion?(sender.tag)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(objSocialNetwork: Social_Network?) { // MARK: AddSocialNetworkPopupVC
        
        guard let obj = objSocialNetwork else { return }
        
        // Set social_category_title
        self.lblSocialNetworkCategory.text = obj.social_category_title
        
        // Filter and set first 3 Icons for each Category
        if let socialIcons = obj.social_network_list {
            
            for (index, socialIcon) in socialIcons.prefix(3).enumerated() {
                
                let url = URL(string: socialIcon.social_icon ?? "")
                let imageView: UIImageView
                
                switch index {
                    case 0:
                        imageView = self.imgSocialNetwork1
                    case 1:
                        imageView = self.imgSocialNetwork2
                    case 2:
                        imageView = self.imgSocialNetwork3
                    default:
                        return
                }
                
                if let url = url {
                    imageView.af_setImage(withURL: url, filter: nil)
                }
            }
        }
    }
}
