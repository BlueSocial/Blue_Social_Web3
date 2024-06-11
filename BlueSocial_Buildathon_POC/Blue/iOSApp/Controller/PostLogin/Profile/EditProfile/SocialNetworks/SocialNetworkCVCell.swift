//
//  SocialNetworkCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class SocialNetworkCVCell: UICollectionViewCell {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewSocialNetwork: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblSocialNetwork: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(model: Social_Network_List, isFromSocialVC: Bool) {
        
        self.lblSocialNetwork.text = model.social_title
        
        if isFromSocialVC {
            self.btnAdd.isHidden = false
        } else {
            self.btnAdd.isHidden = true
        }
        
        if model.social_icon == nil || model.social_icon == "" {
            
            self.imgViewSocialNetwork.isHidden = true
            return
        }
        
        ImageCache().getImage(from: URL(string: (model.social_icon ?? ""))!) { image, error in
            
            if image != nil {
                self.imgViewSocialNetwork.image = image
            }
        }
    }
}
