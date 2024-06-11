//
//  LinkStoreVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

protocol LinkStoreDelegate: AnyObject {
    func linkstoreDismissed()
}

class LinkStoreVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cvLink: UICollectionView!
    @IBOutlet weak var tblSocialNetwork: UITableView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewNoSearchResultFound: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrLink = [String]()
    private var currentSelectedIndex = 0
    
    private var arrSocialNetwork = [Social_Network]()
    private var arrFilterSocialNetwork = [Social_Network]()
    
    private var arrBusinessNetwork = [Social_Network]()
    private var arrFilterBusinessNetwork = [Social_Network]()
    
    internal var socialNameCount: [String: Int] = [:]
    private var countBeforeAdd = 0
    private var socialNameToAdd = ""
    weak var delegate: LinkStoreDelegate?
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblSocialNetwork.register(SocialNetworkTblCell.nib, forCellReuseIdentifier: SocialNetworkTblCell.identifier)
        self.txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.arrLink = ["Recommended"]
        
        if UserLocalData.userMode == "0" {
            self.callGetSocialListAPI(showloader: true, isBusinessProfile: "0")
            
        } else if UserLocalData.userMode == "1" {
            self.callGetSocialListAPI(showloader: true, isBusinessProfile: "1")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.arrFilterSocialNetwork.removeAll()
        self.arrBusinessNetwork.removeAll()
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        self.viewNoSearchResultFound.isHidden = true
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        self.delegate?.linkstoreDismissed()
    }
    
    @IBAction func onBtnClear(_ sender: UIButton) {
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        self.viewNoSearchResultFound.isHidden = true
        self.cvLink.isHidden = false
        self.arrFilterSocialNetwork = self.arrSocialNetwork
        self.tblSocialNetwork.reloadData()
    }
    
    @IBAction func onBtnDone(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.delegate?.linkstoreDismissed()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if self.txtSearch.text?.count == 0 {
            self.cvLink.isHidden = false
            self.btnClear.isHidden = true
            self.viewNoSearchResultFound.isHidden = true
        } else {
            self.cvLink.isHidden = true
            self.btnClear.isHidden = false
        }
        
        if UserLocalData.userMode == "0" {
            
            guard let searchString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchString.isEmpty else {
                // If the search string is empty or nil, return all SocialNetwork
                self.arrFilterSocialNetwork = self.arrSocialNetwork
                self.tblSocialNetwork.reloadData()
                print("No search string. Showing all SocialNetwork.")
                self.viewNoSearchResultFound.isHidden = true
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
            
            self.viewNoSearchResultFound.isHidden = self.arrFilterSocialNetwork.count > 0 ? true : false
            self.tblSocialNetwork.reloadData()
            
        } else if UserLocalData.userMode == "1" {
            
            guard let searchString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchString.isEmpty else {
                // If the search string is empty or nil, return all SocialNetwork
                self.arrFilterBusinessNetwork = self.arrBusinessNetwork
                self.tblSocialNetwork.reloadData()
                print("No search string. Showing all SocialNetwork.")
                self.viewNoSearchResultFound.isHidden = true
                return
            }
            
            self.arrFilterBusinessNetwork = []
            
            print("---------------------------------------------------")
            for socialNetwork in self.arrBusinessNetwork {
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
                        self.arrFilterBusinessNetwork.append(socialNetwork)
                    }
                }
            }
            
            print("arrFilterBusinessNetwork count: \(self.arrFilterBusinessNetwork.count)")
            print("---------------------------------------------------")
            
            self.viewNoSearchResultFound.isHidden = self.arrFilterBusinessNetwork.count > 0 ? true : false
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
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            if showloader { self.hideCustomLoader() }
            
            if isSuccess {
                
                if isBusinessProfile == "0" {
                    
                    self.arrSocialNetwork = response?.socialNetworkModel?.social_network ?? [Social_Network]()
                    self.arrFilterSocialNetwork = self.arrSocialNetwork
                    
                    let tempArray = self.arrSocialNetwork.map({ obj in
                        return obj.social_category_title ?? ""
                    })
                    
                    self.arrLink.append(contentsOf: tempArray)
                    
                } else if isBusinessProfile == "1" {
                    
                    self.arrBusinessNetwork = response?.socialNetworkModel?.social_network ?? [Social_Network]()
                    self.arrFilterBusinessNetwork = self.arrBusinessNetwork
                    
                    let tempArray = self.arrBusinessNetwork.map({ obj in
                        return obj.social_category_title ?? ""
                    })
                    
                    self.arrLink.append(contentsOf: tempArray)
                }
                
                // // Uncomment If want to Expand First Network
                // for i in 0 ... self.arrSocialNetwork.count - 1 {
                //     self.arrSocialNetwork[i].isExpanded = false
                // }
                // self.arrSocialNetwork.first?.isExpanded = true
                
                self.pageControl.isHidden = false
                self.pageControl.numberOfPages = self.arrLink.count
                self.pageControl.currentPage = 0
                self.pageControl.pageIndicatorTintColor = UIColor.appGray_F2F3F4()
                self.pageControl.currentPageIndicatorTintColor = UIColor.appGray_98A2B1()
                
                self.cvLink.reloadData()
                self.tblSocialNetwork.reloadData()
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}

extension LinkStoreVC: EditSocialNWDelegate {
    
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
extension LinkStoreVC: UICollectionViewDataSource {
    
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
extension LinkStoreVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.currentSelectedIndex = indexPath.item
        self.pageControl.currentPage = self.currentSelectedIndex
        self.cvLink.reloadData()
        self.tblSocialNetwork.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableViewDataSource -
// ----------------------------------------------------------
extension LinkStoreVC: UITableViewDataSource {
    
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
            
        } else if UserLocalData.userMode == "1" {
            
            if self.arrFilterBusinessNetwork.count != 0 {
                
                if txtSearch.text?.count == 0 {
                    
                    if self.currentSelectedIndex == 0 {
                        return 6
                        
                    } else {
                        return self.arrFilterBusinessNetwork[self.currentSelectedIndex - 1].social_network_list?.count ?? 0
                    }
                    
                } else {
                    return self.arrFilterBusinessNetwork.count
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
                                    for index in 0 ..< self.arrLink.count {
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
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["phone"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                            return cell
                            
                        case 1:
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
                                                    if ["whatsapp"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["whatsapp"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                            return cell
                            
                        case 2:
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
                                                    if ["instagram"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["instagram"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                            return cell
                            
                        case 3:
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
                                                    if ["email"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["email"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                            return cell
                            
                        case 4:
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
                                                    if ["linkedin"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["linkedin"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
                                                                self.present(editSocialNetworkVC, animated: true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else if UserLocalData.userMode == "1" {
                                if self.arrFilterBusinessNetwork.count != 0 {
                                    for index in 0 ..< self.arrLink.count {
                                        // Use the outerIndex as the index for self.arrLink
                                        if index < self.arrFilterBusinessNetwork.count {
                                            let socialNetwork = self.arrFilterBusinessNetwork[index]
                                            if let socialNetworkList = socialNetwork.social_network_list {
                                                for objSocialNetwork in socialNetworkList {
                                                    let socialName = objSocialNetwork.social_name
                                                    //print("socialName :: \(socialName ?? "")")
                                                    if ["website"].contains(socialName?.lowercased() ?? "") {
                                                        //var badges: [String: String] = [:]
                                                        if let count = self.socialNameCount[socialName?.lowercased() ?? ""] {
                                                            //badges[socialName ?? ""] = "Badge \(count)"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "\(count)")
                                                        } else {
                                                            //badges[socialName ?? ""] = "No Badge"
                                                            cell.configureCellForLinkStore(objSocialNetworkList: objSocialNetwork, badgeCount: "0")
                                                        }
                                                        
                                                        cell.editBtnAction = { (badgeCount) in
                                                            
                                                            let intBadgeCount = Int(badgeCount) ?? 0
                                                            self.countBeforeAdd = intBadgeCount
                                                            self.socialNameToAdd = objSocialNetwork.social_name?.lowercased() ?? ""
                                                            
                                                            if loginUser?.subscriptionStatus == "0" {
                                                                
                                                                if intBadgeCount > 0 {
                                                                    
                                                                } else {
                                                                    
                                                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                    editSocialNetworkVC.delegate = self
                                                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                    editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                    self.present(editSocialNetworkVC, animated: true)
                                                                }
                                                                
                                                            } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                                                
                                                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                                                editSocialNetworkVC.delegate = self
                                                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                                                editSocialNetworkVC.objSocialNetworkList = objSocialNetwork
                                                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                                                
                                                                if intBadgeCount == 0 {
                                                                    editSocialNetworkVC.isFirstTimeTapped = true
                                                                }
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
                                cell.configureCellForLinkStore(objSocialNetworkList: socialNetworkList, badgeCount: "\(count)")
                            } else {
                                badges[socialName ?? ""] = "No Badge"
                                cell.configureCellForLinkStore(objSocialNetworkList: socialNetworkList, badgeCount: "0")
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
                                        
                                    } else {
                                        
                                        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                        editSocialNetworkVC.delegate = self
                                        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                        editSocialNetworkVC.objSocialNetworkList = self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row]
                                        editSocialNetworkVC.isFromLinkStoreAdd = true
                                        editSocialNetworkVC.isFirstTimeTapped = true
                                        self.present(editSocialNetworkVC, animated: true)
                                    }
                                    
                                } else if loginUser?.subscriptionStatus == "1" { // TODO: Not allow to add more than 5 same social network
                                    
                                    let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                    editSocialNetworkVC.delegate = self
                                    editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                    editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                    editSocialNetworkVC.objSocialNetworkList = self.arrFilterSocialNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row]
                                    editSocialNetworkVC.isFromLinkStoreAdd = true
                                    
                                    if intBadgeCount == 0 {
                                        editSocialNetworkVC.isFirstTimeTapped = true
                                    }
                                    self.present(editSocialNetworkVC, animated: true)
                                }
                            }
                        }
                        
                    } else if UserLocalData.userMode == "1" {
                        
                        if let businessNetworkList = self.arrFilterBusinessNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row] {
                            
                            //---------------
                            var badges: [String: String] = [:]
                            
                            let socialName = businessNetworkList.social_name?.lowercased()
                            if let count = self.socialNameCount[(socialName ?? "").lowercased()] {
                                badges[socialName ?? ""] = "Badge \(count)"
                                cell.configureCellForLinkStore(objSocialNetworkList: businessNetworkList, badgeCount: "\(count)")
                            } else {
                                badges[socialName ?? ""] = "No Badge"
                                cell.configureCellForLinkStore(objSocialNetworkList: businessNetworkList, badgeCount: "0")
                            }
                            
                            // Now, 'badges' dictionary contains badges assigned to each 'social_name'
                            for (socialName, badge) in badges {
                                print("\(socialName): \(badge)")
                            }
                            //---------------
                            
                            //cell.configureCellForLinkStore(objSocialNetworkList: businessNetworkList)
                            
                            cell.editBtnAction = { (badgeCount) in
                                
                                let intBadgeCount = Int(badgeCount) ?? 0
                                self.countBeforeAdd = intBadgeCount
                                self.socialNameToAdd = businessNetworkList.social_name?.lowercased() ?? ""
                                
                                let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                editSocialNetworkVC.delegate = self
                                editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                editSocialNetworkVC.objSocialNetworkList = self.arrFilterBusinessNetwork[self.currentSelectedIndex - 1].social_network_list?[indexPath.row]
                                editSocialNetworkVC.isFromLinkStoreAdd = true
                                
                                if intBadgeCount == 0 {
                                    editSocialNetworkVC.isFirstTimeTapped = true
                                }
                                self.present(editSocialNetworkVC, animated: true)
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
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "\(count)")
                                    } else {
                                        badges[socialName] = "No Badge"
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "0")
                                    }
                                    
                                    cell.editBtnAction = { (badgeCount) in
                                        
                                        let intBadgeCount = Int(badgeCount) ?? 0
                                        self.countBeforeAdd = intBadgeCount
                                        self.socialNameToAdd = socialItem.social_name?.lowercased() ?? ""
                                        
                                        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                        editSocialNetworkVC.delegate = self
                                        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                        editSocialNetworkVC.objSocialNetworkList = socialItem
                                        editSocialNetworkVC.isFromLinkStoreAdd = true
                                        
                                        if intBadgeCount == 0 {
                                            editSocialNetworkVC.isFirstTimeTapped = true
                                        }
                                        self.present(editSocialNetworkVC, animated: true)
                                    }
                                    break
                                }
                            }
                        }
                    }
                    
                } else if UserLocalData.userMode == "1" {
                    
                    let socialNetworkItem = self.arrFilterBusinessNetwork[indexPath.row]
                    
                    if let socialList = socialNetworkItem.social_network_list {
                        var badges: [String: String] = [:]
                        
                        for socialItem in socialList {
                            
                            if let socialName = socialItem.social_name?.lowercased() {
                                
                                if socialName.lowercased().contains(txtSearch.text?.lowercased() ?? "") {
                                    //var badgeCount = "No Badge"
                                    
                                    if let count = self.socialNameCount[socialName.lowercased()] {
                                        badges[socialName] = "Badge \(count)"
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "\(count)")
                                    } else {
                                        badges[socialName] = "No Badge"
                                        cell.configureCellForLinkStore(objSocialNetworkList: socialItem, badgeCount: "0")
                                    }
                                    
                                    cell.editBtnAction = { (badgeCount) in
                                        
                                        let intBadgeCount = Int(badgeCount) ?? 0
                                        self.countBeforeAdd = intBadgeCount
                                        self.socialNameToAdd = socialItem.social_name?.lowercased() ?? ""
                                        
                                        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
                                        editSocialNetworkVC.delegate = self
                                        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
                                        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
                                        editSocialNetworkVC.objSocialNetworkList = socialItem
                                        editSocialNetworkVC.isFromLinkStoreAdd = true
                                        
                                        if intBadgeCount == 0 {
                                            editSocialNetworkVC.isFirstTimeTapped = true
                                        }
                                        self.present(editSocialNetworkVC, animated: true)
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

// ----------------------------------------------------------
//                MARK: - UITextField Delegate -
// ----------------------------------------------------------
extension LinkStoreVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.viewSearch.layer.borderColor = UIColor.appBlue_0066FF().cgColor
        self.viewSearch.layer.borderWidth = 1.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.viewSearch.layer.borderWidth = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
                
            case self.txtSearch:
                self.txtSearch.resignFirstResponder()
                break
                
            default:
                break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Check if the replacement string is trying to add whitespace at the beginning
        if string.rangeOfCharacter(from: .whitespacesAndNewlines) != nil && range.location == 0 {
            // Prevent adding whitespace at the beginning
            return false
        }
        return true
    }
}
