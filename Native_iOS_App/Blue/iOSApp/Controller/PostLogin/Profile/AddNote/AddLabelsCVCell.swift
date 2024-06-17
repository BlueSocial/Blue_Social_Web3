//
//  AddLabelsCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddLabelsCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var viewLabel: UIView!
    @IBOutlet weak var btnRemove: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    //    static var nib: UINib {
    //        return UINib(nibName: identifier, bundle: nil)
    //    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var btnRemoveAction: (() -> Void)?
    
    // ----------------------------------------------------------
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewLabel.layer.cornerRadius = 14.0
        self.viewLabel.borderWidth = 1
        self.viewLabel.borderColor = UIColor.appGray_F2F3F4()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnRemove(_ sender: UIButton) {
        
        self.btnRemoveAction?()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(lblTitle: String) {
        
        self.lblLabel.text = lblTitle
    }
}
