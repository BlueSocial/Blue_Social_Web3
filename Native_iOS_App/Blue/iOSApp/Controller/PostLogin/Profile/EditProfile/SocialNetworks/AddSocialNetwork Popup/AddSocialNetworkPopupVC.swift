//
//  AddSocialNetworkPopupVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class AddSocialNetworkPopupVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var tblSocialNetWork         : UITableView!
    @IBOutlet weak var viewBottom               : UIView!
    @IBOutlet weak var viewBlur                 : UIView!
    @IBOutlet weak var heightViewMiddle         : NSLayoutConstraint!
    @IBOutlet weak var heightTblSocialNetWork   : NSLayoutConstraint!
    @IBOutlet weak var lblTitle                 : UILabel!
    
    // ----------------------------------------------------------
    //                       MARK: - property -
    // ----------------------------------------------------------
    private var swipeGesture: UISwipeGestureRecognizer?
    //    private var arrSocialNetwork = [Social_Network]()
    //    private var arrSocialNetworkList = [Social_Network_List]()
    private var arrSocialNetwork = [Social_Network]()
    private var arrBusinessNetwork = [Social_Network]()
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserLocalData.userMode == "0" {
            self.callGetSocialListAPI(showloader: true, isBusinessProfile: "0")
        } else if UserLocalData.userMode == "1" {
            self.callGetSocialListAPI(showloader: true, isBusinessProfile: "1")
        }
        
        //        self.filterAndSetArrayData()
        
        self.tblSocialNetWork.register(AddNetworkHeaderTblCell.nib, forHeaderFooterViewReuseIdentifier: AddNetworkHeaderTblCell.identifier)
        self.tblSocialNetWork.register(AddNetworkTblCell.nib, forCellReuseIdentifier: AddNetworkTblCell.identifier)
        
        self.addGestureRecognizerToDismissPopupView()
        
        self.setTVSocialNetWorkHeight()
        //self.tblSocialNetWork.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setTVSocialNetWorkHeight()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @objc func blurViewTap(_ sender: UITapGestureRecognizer?) {
        self.dismiss(animated: true)
    }
    
    @objc private func swipeDown() {
        
        if self.swipeGesture?.direction == .down {
            self.dismiss(animated: true)
            
            //            // Define the animation properties
            //            let animationDuration: TimeInterval = 0.5
            //            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            //
            //            // Animate the dismissal
            //            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
            //                self.view.alpha = 0
            //            }) { (finished) in
            //                if finished {
            //                    self.dismiss(animated: false, completion: nil)
            //                }
            //            }
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
            if showloader { self.hideCustomLoader() }
            
            if isSuccess {
                
                if isBusinessProfile == "0" {
                    self.arrSocialNetwork = response?.socialNetworkModel?.social_network ?? [Social_Network]()
                } else if isBusinessProfile == "1" {
                    self.arrBusinessNetwork = response?.socialNetworkModel?.social_network ?? [Social_Network]()
                }
                
                // // Uncomment If want to Expand First Network
                // for i in 0 ... self.arrSocialNetwork.count - 1 {
                //     self.arrSocialNetwork[i].isExpanded = false
                // }
                // self.arrSocialNetwork.first?.isExpanded = true
                
                self.tblSocialNetWork.reloadData()
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    private func addGestureRecognizerToDismissPopupView() {
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
        
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeDown))
        self.swipeGesture?.direction = .down
        self.viewBottom.addGestureRecognizer(self.swipeGesture!)
    }
    
    //    private func filterAndSetArrayData() {
    //
    //        if loginUser != nil {
    //
    //            if UserLocalData.userMode == "0" { // loginUser?.user_mode // Social
    //
    //                self.lblTitle.text = "Add social information"
    //                self.arrSocialNetwork = loginUser?.social_network ?? [Social_Network]()
    //
    //                // Iterate through arrSocialNetwork and fill arrSocialNetworkList
    //                for network in self.arrSocialNetwork {
    //                    self.arrSocialNetworkList.append(contentsOf: network.social_network_list ?? [])
    //                }
    //
    //            } else if UserLocalData.userMode == "1" { // Business
    //
    //                self.lblTitle.text = "Add business information"
    //                self.arrSocialNetwork = loginUser?.business_network ?? [Social_Network]()
    //
    //                // Iterate through arrSocialNetwork and fill arrSocialNetworkList
    //                for network in self.arrSocialNetwork {
    //                    self.arrSocialNetworkList.append(contentsOf: network.social_network_list ?? [])
    //                }
    //            }
    //        }
    //    }
    
    private func setTVSocialNetWorkHeight() {
        
        self.tblSocialNetWork.reloadData()
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // Delay seconds
            // Code to be executed after the delay
            print("This code will run after a 0.001-second delay.")
            self.heightTblSocialNetWork.constant = self.tblSocialNetWork.contentSize.height
            self.heightViewMiddle.constant = self.tblSocialNetWork.contentSize.height + 100
        }
    }
    
    private func toggleSection(_ section: Int) {
        
        // Toggle the section's expanded state
        if UserLocalData.userMode == "0" {
            self.arrSocialNetwork[section].isExpanded.toggle()
        } else if UserLocalData.userMode == "1" {
            self.arrBusinessNetwork[section].isExpanded.toggle()
        }
        
        self.setTVSocialNetWorkHeight()
    }
}

