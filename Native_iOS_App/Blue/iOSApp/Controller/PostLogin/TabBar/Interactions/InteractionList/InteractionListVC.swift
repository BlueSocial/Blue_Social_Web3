//
//  InteractionListVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class InteractionListVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var tblInteraction: UITableView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var viewInteraction: UIView!
    @IBOutlet weak var viewNoInteraction: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var viewNoInteractionFound: UIView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    weak var parentVC: InteractionsVC?
    internal var arrInteraction: [DeviceScanHistory] = []
    private var arrFilterInteraction: [DeviceScanHistory] = []
    private var refreshControl = UIRefreshControl()
    private var currentPageIndex = 0
    private var pageIndex = 0
    private var totalPageIndex = 0
    private var isMoreDataAvailable = true
    private var activityIndicator: LoadMoreActivityIndicator!
    private var isUserSubscribed: Bool = false
    private var isFromProfile: Bool = false
    private var user_id = ""
    private var isBackFromProfileScreen: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isBackFromProfileScreen && self.txtSearch.text != "" {
            
            // Keep last search results
            
        } else {
            
            self.resetArrayData()
            
            DispatchQueue.main.async {
                
                if let dbUserInteractionData = DBManager.getDeviceHistory(userID: UserLocalData.UserID) {
                    self.arrInteraction = dbUserInteractionData
                    self.setupArrayAndUI()
                    self.callGetDeviceHistoryAPI(isFirstTime: false)
                    
                } else {
                    self.callGetDeviceHistoryAPI(isFirstTime: true)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.isBackFromProfileScreen = false
    }
    
    @objc func refreshList(_ sender: UIRefreshControl) {
        
        DispatchQueue.main.async {
            self.arrInteraction.removeAll()
            self.viewSearch.isUserInteractionEnabled = false
            self.callGetDeviceHistoryAPI()
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - UIButton Action -
    // ----------------------------------------------------------
    @IBAction func onBtnClear(_ sender: UIButton) {
        
        self.txtSearch.text = ""
        self.arrFilterInteraction = self.arrInteraction
        self.viewNoInteractionFound.isHidden = true
        
        if self.arrFilterInteraction.isEmpty {
            self.lblResult.isHidden = true
        } else {
            self.lblResult.isHidden = false
        }
        self.lblResult.text = "\(self.arrInteraction.count) result\((self.arrInteraction.count > 1) ? "s" : "")"
        self.btnClear.isHidden = true
        self.tblInteraction.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard let updatedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !updatedString.isEmpty else {
            // If the search string is empty or nil, return all interactions
            self.arrFilterInteraction = self.arrInteraction
            self.btnClear.isHidden = true
            self.viewNoInteractionFound.isHidden = true
            
            self.lblResult.isHidden = self.arrFilterInteraction.isEmpty ? true : false
            self.lblResult.text = "\(self.arrFilterInteraction.count) result\((self.arrFilterInteraction.count > 1) ? "s" : "")"
            self.tblInteraction.reloadData()
            print("No search string. Showing all interactions.")
            return
        }
        
        self.arrFilterInteraction = self.arrInteraction.filter { interaction in
            
            var shouldReturnTrue = false
            
            // Filter based on the fullname (case-insensitive)
            if let nameContainsString = interaction.fullname?.lowercased().contains(updatedString), nameContainsString == true {
                shouldReturnTrue = true
            }
            
            // Filter based on the label (case-insensitive)
            if let parametersContainString = interaction.label?.contains(where: { $0.lowercased().contains(updatedString)}), parametersContainString == true {
                shouldReturnTrue = true
            }
            
            return shouldReturnTrue
        }
        
        self.lblResult.text = "\(self.arrFilterInteraction.count) result\((self.arrFilterInteraction.count > 1) ? "s" : "")"
        self.tblInteraction.reloadData()
        
        // Hide/show views based on the filtered results
        if self.arrFilterInteraction.isEmpty {
            self.viewNoInteractionFound.isHidden = false
            
            self.lblResult.isHidden = true
        } else {
            self.viewNoInteractionFound.isHidden = true
            
            self.lblResult.isHidden = false
        }
        
        // Show/hide the clear button based on the length of the search string
        self.btnClear.isHidden = updatedString.count == 0
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callGetDeviceHistoryAPI(isFirstTime: Bool = false) {
        
        let url = BaseURL + APIName.kGetDeviceHistory
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kDeviceHistory,
                                    APIParamKey.kUserId: UserLocalData.UserID]
        
        if !(self.refreshControl.isRefreshing) && isFirstTime {
            if let parentVC = self.parent as? BaseVC {
                parentVC.showCustomLoader()
                (self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar.isUserInteractionEnabled = false
                ((self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar as? CustomTabBar)?.disableUserInteraction()
            }
        }
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            self.refreshControl.isRefreshing ? self.refreshControl.endRefreshing() : (isFirstTime ? self.hideCustomLoader() : nil)
            
            if !(self.refreshControl.isRefreshing) && isFirstTime {
                if let parentVC = self.parent as? BaseVC {
                    parentVC.hideCustomLoader()
                    (self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar.isUserInteractionEnabled = true
                    ((self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar as? CustomTabBar)?.enableUserInteraction()
                }
            }
            
            if isSuccess, var deviceScanHistory = response?.deviceScanHistory {
                
                deviceScanHistory = self.sortDataByDate(deviceScanHistory)
                self.arrInteraction = deviceScanHistory
                
                let dbUserInteractionData = DBManager.getDeviceHistory(userID: UserLocalData.UserID)
                
                // Iterate through arrInteraction and check if the uniqueId exists in dbUserInteractionData
                var modifiedArrInteraction: [DeviceScanHistory] = []
                
                for arrElement in self.arrInteraction {
                    var isMatchingElementFound = false
                    
                    for dbElement in dbUserInteractionData ?? [] {
                        if dbElement.id == arrElement.id {
                            // Matching element found
                            //print("ID: \(arrElement.id ?? "") exists. Element Name: \(arrElement.fullname ?? "")")
                            isMatchingElementFound = true
                            
                            // Create a copy of arrElement and modify the properties
                            var modifiedElement = arrElement
                            modifiedElement.isProfileVisited = dbElement.isProfileVisited
                            
                            // Add the modified element to the new array
                            modifiedArrInteraction.append(modifiedElement)
                        }
                    }
                    
                    if !isMatchingElementFound {
                        // No matching element found
                        //print("ID: \(arrElement.id ?? "") does not exist.")
                        
                        var modifiedElement = arrElement
                        modifiedElement.isProfileVisited = false
                        
                        // Add the modified element to the new array
                        modifiedArrInteraction.append(modifiedElement)
                    }
                }
                
                // Update the original array with modified elements
                self.arrInteraction = modifiedArrInteraction
                
                if let setDeviceInteraction = self.arrInteraction.toJSONString() {
                    self.updateDataIntoDB(deviceInteraction: setDeviceInteraction)
                }
                
                if self.txtSearch.text == "" {
                    self.setupArrayAndUI()
                }
                
                self.viewSearch.isUserInteractionEnabled = true
                
            } else {
                
                if isFirstTime {
                    self.showAlertWithOKButton(message: msg)
                }
                
                self.refreshControl.isRefreshing ? self.refreshControl.endRefreshing() : (isFirstTime ? self.hideCustomLoader() : nil)
                
                if !(self.refreshControl.isRefreshing) && isFirstTime {
                    if let parentVC = self.parent as? BaseVC {
                        parentVC.hideCustomLoader()
                        (self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar.isUserInteractionEnabled = true
                        ((self.navigationController?.viewControllers.last as? MainTabbarController)?.tabBar as? CustomTabBar)?.enableUserInteraction()
                    }
                }
            }
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
        
        self.txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.tblInteraction.isHidden = false
        self.tblInteraction.register(InteractionTblCell.nib, forCellReuseIdentifier: InteractionTblCell.identifier)
        self.setupPullToRefresh()
        self.setupPaginationLoading()
    }
    
    private func setupPaginationLoading() {
        
        //to add loader at bottom for Load more or Pagination
        self.tblInteraction.tableFooterView = UIView()
        
        self.activityIndicator = LoadMoreActivityIndicator(scrollView: self.tblInteraction, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 50)
    }
    
    private func setupPullToRefresh() {
        
        if (self.txtSearch.text?.count ?? 0) > 0 { return }
        
        self.refreshControl.tintColor = UIColor.init(hexString: "#DEDEDF")
        self.refreshControl.addTarget(self, action: #selector(self.refreshList(_:)), for: .valueChanged)
        
        self.tblInteraction.addSubview(self.refreshControl)
        self.refreshControl.didMoveToSuperview()
    }
    
    private func updateDataIntoDB(deviceInteraction: String) {
        
        if DBManager.isDeviceHistoryExist(userID: UserLocalData.UserID) {
            
            // UPDATE
            if DBManager.setDeviceHistory(userID: UserLocalData.UserID, requestBody: deviceInteraction) {
                print("UPDATE API Response in DeviceHistory Table Successfully")
            }
            
        } else {
            
            // INSERT
            if DBManager.insertDeviceHistory(userID: UserLocalData.UserID, requestBody: deviceInteraction) {
                print("INSERT API Response in DeviceHistory Table Successfully")
            }
        }
        
        DispatchQueue.main.async {
            self.tblInteraction.reloadData()
        }
    }
    
    private func resetArrayData() {
        
        self.arrInteraction.removeAll()
        
        self.txtSearch.text = ""
        self.btnClear.isHidden = true
    }
    
    private func setupArrayAndUI() {
        
        DispatchQueue.main.async {
            
            self.arrFilterInteraction = self.arrInteraction
            self.lblResult.text = "\(self.arrFilterInteraction.count) result\((self.arrFilterInteraction.count > 1) ? "s" : "")"
            
            if self.arrFilterInteraction.count > 0 {
                
                self.viewInteraction.isHidden = false
                self.viewNoInteraction.isHidden = true
                self.viewNoInteractionFound.isHidden = true
                self.lblResult.isHidden = false
                
            } else {
                
                self.viewInteraction.isHidden = true
                self.viewNoInteraction.isHidden = false
                self.viewNoInteractionFound.isHidden = false
                self.lblResult.isHidden = true
            }
            
            self.tblInteraction.reloadData()
        }
    }
    
    private func sortDataByDate(_ data: [DeviceScanHistory]) -> [DeviceScanHistory] {
        
        return data.sorted { (history1, history2) -> Bool in
            
            if let date1 = self.dateFormatter.date(from: history1.dt_created ?? ""),
               let date2 = self.dateFormatter.date(from: history2.dt_created ?? "") {
                return date1 > date2
            }
            return false
        }
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension InteractionListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFilterInteraction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblInteraction.dequeueReusableCell(withIdentifier: InteractionTblCell.identifier) as? InteractionTblCell {
            
            guard self.arrFilterInteraction.indices.contains(indexPath.row) else { return UITableViewCell() }
            
            //print("arrLabel :: \(self.arrFilterInteraction[indexPath.row].label ?? [])")
            
            cell.setupInteraction(objInteraction: self.arrFilterInteraction[indexPath.row])
            
            if self.arrFilterInteraction[indexPath.row].isProfileVisited == true {
                cell.imgViewDot.isHidden = true
            }
            
            if indexPath.row == self.arrFilterInteraction.count - 1 {
                if cell.arrLabel.isEmpty {
                    cell.cvLabels.isHidden = true
                    cell.heightCVLabels.constant = 0
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension InteractionListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("arrLabel :: \(self.arrFilterInteraction[indexPath.row].label ?? [])")
        
        let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
        
        profileVC.navigationScreen = .deviceHistory
        
        profileVC.addNoteCallback = { (txtNote, arrLabel) in
            
            self.isBackFromProfileScreen = true
            self.arrFilterInteraction[indexPath.row].notes = txtNote
            self.arrFilterInteraction[indexPath.row].label = arrLabel
            self.arrFilterInteraction[indexPath.row].isProfileVisited = true
            
            if let setDeviceInteraction = self.arrFilterInteraction.toJSONString() {
                self.updateDataIntoDB(deviceInteraction: setDeviceInteraction)
            }
        }
        
        profileVC.deviceScanHistory = self.arrFilterInteraction[indexPath.row]
        
        // Use a custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        if self.arrFilterInteraction[indexPath.row].referal_connect == "1" {
            profileVC.isUser_ReferalConnect = true
        } else if self.arrFilterInteraction[indexPath.row].referal_connect == "0" {
            profileVC.isUser_ReferalConnect = false
        }
        profileVC.receiver_id = self.arrFilterInteraction[indexPath.row].receiver_id ?? ""
        self.navigationController?.pushViewController(profileVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        74
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// ----------------------------------------------------------
//                MARK: - UITextField Delegate -
// ----------------------------------------------------------
extension InteractionListVC: UITextFieldDelegate {
    
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
