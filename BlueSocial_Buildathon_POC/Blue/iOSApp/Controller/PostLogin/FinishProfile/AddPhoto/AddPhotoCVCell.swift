//
//  AddPhotoCVCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddPhotoCVCell: UICollectionViewCell {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var addPhotoView: CustomView!
    
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
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnRemovePhoto(_ sender: UIButton) {
        
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func configureCell(imageName: PhotoModel?) {
        
        
    }
    
//    func configureCell(topic: TopicModel?, isNewInterestTopic: Bool) {
//
//        self.chipView.cornerRadius = 14
//        self.imgViewTopic.layer.cornerRadius = (self.imgViewTopic.layer.frame.size.width + self.imgViewTopic.layer.frame.size.height) / 4
//
//        guard let obj = topic else { return }
//
//        if isNewInterestTopic {
//
//            self.chipView.isHidden = true
//            self.addNewChipView.isHidden = false
//
//            self.imgViewTopicN.image = UIImage(named: "ic_add_chip_blue")
//            self.lblTopicN.text = obj.topic
//
//        } else {
//
//            self.chipView.isHidden = false
//            self.addNewChipView.isHidden = true
//
//            self.imgViewTopic.image = UIImage(named: obj.imageName)
//            self.lblTopic.text = obj.topic
//        }
//
//        if obj.isSelected {
//
//            self.chipView.backgroundColor = UIColor.appBlue_0066FF()
//            self.chipView.borderWidth = 0
//            self.lblTopic.textColor = UIColor.appWhite_FFFFFF()
//            self.imgViewTopic.backgroundColor = UIColor.appWhite_FFFFFF()
//
//        } else {
//
//            self.chipView.borderWidth = 1
//            self.chipView.borderColor = UIColor.appGray_F2F3F4()
//            self.chipView.backgroundColor = UIColor.appWhite_FFFFFF()
//            self.lblTopic.textColor = UIColor.appBlack_031227()
//        }
//    }
}
