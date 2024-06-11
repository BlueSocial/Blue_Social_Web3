//
//  TransactionCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class TransactionCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblTransactionType: UILabel!
    @IBOutlet weak var viewTransction: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
//    override var isSelected: Bool {
//        didSet {
//            
//            // Update UI elements based on isSelected
//            if isSelected {
//                self.viewTransction.layer.borderWidth = 0
//                self.viewTransction.backgroundColor = UIColor.appBlue_0066FF()
//                self.lblTransactionType.textColor = UIColor.appWhite_FFFFFF()
//            } else {
//                self.viewTransction.layer.borderWidth = 1
//                self.viewTransction.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
//                self.viewTransction.backgroundColor = UIColor.appWhite_FFFFFF()
//                self.lblTransactionType.textColor = UIColor.appBlack_000000()
//            }
//        }
//    }
    
    // ----------------------------------------------------------
    //                MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureSelectedState() {
        self.viewTransction.layer.borderWidth = 0
        self.viewTransction.backgroundColor = UIColor.appBlue_0066FF()
        self.lblTransactionType.textColor = UIColor.appWhite_FFFFFF()
    }
    
    func configureDeselectedState() {
        self.viewTransction.layer.borderWidth = 1
        self.viewTransction.layer.borderColor = UIColor.appGray_F2F3F4().cgColor
        self.viewTransction.backgroundColor = UIColor.appWhite_FFFFFF()
        self.lblTransactionType.textColor = UIColor.appBlack_000000()
    }
}
