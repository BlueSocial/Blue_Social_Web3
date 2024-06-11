//
//  SocialVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

protocol SocialVCDelegate: AnyObject {
    func getSocialNetworkOrder(arrSocialNetwork: [Social_Network])
}

class SocialVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblSocialNetworkCount: UILabel!
    @IBOutlet weak var btnVisitLinkStore: UIButton!
    @IBOutlet weak var viewSocialNetwork: UIView!
    @IBOutlet weak var cvSocialNetwork: UICollectionView!
    @IBOutlet weak var tblSocialNetwork: UITableView!
    @IBOutlet weak var viewNoSocialNetwork: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var imgViewStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    var socialDetail: UserDetail?
    var businessDetail: UserDetail?
    // internal var selectedCategory = ""
    private var arrSocialNetworkList = [Social_Network_List]()
    private var socialNameCount: [String: Int] = [:]
    
    weak var delegate: SocialVCDelegate?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.cvSocialNetwork.register(SocialNetworkCVCell.nib, forCellWithReuseIdentifier: SocialNetworkCVCell.identifier)
        self.tblSocialNetwork.register(SocialNetworkTblCell.nib, forCellReuseIdentifier: SocialNetworkTblCell.identifier)
        
        self.tblSocialNetwork.dragDelegate = self
        self.tblSocialNetwork.dragInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            self.updateUI()
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnVisitLinkStore(_ sender: UIButton) {
        
        let linkStoreVC = LinkStoreVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
        linkStoreVC.socialNameCount = self.socialNameCount
        linkStoreVC.delegate = self
        linkStoreVC.modalPresentationStyle = .overCurrentContext
        linkStoreVC.modalTransitionStyle = .crossDissolve
        //linkStoreVC.view.backgroundColor = UIColor.clear
        self.present(linkStoreVC, animated: true)
    }
    
    @IBAction func onBtnStatus(_ sender: UIButton) {
        
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        // Iterate over socialNameCount and filter arrSocialNetworkList
        for (socialName, count) in self.socialNameCount {
            
            // Iterate over arrSocialNetworkList
            for socialNetwork in self.arrSocialNetworkList {
                
                // Check if the lowercase social name matches the given social name
                if let name = socialNetwork.social_name?.lowercased(), name == socialName {
                    
                    // Handle the matched social network element here
                    print("Matched Social Name: \(name)")
                    print("Social Value: \(socialNetwork.value ?? "")")
                    
                    socialNetwork.snCount = count
                }
            }
        }
        
        if self.arrSocialNetworkList.count == 0 {
            self.viewNoSocialNetwork.isHidden = false
            self.viewSocialNetwork.isHidden = true
        } else {
            self.viewNoSocialNetwork.isHidden = true
            self.viewSocialNetwork.isHidden = false
        }
        
        self.lblSocialNetworkCount.text = "\(self.arrSocialNetworkList.count) link\((self.arrSocialNetworkList.count > 1) ? "s" : "")"
        self.lblSocialNetworkCount.isHidden = self.arrSocialNetworkList.count > 0 ? false : true
        // self.cvSocialNetwork.reloadData()
        
        DispatchQueue.main.async {
            self.tblSocialNetwork.reloadData()
        }
    }
    
    private func updateUI() {
        
        if UserLocalData.userMode == "0" {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
            
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                
                self.socialDetail = dbUserModel
                self.setUserSocialDetail()
            }
        }
    }
    
    private func setUserSocialDetail() {
        
        if let socialDetail = self.socialDetail {
            
            var tempArray = [Social_Network_List]()
            
            if let socialNetwork = socialDetail.social_network {
                for index in 0 ... (socialNetwork.count) - 1 {
                    if let socialNetworkList = socialNetwork[index].social_network_list {
                        for i in 0 ... (socialNetworkList.count) - 1 {
                            if socialNetworkList[i].value != nil && socialNetworkList[i].value != "" {
                                tempArray.append(socialNetworkList[i])
                            }
                        }
                    }
                }
            }
            
            self.arrSocialNetworkList = tempArray
            
            // Sort the array in ascending order based on social_app_order
            self.arrSocialNetworkList.sort { (social1, social2) -> Bool in
                // Convert social_app_order strings to integers
                guard let order1 = Int(social1.social_app_order ?? ""),
                      let order2 = Int(social2.social_app_order ?? "") else {
                    return false // If conversion fails, maintain current order
                }
                
                // Compare integers
                return order1 < order2
            }
            
            self.tblSocialNetwork.reloadData()
            
            //---------------
            var tempSocialNameCount: [String: Int] = [:]
            
            if let socialNetwork = socialDetail.social_network {
                for category in socialNetwork {
                    if let socialNetworkList = category.social_network_list {
                        for objSN in socialNetworkList {
                            if let value = objSN.value, !value.isEmpty {
                                if let count = tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] {
                                    tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] = count + 1
                                } else {
                                    tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] = 1
                                }
                            }
                        }
                    }
                }
            }
            
            // Printing the counts for each social_name
            //            for (socialName, count) in tempSocialNameCount {
            //                print("\(socialName): \(count)")
            //            }
            
            self.socialNameCount = tempSocialNameCount
            //---------------
            
            self.setupUI()
        }
    }
    
    private func setUserBusinessDetail() {
        
        if let businessDetail = self.businessDetail {
            
            var tempArray = [Social_Network_List]()
            
            if let businessNetwork = businessDetail.business_network {
                for index in 0 ... (businessNetwork.count) - 1 {
                    if let businessNetworkList = businessNetwork[index].social_network_list {
                        for i in 0 ... (businessNetworkList.count) - 1 {
                            if businessNetworkList[i].value != nil && businessNetworkList[i].value != "" {
                                tempArray.append(businessNetworkList[i])
                            }
                        }
                    }
                }
            }
            
            self.arrSocialNetworkList = tempArray
            
            // Sort the array in ascending order based on social_app_order
            self.arrSocialNetworkList.sort { (social1, social2) -> Bool in
                // Convert social_app_order strings to integers
                guard let order1 = Int(social1.social_app_order ?? ""),
                      let order2 = Int(social2.social_app_order ?? "") else {
                    return false // If conversion fails, maintain current order
                }
                
                // Compare integers
                return order1 < order2
            }
            
            self.tblSocialNetwork.reloadData()
            
            //---------------
            var tempSocialNameCount: [String: Int] = [:]
            
            if let businessNetwork = businessDetail.business_network {
                for category in businessNetwork {
                    if let socialNetworkList = category.social_network_list {
                        for objSN in socialNetworkList {
                            if let value = objSN.value, !value.isEmpty {
                                if let count = tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] {
                                    tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] = count + 1
                                } else {
                                    tempSocialNameCount[objSN.social_name?.lowercased() ?? ""] = 1
                                }
                            }
                        }
                    }
                }
            }
            
            // Printing the counts for each social_name
            //            for (socialName, count) in tempSocialNameCount {
            //                print("\(socialName): \(count)")
            //            }
            
            self.socialNameCount = tempSocialNameCount
            //---------------
            
            self.setupUI()
        }
    }
    
    private func printArrayWithObjects() {
        
        // Print index wise array with its objects
        for (index, item) in self.arrSocialNetworkList.enumerated() {
            print("Index: \(index), Object: \(item.social_name ?? "")")
            
            item.social_app_order = "\(index + 1)"
        }
        
        if UserLocalData.userMode == "0" {
            
            if let socialNetwork = self.socialDetail?.social_network {
                
                for (index, socialNetworkItem) in socialNetwork.enumerated() {
                    
                    if let socialNetworkList = socialNetworkItem.social_network_list {
                        
                        for (subIndex, obj) in socialNetworkList.enumerated() {
                            
                            if let objSN = self.arrSocialNetworkList.first(where: { $0.user_link_id == obj.user_link_id }) {
                                
                                // Replace the object at the specified index
                                self.socialDetail?.social_network?[index].social_network_list?[subIndex] = objSN
                                
                                print("social_name :: \(self.socialDetail?.social_network?[index].social_network_list?[subIndex].social_name ?? ""), social_app_order :: \(self.socialDetail?.social_network?[index].social_network_list?[subIndex].social_app_order ?? "")")
                            }
                        }
                    }
                }
            }
            
            delegate?.getSocialNetworkOrder(arrSocialNetwork: self.socialDetail?.social_network ?? [Social_Network]())
            
        } else if UserLocalData.userMode == "1" {
            
            if let socialNetwork = self.businessDetail?.business_network {
                
                for (index, socialNetworkItem) in socialNetwork.enumerated() {
                    
                    if let socialNetworkList = socialNetworkItem.social_network_list {
                        
                        for (subIndex, obj) in socialNetworkList.enumerated() {
                            
                            if let objSN = self.arrSocialNetworkList.first(where: { $0.user_link_id == obj.user_link_id }) {
                                
                                // Replace the object at the specified index
                                self.businessDetail?.business_network?[index].social_network_list?[subIndex] = objSN
                                
                                print("social_name :: \(self.businessDetail?.business_network?[index].social_network_list?[subIndex].social_name ?? ""), social_app_order :: \(self.businessDetail?.business_network?[index].social_network_list?[subIndex].social_app_order ?? "")")
                            }
                        }
                    }
                }
            }
            
            delegate?.getSocialNetworkOrder(arrSocialNetwork: self.businessDetail?.business_network ?? [Social_Network]())
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UITableViewDataSource -
// ----------------------------------------------------------
extension SocialVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSocialNetworkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblSocialNetwork.dequeueReusableCell(withIdentifier: SocialNetworkTblCell.identifier) as? SocialNetworkTblCell {
            
            cell.configureCell(objSocialNetworkList: self.arrSocialNetworkList[indexPath.row], isFromProfileVC: false)
            
            cell.editBtnAction = { (badgeCount) in
                
                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                editSocialNetworkVC.delegate = self
                editSocialNetworkVC.isFromSocialVC = true
                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                editSocialNetworkVC.objSocialNetworkList = self.arrSocialNetworkList[indexPath.item]
                editSocialNetworkVC.isFirstTimeTapped = self.arrSocialNetworkList[indexPath.item].snCount > 1 ? false : true
                self.present(editSocialNetworkVC, animated: true)
            }
            
            return cell
        }
        return UITableViewCell()
    }
}

