//
//  TblHeaderCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class TblHeaderCell: UITableViewHeaderFooterView {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet  weak var lblTitle: UILabel!
    
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
    //                       MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
