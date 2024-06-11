//
//  SocialNetworkTblCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class SocialNetworkTblCell: UITableViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var imgViewSocialNetwork: UIImageView!
    @IBOutlet weak var lblSocialNetwork: UILabel!
    @IBOutlet weak var viewSocialNetworkCount: UIView!
    @IBOutlet weak var lblSocialNetworkCount: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnEditWithMoreTouchableArea: UIButton!
    @IBOutlet weak var viewBlur: UIView!
    
    //--------------------------------------------------------
    //                  MARK: - Property -
    //--------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    //var editBtnAction: (() -> ())?
    var editBtnAction: ((_ badgeCount: String) -> ())?
    
    // ----------------------------------------------------------
    //                       MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnEdit(_ sender: UIButton) {
        
        self.editBtnAction?(self.lblSocialNetworkCount.text ?? "")
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(objSocialNetworkList: Social_Network_List, isFromProfileVC: Bool) { // MARK: ProfileVC, SocialVC
        
        self.lblSocialNetwork.text = objSocialNetworkList.social_title?.capitalized
        self.btnEdit.setTitle("Edit", for: .normal)
        
        if isFromProfileVC {
            self.btnMenu.isHidden = true
            self.btnEdit.isHidden = true
            self.btnEditWithMoreTouchableArea.isHidden = true
            
        } else {
            self.btnMenu.isHidden = false
            self.btnEdit.isHidden = false
            self.btnEditWithMoreTouchableArea.isHidden = false
        }
        
        if objSocialNetworkList.social_icon == nil || objSocialNetworkList.social_icon == "" {
            
            self.imgViewSocialNetwork.isHidden = true
            return
        }
        
        self.imgViewSocialNetwork.image = UIImage()
        
//        ImageCache().getImage(from: URL(string: (objSocialNetworkList.social_icon ?? ""))!) { image, error in
//            
//            if image != nil {
//                self.imgViewSocialNetwork.image = image
//            }
//        }
        
        if let url = URL(string: objSocialNetworkList.social_icon ?? "") {
            self.imgViewSocialNetwork.af_setImage(withURL: url)
        }
        
        self.viewSocialNetworkCount.isHidden = true
    }
    
    func configureCellForLinkStore(objSocialNetworkList: Social_Network_List, badgeCount: String, needToHideBadge: Bool = false) { // MARK: LinkStoreVC, AddSocialNetworksVC
        
        if objSocialNetworkList.social_name?.lowercased() == "phone" {
            self.lblSocialNetwork.text = objSocialNetworkList.social_name?.capitalized //"Phone Number"
        } else {
            self.lblSocialNetwork.text = objSocialNetworkList.social_name?.capitalized
        }
        
        self.btnMenu.isHidden = true
        self.btnEdit.setTitle("Add", for: .normal)
        
        if objSocialNetworkList.social_icon == nil || objSocialNetworkList.social_icon == "" {
            
            self.imgViewSocialNetwork.isHidden = true
            return
        }
        
        ImageCache().getImage(from: URL(string: (objSocialNetworkList.social_icon ?? ""))!) { image, error in
            
            if image != nil {
                self.imgViewSocialNetwork.image = image
            }
        }
        
        self.viewSocialNetworkCount.isHidden = false
        self.lblSocialNetworkCount.text = badgeCount
        
        if needToHideBadge {
            
            self.viewSocialNetworkCount.isHidden = true
            //self.lblSocialNetworkCount.text = badgeCount
            
            if badgeCount != "0" {
                
                self.btnEdit.setTitle("Edit", for: .normal)
                
            } else if badgeCount == "0" {
                
                self.btnEdit.setTitle("Add", for: .normal)
            }
            
        } else {
            
            if badgeCount != "0" {
                
                self.viewSocialNetworkCount.isHidden = false
                self.lblSocialNetworkCount.text = badgeCount
                
            } else if badgeCount == "0" {
                
                self.viewSocialNetworkCount.isHidden = true
                self.lblSocialNetworkCount.text = badgeCount
            }
        }
    }
}
