//
//  WalletVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class WalletVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var tblTransaction: UITableView!
    @IBOutlet weak var heightTblTransaction: NSLayoutConstraint!
    @IBOutlet weak var viewNoTransaction: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblBSTBalance: UILabel!
    @IBOutlet weak var lblBSTInUSD: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrIndividualInteraction: [IndividualProofInteractionModel] = [IndividualProofInteractionModel]()
    private var isViewWillAppearFirstTime: Bool = true
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnViewAll.isHidden = true
        
        self.tblTransaction.register(InteractionTblCell.nib, forCellReuseIdentifier: InteractionTblCell.identifier)
        self.tblTransaction.estimatedRowHeight = 74.0 // Adjust as needed
        self.tblTransaction.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupUI()
        self.showDataFromDB()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tblTransaction.reloadData()
        self.view.layoutIfNeeded()
        
        if self.arrIndividualInteraction.count == 0 {
            //self.heightTblTransaction.constant = 74
            
        } else {
            self.heightTblTransaction.constant = self.tblTransaction.contentSize.height //370
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnBuyTokens(_ sender: UIButton) {
        
        let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
        webContentVC.contentType = .BuyTokens
        navigationController?.pushViewController(webContentVC, animated: true)
    }
    
    @IBAction func onBtnWhitePaper(_ sender: UIButton) {
        
        let webContentVC = WebContentVC.instantiate(fromAppStoryboard: .Main)
        webContentVC.contentType = .WhitePaper
        navigationController?.pushViewController(webContentVC, animated: true)
    }
    
    @IBAction func onBtnViewAll(_ sender: UIButton) {
        
        let recentTransactionVC = RecentTransactionVC.instantiate(fromAppStoryboard: .Discover)
        recentTransactionVC.arrAll = self.arrIndividualInteraction
        self.navigationController?.pushViewController(recentTransactionVC, animated: true)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callGetIndividualProofInteractionAPI(receiverId: String, isFirstTime: Bool = false) {
        
        let url = BaseURL + APIName.kGetIndividualProofInteraction
        //let url = "http://52.25.225.196/api/" + APIName.kGetIndividualProofInteraction
        
        let param: [String: Any] = [APIParamKey.kReceiver_Id: receiverId,
                                    APIParamKey.kUser_Id: UserLocalData.UserID]

        if isFirstTime { self.showCustomLoader() }
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            if isFirstTime { self.hideCustomLoader() }
            
            if isSuccess, let historyInteraction = response?.getIndividualProofInteraction {
                
                self.arrIndividualInteraction = historyInteraction
                //self.arrUserInteractionHistory.append(contentsOf: historyInteraction)
                //self.pageIndex += 1
                //self.totalPageIndex = response?.totalPageIndex ?? 0
                
                // if self.pageIndex == self.totalPageIndex {
                //     self.isMoreDataAvailable = false
                // }

                let dbUserInteractionData = DBManager.getIndividualProofInteraction(userID: UserLocalData.UserID)
                
                var modifiedArrInteraction: [IndividualProofInteractionModel] = []
                
                for arrElement in self.arrIndividualInteraction {
                    var isMatchingElementFound = false
                    
                    for dbElement in dbUserInteractionData ?? [] {
                        if dbElement.id == arrElement.id {
                            // Matching element found
                            //print("ID: \(arrElement.id ?? "") exists. Element Name: \(arrElement.fullName ?? "")")
                            isMatchingElementFound = true
                            
                            // Create a copy of arrElement and modify the properties
                            let modifiedElement = arrElement
                            
                            // Add the modified element to the new array
                            modifiedArrInteraction.append(modifiedElement)
                        }
                    }
                    
                    if !isMatchingElementFound {
                        // No matching element found
                        //print("ID: \(arrElement.id ?? "") does not exist.")
                        
                        let modifiedElement = arrElement
                        
                        // Add the modified element to the new array
                        modifiedArrInteraction.append(modifiedElement)
                    }
                }
                
                if let setDeviceInteraction = self.arrIndividualInteraction.toJSONString() {
                    self.updateDataIntoDB(individualInteraction: setDeviceInteraction)
                }
                
                if self.arrIndividualInteraction.count == 0 {
                    self.tblTransaction.isHidden = true
                    self.viewNoTransaction.isHidden = false
                    self.btnViewAll.isHidden = true
                    
                } else {
                    self.tblTransaction.isHidden = false
                    self.viewNoTransaction.isHidden = true
                    self.btnViewAll.isHidden = false
                }
                
                self.tblTransaction.reloadData()
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    //--------------------------------------------------------
    //                  MARK: - Function -
    //--------------------------------------------------------
    private func showDataFromDB() {
        
        if let dbUserInteractionProofData = DBManager.getIndividualProofInteraction(userID: UserLocalData.UserID) {
            
            self.arrIndividualInteraction = dbUserInteractionProofData
            
            if self.arrIndividualInteraction.count == 0 {
                self.tblTransaction.isHidden = true
                self.viewNoTransaction.isHidden = false
                self.btnViewAll.isHidden = true
                
            } else {
                self.tblTransaction.isHidden = false
                self.viewNoTransaction.isHidden = true
                self.btnViewAll.isHidden = false
            }
            
            self.callGetIndividualProofInteractionAPI(receiverId: "0", isFirstTime: false)
            
        } else {
            self.callGetIndividualProofInteractionAPI(receiverId: "0", isFirstTime: true)
        }
    }
    
    private func setupUI() {
        
        self.lblBSTBalance.text = "\(loginUser?.totalBST ?? 0)"
        
        let BSTInUSD = self.returnTwoDigitAfterDecimal((Double(loginUser?.totalBST ?? 0) * 0.10))
        self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
    }
    
    private func updateDataIntoDB(individualInteraction: String) {
        
        if DBManager.isIndividualProofInteraction(userID: UserLocalData.UserID) {
            
            // UPDATE
            if DBManager.setIndividualProofInteraction(userID: UserLocalData.UserID, requestBody: individualInteraction) {
                print("UPDATE API Response in Individual Proof Interaction Table Successfully")
            }
            
        } else {
            
            // INSERT
            if DBManager.insertIndividualProofInteraction(userID: UserLocalData.UserID, requestBody: individualInteraction) {
                print("INSERT API Response in Individual Proof Interaction Table Successfully")
            }
        }
        self.tblTransaction.reloadData()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension WalletVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrIndividualInteraction.count >= 5 {
            return 5
        } else {
            return self.arrIndividualInteraction.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblTransaction.dequeueReusableCell(withIdentifier: InteractionTblCell.identifier) as? InteractionTblCell {
            guard self.arrIndividualInteraction.indices.contains(indexPath.row) else { return UITableViewCell() }
            cell.setupBSTHistory(objBSTHistory: self.arrIndividualInteraction[indexPath.row])
            cell.backgroundColor = UIColor.yellow
            return cell
        }
        
        return UITableViewCell()
        
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension WalletVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //.leastNonzeroMagnitude
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //.leastNonzeroMagnitude
        return 0
    }
}

