//
//  InterestChipCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InterestChipCVCell: UICollectionViewCell {

    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var chipView: CustomView!
    @IBOutlet weak var imgViewTopic: UIImageView!
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var chipViewWidth: NSLayoutConstraint!
    
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
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func configureCellWith(topic: InterestTopic?, isNewInterestTopic: Bool) {

        self.chipView.CornerRadius = 14
        self.imgViewTopic.layer.cornerRadius = (self.imgViewTopic.layer.frame.size.width + self.imgViewTopic.layer.frame.size.height) / 4

        guard let obj = topic else { return }

        if isNewInterestTopic {

            self.imgViewTopic.image = UIImage(named: "ic_add_chip_blue")
            self.lblTopic.text = obj.topic

        } else {

            self.imgViewTopic.image = UIImage(named: obj.imageName)
            self.lblTopic.text = obj.topic
        }

        if obj.isSelected {

            self.chipView.backgroundColor = UIColor.appBlue_0066FF()
            self.chipView.borderWidth = 0
            self.lblTopic.textColor = UIColor.appWhite_FFFFFF()
            self.imgViewTopic.backgroundColor = UIColor.appWhite_FFFFFF()

        } else {

            self.chipView.borderWidth = 1
            self.chipView.borderColor = UIColor.appGray_F2F3F4()
            self.chipView.backgroundColor = UIColor.appWhite_FFFFFF()
            self.lblTopic.textColor = UIColor.appBlack_031227()
        }
    }
    
    func configureCell(topic: User_Interest?) {
        
        self.chipView.CornerRadius = 14
        self.imgViewTopic.layer.cornerRadius = (self.imgViewTopic.layer.frame.size.width + self.imgViewTopic.layer.frame.size.height) / 4
        
        guard let obj = topic else { return }
        
        if obj.id == "-1" {
            
            self.imgViewTopic.image = UIImage(named: "ic_add_chip_blue")
            self.lblTopic.text = obj.name
            
        } else {
            
            //self.imgViewTopic.image = UIImage(named: obj.icon ?? "ic_add_chip_blue")
            if let url = URL(string: obj.icon ?? "") {
                self.imgViewTopic.af_setImage(withURL: url, filter: nil)
            } else {
                self.imgViewTopic.image = UIImage(named: "ic_add_chip_blue")
            }
            self.lblTopic.text = obj.name
        }
        
        if obj.selected {
            
            // print("selected obj name: \(obj.name ?? "")")
            // print("-----------------------------")
            // print("-----------------------------")
            
            self.chipView.borderWidth = 0
            self.chipView.backgroundColor = UIColor.appBlue_0066FF()
            self.lblTopic.textColor = UIColor.appWhite_FFFFFF()
            self.imgViewTopic.backgroundColor = UIColor.appWhite_FFFFFF()
            
        } else {
            
            // print("unselected obj name: \(obj.name ?? "")")
            // print("-----------------------------")
            // print("-----------------------------")
            
            self.chipView.borderWidth = 1
            self.chipView.borderColor = UIColor.appGray_F2F3F4()
            self.chipView.backgroundColor = UIColor.appWhite_FFFFFF()
            self.lblTopic.textColor = UIColor.appBlack_031227()
        }
    }
}
