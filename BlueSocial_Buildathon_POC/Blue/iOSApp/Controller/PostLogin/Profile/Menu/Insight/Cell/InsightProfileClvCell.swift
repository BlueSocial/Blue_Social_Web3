//
//  InsightProfileClvCell.swift
//  Blue
//
//  Created by Blue.
//

import UIKit

class InsightProfileClvCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblInsight              : UILabel!
    @IBOutlet weak var lblInsightCount         : UILabel!
    @IBOutlet weak var selectInsightView       : UIView!
    @IBOutlet weak var borderView              : CustomView!

    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(objProfieInsight: ProfieInsight?) {
        
        guard let obj = objProfieInsight else { return }
        
        let selected = obj.isSelected
        if selected == true {
            
            self.borderView.backgroundColor = UIColor.appWhite_DFECFF()
            self.borderView.borderColor = UIColor.appBlue_0066FF()
            self.lblInsight.textColor = UIColor.appBlue_0066FF()
            self.lblInsightCount.textColor = UIColor.appBlue_0066FF()
            
        } else {
            
            self.borderView.backgroundColor = UIColor.appWhite_FFFFFF()
            self.borderView.borderColor = UIColor.appWhite_DFECFF()
            self.lblInsight.textColor = UIColor.appGray_98A2B1()
            self.lblInsightCount.textColor = UIColor.appBlack_000000()
        }
    }
}