extension SocialVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = self.arrSocialNetworkList.remove(at: sourceIndexPath.row)
        self.arrSocialNetworkList.insert(mover, at: destinationIndexPath.row)
        
        // Print the updated array with objects
        self.printArrayWithObjects()
    }
}

extension SocialVC: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.arrSocialNetworkList[indexPath.row]
        return [ dragItem ]
    }
}

extension SocialVC: EditSocialNWDelegate {
    
    func updateBadgeCount() {
        
        self.viewWillAppear(false)
    }
}

extension SocialVC: LinkStoreDelegate {
    
    func linkstoreDismissed() {
        
        self.viewWillAppear(false)
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionViewDataSource -
// ----------------------------------------------------------
//extension SocialVC: UICollectionViewDataSource {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("Collection - self.arrSocialNetworkList.count :: ", self.arrSocialNetworkList.count)
//        return self.arrSocialNetworkList.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if let cell = self.cvSocialNetwork.dequeueReusableCell(withReuseIdentifier: SocialNetworkCVCell.identifier, for: indexPath) as? SocialNetworkCVCell {
//            cell.configureCell(model: self.arrSocialNetworkList[indexPath.item], isFromSocialVC: true)
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//}

// ----------------------------------------------------------
//                MARK: - UICollectionView Delegate -
// ----------------------------------------------------------
//extension SocialVC: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
////        let deleteSocialNetworkVC = R.storyboard.blueProUserProfile.deleteSocialNetworkVC()!
////        deleteSocialNetworkVC.modalTransitionStyle = .crossDissolve
////        deleteSocialNetworkVC.modalPresentationStyle = .overCurrentContext
////        self.present(deleteSocialNetworkVC, animated: true)
//    }
//}

// -------------------------------------------------------------
//                MARK: - UICollectionViewDelegateFlowLayout -
// -------------------------------------------------------------
//extension SocialVC: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let spacing: CGFloat = 8 // Adjust this value based on your spacing needs
//        let sectionInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Adjust these values based on your spacing needs
//
//        let availableWidth = collectionView.frame.width - sectionInsets.left - sectionInsets.right - (2 * spacing) // Subtract spacing and leading/trailing insets
//        let cellWidth = availableWidth / 3 // Display 3 items side by side
//        let cellHeight: CGFloat = 110 // Adjust this height as needed
//
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//        return 8
//    }
//}
