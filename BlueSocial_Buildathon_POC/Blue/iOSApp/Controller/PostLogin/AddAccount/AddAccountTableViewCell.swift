//
//  AddAccountTableViewCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddAccountTableViewCell: UITableViewCell {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblName          : UILabel!
    @IBOutlet weak var imgProfile       : UIImageView!
    @IBOutlet weak var imgLogin         : UIImageView!
    @IBOutlet weak var btnAddAccount    : UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(accountInfo: [String: Any]) {
        
        self.lblName.text = (accountInfo[APIParamKey.kName] as? String)?.capitalized
        
        if let url = URL(string: accountInfo[APIParamKey.kProfilePic] as? String ?? "") {
            
            self.imgProfile.af_setImage(withURL: url, filter: nil)
        }
        
        if UserLocalData.UserID != "" {
            
            if accountInfo[APIParamKey.kUserId] as? String == UserLocalData.UserID {
                self.imgLogin.image = UIImage(named: "ic_checkbox_fill")
            } else {
                self.imgLogin.image = UIImage(named: "ic_checkbox")
            }
            
        } else {
            self.imgLogin.isHidden = true
        }
    }
}
