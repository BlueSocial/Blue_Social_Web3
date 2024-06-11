//
//  AddNetworkTblCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddNetworkTblCell: UITableViewCell {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblSocialNetworkName         : UILabel!
    @IBOutlet weak var imgSocial                    : UIImageView!
    @IBOutlet weak var imgSelected                  : UIImageView!
    @IBOutlet weak var lblTapsCount                 : UILabel!

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
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(objSocialNetworkList: Social_Network_List?) { // MARK: AddSocialNetworkPopupVC
        
        guard let obj = objSocialNetworkList else { return }
        
        self.lblTapsCount.isHidden = true
        
        if let url = URL(string: obj.social_icon ?? "") {
            self.imgSocial.af_setImage(withURL: url, filter: nil)
        }
        
        self.lblSocialNetworkName.text = obj.social_title
        
        if obj.value != nil && obj.value != "" {
            self.imgSelected.isHidden = false
            self.imgSelected.image = UIImage(named: "ic_check_blue")
        } else {
            self.imgSelected.isHidden = true
        }
    }
}
