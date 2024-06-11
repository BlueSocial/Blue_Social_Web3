//
//  InterestTopicCVCell.swift
//  Blue
//
//  Created by Blue
//

import UIKit

class InterestTopicCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblInterest1: UILabel!
    @IBOutlet weak var lblInterest2: UILabel!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var outerViewLbl1: UIView!
    @IBOutlet weak var outerViewLbl2: UIView!
    @IBOutlet weak var innerViewLbl1: UIView!
    @IBOutlet weak var innerViewLbl2: UIView!
    @IBOutlet weak var centerInnerViewLbl1: NSLayoutConstraint!
    @IBOutlet weak var trailingInnerViewLbl1: NSLayoutConstraint!
    
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
