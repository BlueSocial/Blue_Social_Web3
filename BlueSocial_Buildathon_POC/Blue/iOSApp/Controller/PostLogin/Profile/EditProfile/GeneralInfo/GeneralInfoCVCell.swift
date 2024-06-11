//
//  GeneralInfoCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class GeneralInfoCVCell: UICollectionViewCell {

    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var lblInfo: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    var selectedItem: (() -> Void)?
    
    // ----------------------------------------------------------
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnCheckbox(_ sender: UIButton) {
        
        if self.isSelected {
            self.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
        } else {
            self.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
        }
        
        self.isSelected = !self.isSelected
        self.selectedItem?()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(name: String) {
        self.lblInfo.text = name
    }
}
