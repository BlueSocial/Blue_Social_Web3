//
//  InteractionTblCell.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InteractionTblCell: UITableViewCell {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblUniversity: UILabel!
    @IBOutlet weak var lblToken: UILabel!
    @IBOutlet weak var imgViewDot: UIImageView!
    @IBOutlet weak var imgViewDotGray: UIImageView!
    
    @IBOutlet weak var cvLabels: UICollectionView!
    @IBOutlet weak var heightCVLabels: NSLayoutConstraint!
    
    //--------------------------------------------------------
    //                  MARK: - Property -
    //--------------------------------------------------------
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let dateFormatter = DateFormatter()
    
    var arrLabel: [String] = []
    
    // ----------------------------------------------------------
    //                       MARK: - awake Method -
    // ----------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.cvLabels.register(LabelChipCVCell.nib, forCellWithReuseIdentifier: LabelChipCVCell.identifier)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    internal func setupInteraction(objInteraction: DeviceScanHistory) { // MARK: InteractionListVC
        
        self.lblToken.isHidden = true
        self.imgViewDot.isHidden = false
        
        self.arrLabel = objInteraction.label ?? []
        
        if objInteraction.label?.count != 0 {
            self.cvLabels.isHidden = false
            self.heightCVLabels.constant = 24//self.cvLabels.bounds.height
        } else {
            self.cvLabels.isHidden = true
            self.heightCVLabels.constant = 0
        }
        
        self.cvLabels.reloadData()
        
        if objInteraction.fullname != nil && objInteraction.fullname != "" {
            self.lblName.text = objInteraction.fullname?.capitalized
            
        } else {
            self.lblName.text = objInteraction.firstname?.capitalized ?? "---"
        }
        
        if let url = URL(string: objInteraction.profile_url ?? "") {
            
            self.imgViewProfile.af_setImage(withURL: url)
            
        } else {
            
            let components = objInteraction.fullname?.components(separatedBy: " ")
            
            if (components?.count ?? 0) >= 2 {
                
                self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")\(components?[1].capitalized.first ?? "B")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                
            } else if (components?.count ?? 0) == 1 {
                
                self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
                
            } else {
                
                self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\("AB")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            }
        }
        
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Locale.current
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        if let inputDate = self.dateFormatter.date(from: objInteraction.dt_created ?? "") {
            
            self.dateFormatter.dateFormat = "MMM d, yyyy"
            self.dateFormatter.timeZone = TimeZone.current
            let outputDateStr = self.dateFormatter.string(from: inputDate)
            
            if objInteraction.dt_created != nil && objInteraction.dt_created != "" {
                self.lblDate.text = outputDateStr
            } else {
                self.lblDate.text = "---"
            }
            
        } else {
            print("Invalid date format")
        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if objInteraction.profession_type == "1" {
            self.lblUniversity.text = objInteraction.company_name
            
        } else if objInteraction.profession_type == "2" {
            self.lblUniversity.text = objInteraction.university
            
        } else {
            self.lblUniversity.text = ""
            self.imgViewDotGray.isHidden = true
            self.lblUniversity.isHidden = true
        }
        
        if self.lblUniversity.text == "" || self.lblUniversity.text == nil {
            self.imgViewDotGray.isHidden = true
            self.lblUniversity.isHidden = true
            
        } else {
            self.imgViewDotGray.isHidden = false
            self.lblUniversity.isHidden = false
        }
    }
    
    internal func setupBSTHistory(objBSTHistory: IndividualProofInteractionModel) { // MARK: WalletVC
        
        self.imgViewDot.isHidden = true
        self.cvLabels.isHidden = true
        self.heightCVLabels.constant = 0
        
        let components = objBSTHistory.fullName?.components(separatedBy: " ")
        
        if (components?.count ?? 0) >= 2 {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")\(components?[1].capitalized.first ?? "B")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            
        } else if (components?.count ?? 0) == 1 {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            
        } else {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\("AB")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
        }
        
        if let url = URL(string: objBSTHistory.profileURL ?? "") {
            self.imgViewProfile.af_setImage(withURL: url)
        }
        
        //self.lblName.text = objBSTHistory.device_scan_type == "Send" ? "Sent Tokens" : objBSTHistory.device_scan_type
        if objBSTHistory.device_scan_type == "POI" {
            self.lblName.text = enumTransactionType.proofOfInteraction.rawValue
            
        } else if objBSTHistory.device_scan_type == "BreakTheIce" {
            self.lblName.text = enumTransactionType.breakTheIce.rawValue
            
        } else if objBSTHistory.device_scan_type == "ExchangeTokenReceive" {
            self.lblName.text = enumTransactionType.exchangeContact.rawValue
            
        } else if objBSTHistory.device_scan_type == "Received" {
            self.lblName.text = enumTransactionType.received.rawValue
            
        } else if objBSTHistory.device_scan_type == "Send" {
            self.lblName.text = enumTransactionType.sentTokens.rawValue
            
        } else if objBSTHistory.device_scan_type == "ReferralToken" {
            self.lblName.text = enumTransactionType.referral.rawValue
        }
        self.lblDate.text = objBSTHistory.fullName?.capitalized
        
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        if let inputDate = self.dateFormatter.date(from: objBSTHistory.dt_created ?? "") {
            
            self.dateFormatter.dateFormat = "d MMM h:mm a"
            self.dateFormatter.timeZone = TimeZone.current
            let outputDateStr = self.dateFormatter.string(from: inputDate)
            
            self.lblUniversity.text = outputDateStr
            
        } else {
            print("Invalid date format")
        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if objBSTHistory.blueSocialToken != "" {
            var deviceScanType = "+"
            
            if objBSTHistory.device_scan_type == "BreakTheIce" || objBSTHistory.device_scan_type == "Send" {
                deviceScanType = "-"
            }
            
            self.lblToken.text = deviceScanType + " \(objBSTHistory.blueSocialToken ?? "0")"
            
        } else {
            self.lblToken.text = "0"
        }
    }
    
    internal func setupRecentTransactionsCell(with objTransaction: IndividualProofInteractionModel) { // MARK: RecentTransactionVC
        
        self.imgViewDot.isHidden = true
        self.cvLabels.isHidden = true
        self.heightCVLabels.constant = 0
        
        let components = objTransaction.fullName?.components(separatedBy: " ")
        
        if (components?.count ?? 0) >= 2 {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")\(components?[1].capitalized.first ?? "B")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            
        } else if (components?.count ?? 0) == 1 {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\(components?[0].capitalized.first ?? "A")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
            
        } else {
            
            self.imgViewProfile.image = UIImage.imageWithInitial(initial: "\("AB")", imageSize: self.imgViewProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
        }
        
        if let url = URL(string: objTransaction.profileURL ?? "") {
            self.imgViewProfile.af_setImage(withURL: url)
        }
        
        //self.lblName.text = objTransaction.device_scan_type == "Send" ? "Sent Tokens" : objTransaction.device_scan_type
        if objTransaction.device_scan_type == "POI" {
            self.lblName.text = enumTransactionType.proofOfInteraction.rawValue
            
        } else if objTransaction.device_scan_type == "BreakTheIce" {
            self.lblName.text = enumTransactionType.breakTheIce.rawValue
            
        } else if objTransaction.device_scan_type == "ExchangeTokenReceive" {
            self.lblName.text = enumTransactionType.exchangeContact.rawValue
            
        } else if objTransaction.device_scan_type == "Received" {
            self.lblName.text = enumTransactionType.received.rawValue
            
        } else if objTransaction.device_scan_type == "Send" {
            self.lblName.text = enumTransactionType.sentTokens.rawValue
            
        } else if objTransaction.device_scan_type == "ReferralToken" {
            self.lblName.text = enumTransactionType.referral.rawValue
        }
        self.lblDate.text = objTransaction.fullName?.capitalized
        
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        if let inputDate = self.dateFormatter.date(from: objTransaction.dt_created ?? "") {
            
            self.dateFormatter.dateFormat = "d MMM h:mm a"
            self.dateFormatter.timeZone = TimeZone.current
            let outputDateStr = self.dateFormatter.string(from: inputDate)
            
            self.lblUniversity.text = outputDateStr
            
        } else {
            print("Invalid date format")
        }
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if objTransaction.blueSocialToken != "" {
            var deviceScanType = "+"
            
            if objTransaction.device_scan_type == "BreakTheIce" || objTransaction.device_scan_type == "Send" {
                deviceScanType = "-"
            }
            
            self.lblToken.text = deviceScanType + " \(objTransaction.blueSocialToken ?? "0")"
            
        } else {
            self.lblToken.text = "0"
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension InteractionTblCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrLabel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelChipCVCell.identifier, for: indexPath) as? LabelChipCVCell {
            cell.configureCell(lblTitle: self.arrLabel[indexPath.item])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension InteractionTblCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let font = UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        let value = self.arrLabel[indexPath.item]
        let width = BaseVC.sharedInstance.getWidthFromSting(value: value, fromFont: font) + 16 // 16 - Leading 8 & Trailing 8
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
}
