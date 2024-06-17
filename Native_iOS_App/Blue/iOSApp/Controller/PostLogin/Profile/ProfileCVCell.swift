//
//  ProfileCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class ProfileCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblProfileType: UILabel!
    @IBOutlet weak var viewProfile: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
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
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(IndexPath: Int, selectedIndex: Int, title: String) {
        
        if IndexPath == selectedIndex {
            
            self.viewProfile.layer.borderWidth = 0
            self.viewProfile.backgroundColor = UIColor.appBlue_0066FF()
            self.lblProfileType.textColor = UIColor.appWhite_FFFFFF()
            
        } else {
            
            self.viewProfile.layer.borderWidth = 1
            self.viewProfile.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
            self.viewProfile.backgroundColor = UIColor.appWhite_FFFFFF()
            self.lblProfileType.textColor = UIColor.appBlack_000000()
        }
        
        self.lblProfileType.text = title
        self.viewProfile.layer.borderWidth = 1
        self.viewProfile.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
        self.viewProfile.layer.cornerRadius = 14.0
    }
}
