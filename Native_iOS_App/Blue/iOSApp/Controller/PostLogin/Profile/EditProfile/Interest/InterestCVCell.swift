//
//  InterestCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InterestCVCell: UICollectionViewCell {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewTopic: UIImageView!
    @IBOutlet weak var lblTopic: UILabel!
    
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
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(model: User_Interest) {
        
        self.lblTopic.text = model.name
        
        if model.icon == nil || model.icon == "" {
            
            self.imgViewTopic.isHidden = true
            return
        }
        
        if model.icon == "ic_add_chip_blue" {
            
            self.imgViewTopic.isHidden = true
            self.imgViewTopic.image = UIImage(named: "ic_add_chip_blue")
            return
        }
        
        ImageCache().getImage(from: URL(string: model.icon!)!) { image, error in
            
            if image != nil {
                
                self.imgViewTopic.image = image
            }
        }
    }
}
