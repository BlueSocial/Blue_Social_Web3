//
//  InsightSocialLinksVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InsightSocialLinksVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var tblSocialLinks: UITableView!
    @IBOutlet weak var nodataView: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - property -
    // ----------------------------------------------------------
    private var socialNetworkClick = [SocialListNetwork]()
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDataIntoDB()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        // Register XIB File in Table View
        self.tblSocialLinks.register(AddNetworkHeaderTblCell.nib, forHeaderFooterViewReuseIdentifier: AddNetworkHeaderTblCell.identifier)
        self.tblSocialLinks.register(AddNetworkTblCell.nib, forCellReuseIdentifier: AddNetworkTblCell.identifier)
        self.tblSocialLinks.register(SocialLinkCountFooterTableViewCell.nib, forCellReuseIdentifier: SocialLinkCountFooterTableViewCell.identifier)
    }
    
    private func toggleSection(_ section: Int) {
        
        self.socialNetworkClick[section].Social_networkExpand.toggle()
        self.tblSocialLinks.reloadData()
    }
    
    private func updateLinkProfile() {
        
        self.tblSocialLinks.reloadData()
    }
    
    private func loadDataIntoDB() {
        
        let dbUserData = DBManager.checkLinksInsightExist(userID: UserLocalData.UserID)
        
        if let dbUserModel = dbUserData.userData?.clickData, dbUserData.isSuccess {
            
            self.socialNetworkClick = dbUserModel
            
            DispatchQueue.main.async {
                self.updateLinkProfile()
            }
            self.callGetSocialClickAPI(isShowLoader: false)
            
        } else {
            self.callGetSocialClickAPI(isShowLoader: true)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - API Calling -
// ----------------------------------------------------------
extension InsightSocialLinksVC {
    
    // getSocialLinks | Get Social Link in Insights with no of taps
    private func callGetSocialClickAPI(isShowLoader: Bool) {
        
        let url = BaseURL + APIName.kGetSocialLinks
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kSocialClicks,
                                    APIParamKey.kUserId: UserLocalData.UserID]
        
        if isShowLoader {
            if let parentVC = self.parent as? BaseVC {
                parentVC.showCustomLoader()
            }
        }
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isShowLoader {
                if let parentVC = self.parent as? BaseVC {
                    parentVC.hideCustomLoader()
                }
            }
            
            if isSuccess {
                
                if let socialNetworkClick = response?.socialClick?.clickData {
                    self.socialNetworkClick = socialNetworkClick
                }
                
                self.updateLinkProfile()
                
                if let InsightsLinkDetail = response?.socialClick {
                    
                    let dbUserData = DBManager.checkLinksInsightExist(userID: UserLocalData.UserID)
                    
                    if dbUserData.isSuccess {
                        
                        let isLinksInsightUpdated = DBManager.updateLinksInsight(userID: UserLocalData.UserID, requestBody: InsightsLinkDetail.toJSONString() ?? "")
                        print("Is Blue LinksInsight Updated :: \(isLinksInsightUpdated)")
                        
                    } else {
                        
                        let isLinksInsightInserted = DBManager.insertProfileInsight(userID: UserLocalData.UserID, profileInsightsData: "", linkInsightsData: InsightsLinkDetail.toJSONString() ?? "")
                        print("Is Blue LinksInsight Inserted :: \(isLinksInsightInserted)")
                    }
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
}


// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension InsightSocialLinksVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.socialNetworkClick.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.socialNetworkClick[section].Social_networkExpand {
            return self.socialNetworkClick[section].social_network_list?.count ?? 0
        } else {
            return self.socialNetworkClick[section].social_network_list?.count ?? 0 >= 3 ?  3 : (self.socialNetworkClick[section].social_network_list?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblSocialLinks.dequeueReusableCell(withIdentifier: "AddNetworkTblCell", for: indexPath) as? AddNetworkTblCell {
            
            cell.imgSelected.isHidden = true
            let socialCategoryImage = self.socialNetworkClick[indexPath.section].social_network_list?[indexPath.row].social_icon ?? ""
            let socialCategory = self.socialNetworkClick[indexPath.section].social_network_list?[indexPath.row].social_name
            let socialCategoryCount = self.socialNetworkClick[indexPath.section].social_network_list?[indexPath.row].value ?? 0
            
            if let url = URL(string: socialCategoryImage) {
                cell.imgSocial.af_setImage(withURL: url)
            }
            
            cell.lblSocialNetworkName.text = socialCategory
            cell.lblTapsCount.text = "\(socialCategoryCount) taps"
            
            return cell
            
        }
        return UITableViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension InsightSocialLinksVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = tblSocialLinks.dequeueReusableHeaderFooterView(withIdentifier: AddNetworkHeaderTblCell.identifier) as? AddNetworkHeaderTblCell {
            
            headerView.lblSocialNetworkCategory.text = self.socialNetworkClick[section].social_category_title
            
            headerView.btnExapand.tag = section
            
            headerView.completion = { (toggleSection) in
                self.toggleSection(toggleSection)
            }
            headerView.stackViewSampleNetwork.isHidden = true
            headerView.imgViewExpandCollapseArrow.isHidden = true
            
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 71.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if self.socialNetworkClick[section].social_network_list?.count ?? 0 >= 3 {
            
            let footerCell = tableView.dequeueReusableCell(withIdentifier: "SocialLinkCountFooterTableViewCell") as! SocialLinkCountFooterTableViewCell
            DispatchQueue.main.async {
                footerCell.completion = {
                    self.socialNetworkClick[section].Social_networkExpand = !self.socialNetworkClick[section].Social_networkExpand
                    let contentOffset = tableView.contentOffset
                    tableView.reloadData()
                    tableView.setContentOffset(contentOffset, animated: false)
                }
            }
            
            footerCell.isExpanded = self.socialNetworkClick[section].Social_networkExpand
            return footerCell
            
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if self.socialNetworkClick[section].social_network_list?.count ?? 0 > 3 {
            return 100.0
            
        } else {
            return 0.0
        }
    }
}
