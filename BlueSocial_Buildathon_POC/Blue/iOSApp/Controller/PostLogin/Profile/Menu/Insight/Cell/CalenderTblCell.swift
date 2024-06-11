//
//  CalenderTblCell.swift
//  Blue
//
//  Created by Blue.
//

import UIKit

class CalenderTblCell: UITableViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet  weak var lblCalenderYearName          : UILabel!
    @IBOutlet  weak var imgSelected                  : UIImageView!
    
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
}
