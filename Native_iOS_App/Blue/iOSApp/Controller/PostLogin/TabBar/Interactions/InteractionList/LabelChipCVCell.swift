//
//  LabelChipCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class LabelChipCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var chipView: CustomView!
    @IBOutlet weak var lblLabel: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.chipView.CornerRadius = 10
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(lblTitle: String) {
        
        self.lblLabel.text = lblTitle
    }
}
