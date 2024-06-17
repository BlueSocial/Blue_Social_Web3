//
//  AddSocialNetworksVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddSocialNetworksVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cvLink: UICollectionView!
    @IBOutlet weak var tblSocialNetwork: UITableView!
    
    // ----------------------------------------------------------
    //                       MARK: - property -
    // ----------------------------------------------------------
    private var arrLink = [String]()
    private var currentSelectedIndex = 0
    
    private var arrSocialNetwork = [Social_Network]()
    private var arrFilterSocialNetwork = [Social_Network]()
    
    internal var socialNameCount: [String: Int] = [:]
    private var countBeforeAdd = 0
    private var socialNameToAdd = ""
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footerView = UIView()
        footerView.frame.size.height = 1
        tblSocialNetwork.tableFooterView = footerView
        
        self.tblSocialNetwork.register(SocialNetworkTblCell.nib, forCellReuseIdentifier: SocialNetworkTblCell.identifier)
        self.txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.arrLink = ["Recommended"]
        
        if UserLocalData.userMode == "0" {
            self.callGetSocialListAPI(showloader: true, isBusinessProfile: "0")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.arrFilterSocialNetwork.removeAll()
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        
        let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
        
        if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
            
            self.arrSocialNetwork = dbUserModel.social_network ?? [Social_Network]()
            self.arrFilterSocialNetwork = self.arrSocialNetwork
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnClear(_ sender: UIButton) {
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        self.cvLink.isHidden = false
        self.arrFilterSocialNetwork = self.arrSocialNetwork
        self.tblSocialNetwork.reloadData()
    }
    
    @IBAction func onBtnFinishProfile(_ sender: UIButton) {
        
        print("Finish Profile Button Tapped")
        //        if let navigationController = self.navigationController {
        //            navigationController.popToRootViewController(animated: true)
        //        }
        
        var rootVC: UIViewController
        let tabbar = MainTabbarController.instantiate(fromAppStoryboard: .Discover)
        tabbar.selectedIndex = 1 // Select the desired tab index
        
        // Set the tab bar controller as the root view controller
        rootVC = tabbar
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.setNavigationBarHidden(true, animated: true)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let window = appDelegate.window {
                // Now you have access to the window instance.
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if txtSearch.text?.count == 0 {
            cvLink.isHidden = false
            btnClear.isHidden = true
        } else {
            cvLink.isHidden = true
            btnClear.isHidden = false
        }
        
        if UserLocalData.userMode == "0" {
            
            guard let searchString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchString.isEmpty else {
                // If the search string is empty or nil, return all SocialNetwork
                self.arrFilterSocialNetwork = self.arrSocialNetwork
                self.tblSocialNetwork.reloadData()
                print("No search string. Showing all SocialNetwork.")
                return
            }
            
            self.arrFilterSocialNetwork = []
            
            print("---------------------------------------------------")
            for socialNetwork in self.arrSocialNetwork {
                if let socialList = socialNetwork.social_network_list {
                    var isContainsSearchString = false
                    
                    for socialItem in socialList {
                        if let socialName = socialItem.social_name {
                            if socialName.lowercased().contains(searchString.lowercased()) {
                                isContainsSearchString = true
                                print("- \(socialName) contains - \(searchString): \(isContainsSearchString), in category: \(socialItem.social_category_title ?? "")")
                                break
                            }
                        }
                    }
                    
                    if isContainsSearchString {
                        self.arrFilterSocialNetwork.append(socialNetwork)
                    }
                }
            }
            
            print("arrFilterSocialNetwork count: \(self.arrFilterSocialNetwork.count)")
            print("---------------------------------------------------")
            
            self.tblSocialNetwork.reloadData()
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callGetSocialListAPI(showloader: Bool = false, isBusinessProfile: String) {
        
        let url = BaseURL + APIName.kGetSocialList
        
        let param: [String: Any] = [APIParamKey.kIsBusinessProfile: isBusinessProfile]
        // Social Network Default List - "0" | Business Network Default List - "1"
        
        if showloader { self.showCustomLoader() }
        APIManager.postAPIRequest(postURL: url, parameters: param ) { (isSuccess, msg, response) in
            self.hideCustomLoader()
            
            if isSuccess {
                
                if isBusinessProfile == "0" {
                    
                    self.arrSocialNetwork = response?.socialNetworkModel?.social_network ?? [Social_Network]()
                    self.arrFilterSocialNetwork = self.arrSocialNetwork
                    
                    let tempArray = self.arrSocialNetwork.map({ obj in
                        return obj.social_category_title ?? ""
                    })
                    
                    self.arrLink.append(contentsOf: tempArray)
                }
                
                self.cvLink.reloadData()
                self.tblSocialNetwork.reloadData()
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

extension AddSocialNetworksVC: EditSocialNWDelegate {
    
    func updateBadgeCount() {
        
        if var snCount = self.socialNameCount[self.socialNameToAdd] {
            // You found "SN" in the dictionary, and snCount contains its value.
            print("SN count: \(snCount)")
            
            snCount += 1
            self.socialNameCount[self.socialNameToAdd] = snCount
            
        } else {
            // "SN" is not in the dictionary.
            print("SN not found in the dictionary. Adding it now.")
            
            // Adding the key-value pair to the dictionary
            self.socialNameCount[self.socialNameToAdd] = 1
        }
        
        self.tblSocialNetwork.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension AddSocialNetworksVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrLink.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvLink.dequeueReusableCell(withReuseIdentifier: LinkCVCell.identifier, for: indexPath) as? LinkCVCell {
            cell.configureCell(IndexPath: indexPath.item, selectedIndex: self.currentSelectedIndex, title: self.arrLink[indexPath.item])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension AddSocialNetworksVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.currentSelectedIndex = indexPath.item
        self.cvLink.reloadData()
        self.tblSocialNetwork.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableViewDataSource -
// ----------------------------------------------------------
extension AddSocialNetworksVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if UserLocalData.userMode == "0" {
            
            if self.arrFilterSocialNetwork.count != 0 {
                
                if txtSearch.text?.count == 0 {
                    
                    if self.currentSelectedIndex == 0 {
                        return 6
                        
                    } else {
                        return self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?.count ?? 0
                    }
                    
                } else {
                    return self.arrFilterSocialNetwork.count
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblSocialNetwork.dequeueReusableCell(withIdentifier: SocialNetworkTblCell.identifier) as? SocialNetworkTblCell {
            
            if txtSearch.text?.count == 0 { // Without Search
                
                if self.currentSelectedIndex == 0 { // Recommended
                    
                    switch indexPath.row {
                            
                        case 0:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0..<self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["phone"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        case 1:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0..<self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["whatsapp"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        case 2:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0..<self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["instagram"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        case 3:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0..<self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["email"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        case 4:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0..<self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["linkedin"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        case 5:
                            if UserLocalData.userMode == "0" {
                                if self.arrFilterSocialNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterSocialNetwork.count {
                                            let socialNetwork = self.arrFilterSocialNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["website"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)", needToHideBadge: true)
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0", needToHideBadge: true)
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                    //                                                                    self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                                    //
                                                                    //                                                                        if btnAction == 2 {
                                                                    //                                                                            let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                                    //                                                                            subscriptionVC.isFromEditProfile = true
                                                                    //                                                                            self.present(subscriptionVC, animated: true)
                                                                    //                                                                        }
                                                                    //                                                                    }
                                                                    
                                                                    // Open EditSocialNetworkVC with Edit Option
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromSocialVC = true
                                                                    editSocialNetworkVC.isFromFinishProfile = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.editSocialNWDelegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            return cell
                            
                        default:
                            break
                    }
                    
                } else { // All From API
                    
                    if UserLocalData.userMode == "0" {
                        
                        if let socialNetworkList = self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row] {
                            
                            //---------------
                            var badges: [String: String] = [:]
                            
                            let socialName = socialNetworkList.social_name?.lowercased()
                            if let count = self.socialNameCount[(socialName ?? "").lowercased()] {
                                badges[socialName ?? ""] = "Badge \(count)"
                                cell.configureCellForLinkStore(objSocialNetworkList: socialNetworkList, badgeCount: "\(count)", needToHideBadge: true)
                            } else {
                                badges[socialName ?? ""] = "No Badge"
                                cell.configureCellForLinkStore(objSocialNetworkList: socialNetworkList, badgeCount: "0", needToHideBadge: true)
                            }
                            
                            // Now, 'badges' dictionary contains badges assigned to each 'social_name'
                            for (socialName, badge) in badges {
                                print("\(socialName): \(badge)")
                            }
                            //---------------
                            
                            //cell.configureCellForLinkStore(objSocialNetworkList: socialNetworkList)
                            
                            cell.editBtnAction = { (badgeCount) in
                                
                                let intBadgeCount = Int(badgeCount) ?? 0
                                self.countBeforeAdd = intBadgeCount
                                self.socialNameToAdd = socialNetworkList.social_name?.lowercased() ?? ""
                                
                                if loginUser?.subscriptionStatus == "0" {
                                    
                                    if intBadgeCount > 0 {
                                        
                                        //                                        self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                        //
                                        //                                            if btnAction == 2 {
                                        //                                                let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                        //                                                subscriptionVC.isFromEditProfile = true
                                        //                                                self.present(subscriptionVC, animated: true)
                                        //                                            }
                                        //                                        }
                                        
                                        // Open EditSocialNetworkVC with Edit Option
                                        
                                        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                        editSocialNetworkVC.delegate = self
                                        editSocialNetworkVC.editSocialNWDelegate = self
                                        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                        editSocialNetworkVC.objSocialNetworkList = self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row]
                                        editSocialNetworkVC.isFromSocialVC = true
                                        editSocialNetworkVC.isFromFinishProfile = true
                                        self.present(editSocialNetworkVC, animated: true)
                                        
                                    } else {
                                        
                                        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                        editSocialNetworkVC.delegate = self
                                        editSocialNetworkVC.editSocialNWDelegate = self
                                        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                        editSocialNetworkVC.objSocialNetworkList = self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row]
                                        editSocialNetworkVC.isFromLinkStoreAdd = true
                                        editSocialNetworkVC.isFirstTimeTapped = true
                                        self.present(editSocialNetworkVC, animated: true)
                                    }
                                }
                            }
                        }
                        
                    }
                    return cell
                }
                
            } else { // With Search
                
                if UserLocalData.userMode == "0" {
                    
                    let socialNetworkItem = self.arrFilterSocialNetwork[indexPath.row]
                    
                    if let socialList = socialNetworkItem.social_network_list {
                        var badges: [String: String] = [:]
                        
                        for socialItem in socialList {
                            
                            if let socialName = socialItem.social_name?.lowercased() {
                                
                                if socialName.lowercased().contains(txtSearch.text?.lowercased() ?? "") {
                                    //var badgeCount = "No Badge"
                                    
                                    if let count = self.socialNameCount[socialName.lowercased()] {
                                        badges[socialName] = "Badge \(count)"
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "\(count)", needToHideBadge: true)
                                    } else {
                                        badges[socialName] = "No Badge"
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "0", needToHideBadge: true)
                                    }
                                    
                                    cell.editBtnAction = { (badgeCount) in
                                        
                                        let intBadgeCount = Int(badgeCount) ?? 0
                                        self.countBeforeAdd = intBadgeCount
                                        self.socialNameToAdd = socialItem.social_name?.lowercased() ?? ""
                                        
                                        if loginUser?.subscriptionStatus == "0" {
                                            
                                            if intBadgeCount > 0 {
                                                
                                                //                                        self.showAlertWith2Buttons(title: kALERT_Title_Blue_Pro, message: kUpgradeToBlueProForAddingMoreSocialNetwork, btnOneName: "NO THANKS", btnTwoName: "UPGRADE NOW") { btnAction in
                                                //
                                                //                                            if btnAction == 2 {
                                                //                                                let subscriptionVC = SubscriptionVC.instantiate(fromAppStoryboard: .BluePro)
                                                //                                                subscriptionVC.isFromEditProfile = true
                                                //                                                self.present(subscriptionVC, animated: true)
                                                //                                            }
                                                //                                        }
                                                
                                                // Open EditSocialNetworkVC with Edit Option
                                                
                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                editSocialNetworkVC.delegate = self
                                                editSocialNetworkVC.editSocialNWDelegate = self
                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                editSocialNetworkVC.objSocialNetworkList = socialItem
                                                editSocialNetworkVC.isFromSocialVC = true
                                                editSocialNetworkVC.isFromFinishProfile = true
                                                self.present(editSocialNetworkVC, animated: true)
                                                
                                            } else {
                                                
                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                editSocialNetworkVC.delegate = self
                                                editSocialNetworkVC.editSocialNWDelegate = self
                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                editSocialNetworkVC.objSocialNetworkList = socialItem
                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                editSocialNetworkVC.isFirstTimeTapped = true
                                                self.present(editSocialNetworkVC, animated: true)
                                            }
                                            
                                        }
                                    }
                                    break
                                }
                            }
                        }
                    }
                    
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension AddSocialNetworksVC: EditSocialNetworkDelegate {
    
    func editSNDismissed() {
        
        self.viewWillAppear(false)
    }
}
