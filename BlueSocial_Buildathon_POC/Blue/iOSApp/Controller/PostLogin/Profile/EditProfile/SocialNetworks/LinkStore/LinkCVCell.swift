//
//  LinkCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class LinkCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var viewLink: UIView!
    
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
        
        self.lblLink.text = title
        self.viewLink.layer.cornerRadius = 14.0
        
        if IndexPath == selectedIndex {
            
            self.viewLink.layer.borderWidth = 0
            self.viewLink.backgroundColor = UIColor.appBlue_0066FF()
            self.lblLink.textColor = UIColor.appWhite_FFFFFF()
            
        } else {
            
            self.viewLink.layer.borderWidth = 1
            self.viewLink.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
            self.viewLink.backgroundColor = UIColor.appWhite_FFFFFF()
            self.lblLink.textColor = UIColor.appBlack_000000()
        }
    }
}