// ----------------------------------------------------------
//       MARK: - UITableView DataSource -
// ----------------------------------------------------------
extension AddSocialNetworkPopupVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if UserLocalData.userMode == "0" {
            return self.arrSocialNetwork.count
        } else if UserLocalData.userMode == "1" {
            return self.arrBusinessNetwork.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if UserLocalData.userMode == "0" {
            return self.arrSocialNetwork[section].isExpanded ? (self.arrSocialNetwork[section].social_network_list?.count ?? 0) : 0
        } else if UserLocalData.userMode == "1" {
            return self.arrBusinessNetwork[section].isExpanded ? (self.arrBusinessNetwork[section].social_network_list?.count ?? 0) : 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = self.tblSocialNetWork.dequeueReusableCell(withIdentifier: AddNetworkTblCell.identifier, for: indexPath) as? AddNetworkTblCell {
            
            if UserLocalData.userMode == "0" {
                
                cell.configureCell(objSocialNetworkList: self.arrSocialNetwork[indexPath.section].social_network_list?[indexPath.item])
                
            } else if UserLocalData.userMode == "1" {
                
                cell.configureCell(objSocialNetworkList: self.arrBusinessNetwork[indexPath.section].social_network_list?[indexPath.item])
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UITableView Delegate -
// ----------------------------------------------------------
extension AddSocialNetworkPopupVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(self.arrSocialNetwork[indexPath.section].social_network_list?[indexPath.item].social_title ?? "")
        
        //        let editSocialNetworkVC = EditSocialNetworkVC.instantiate(fromAppStoryboard: .Login)
        //        editSocialNetworkVC.modalPresentationStyle = .overCurrentContext
        //        editSocialNetworkVC.modalTransitionStyle = .crossDissolve
        //        editSocialNetworkVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1) // 10%
        //
        //        if UserLocalData.userMode == "0" {
        //
        //            editSocialNetworkVC.objSocialNetworkList = self.arrSocialNetwork[indexPath.section].social_network_list?[indexPath.item]
        //
        //        } else if UserLocalData.userMode == "1" {
        //
        //            editSocialNetworkVC.objSocialNetworkList = self.arrBusinessNetwork[indexPath.section].social_network_list?[indexPath.item]
        //        }
        //
        //        self.present(editSocialNetworkVC, animated: true)
    }
    
    // View For Header Section With XIB File
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = tblSocialNetWork.dequeueReusableHeaderFooterView(withIdentifier: AddNetworkHeaderTblCell.identifier) as? AddNetworkHeaderTblCell {
            
            headerView.btnExapand.tag = section
            
            headerView.completion = { (toggleSection) in
                self.toggleSection(toggleSection)
            }
            
            if UserLocalData.userMode == "0" {
                
                headerView.configureCell(objSocialNetwork: self.arrSocialNetwork[section])
                
                let isExpanded = self.arrSocialNetwork[section].isExpanded
                
                if isExpanded {
                    headerView.stackViewSampleNetwork.isHidden = true
                    headerView.imgViewExpandCollapseArrow.image = UIImage(named: "ic_arrow_up")
                } else {
                    headerView.stackViewSampleNetwork.isHidden = false
                    headerView.imgViewExpandCollapseArrow.image = UIImage(named: "ic_arrow_down1")
                }
                
            } else if UserLocalData.userMode == "1" {
                
                headerView.configureCell(objSocialNetwork: self.arrBusinessNetwork[section])
                
                let isExpanded = self.arrBusinessNetwork[section].isExpanded
                
                if isExpanded {
                    headerView.stackViewSampleNetwork.isHidden = true
                    headerView.imgViewExpandCollapseArrow.image = UIImage(named: "ic_arrow_up")
                } else {
                    headerView.stackViewSampleNetwork.isHidden = false
                    headerView.imgViewExpandCollapseArrow.image = UIImage(named: "ic_arrow_down1")
                }
            }
            
            return headerView
        }
        return UIView()
    }
}
