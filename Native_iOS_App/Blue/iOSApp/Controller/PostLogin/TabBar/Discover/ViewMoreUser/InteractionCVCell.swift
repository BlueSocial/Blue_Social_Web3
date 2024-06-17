//
//  InteractionCVCell.swift
//  BlueSocialDemo
//
//  Created by Manali on 24/08/23.
//

import UIKit

class InteractionCVCell: UICollectionViewCell {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private var businessFirstname = ""
    private var businessLastname = ""
    
    // ----------------------------------------------------------
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    internal func setupCell(objBeacon: Beacon) { // MARK: InteractionListVC
        
        self.lblName.text = objBeacon.title ?? "---"
        
        if objBeacon.userDetail?.user_mode == "1" && objBeacon.userDetail?.subscriptionStatus == "1" {
            
            if let url = URL(string: objBeacon.userDetail?.business_profileURL ?? "") {
                
                self.imgProfile.af_setImage(withURL: url)
                
            } else {
                
                if let firstName = objBeacon.userDetail?.business_firstName?.capitalized.first {
                    self.businessFirstname = String(firstName)
                    
                } else if let firstName = objBeacon.userDetail?.firstname?.capitalized.first {
                    self.businessFirstname = String(firstName)
                }
                
                if let lastName = objBeacon.userDetail?.business_lastName?.capitalized.first {
                    self.businessLastname = String(lastName)
                    
                } else if let lastName = objBeacon.userDetail?.lastname?.capitalized.first {
                    self.businessLastname = String(lastName)
                }
                
                self.imgProfile?.image = UIImage.imageWithInitial(initial: "\(self.businessFirstname)\(self.businessLastname)", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
            
        } else {
            
            if let url = URL(string: objBeacon.userDetail?.profile_img ?? "") {
                
                self.imgProfile.af_setImage(withURL: url)
                
            } else {
                
                self.imgProfile?.image = UIImage.imageWithInitial(initial: "\(objBeacon.userDetail?.firstname?.capitalized.first ?? "A")\(objBeacon.userDetail?.lastname?.capitalized.first ?? "B")", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
        }
    }
}
