//
//  MoreVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import SafariServices

class MoreVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlets -
    // ----------------------------------------------------------
    @IBOutlet weak var lblBSTBalance: UILabel!
    @IBOutlet weak var lblBSTInUSD: UILabel!
    @IBOutlet weak var lblWalletAddress: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var businessFirstname = ""
    private var businessLastname = ""
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //@ethan
        NotificationCenter.default.addObserver(self, selector: #selector(handleBalanceUpdate(notification:)), name: .balanceUpdated, object: nil)

        setupUI()
    }
    
//    //@ethan
//    deinit {
//            NotificationCenter.default.removeObserver(self, name: .balanceUpdated, object: nil)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //@ethan
        fetchBalanceFromNative()
        
        //self.setProfileImage()
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    // changed to send to hyperlink @ethan
    @IBAction func onBtnWallet(_ sender: UIButton) {
        print("clicked wallet")
        
        if let walletLink = UserDefaults.standard.string(forKey: "walletLink") {
            print("Stored wallet link: \(walletLink)")
            if let url = URL(string: walletLink) {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            } else {
                print("Invalid URL stored in UserDefaults: \(walletLink)")
            }
        } else {
            print("No wallet link found in UserDefaults")
        }
    }
    
    
    @IBAction func onBtnMarketPlace(_ sender: UIButton) {
        
        if let url = URL(string: "https://blue.social/shop-blue/") {
            
            if UIApplication.shared.canOpenURL(url) {
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
                
            } else {
                // Handle the case where the URL cannot be opened
                // For example, show an error message to the user
            }
            
        } else {
            // Handle the case where the URL is not valid
            // For example, show an error message to the user
        }
    }
    
    @IBAction func onBtnSettings(_ sender: UIButton) {
        
        let settingsVC = SettingsVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func onBtnMyProfile(_ sender: UIButton) {
        
        if loginUser?.username == "" || loginUser?.username == nil || loginUser?.profile_img == "" || loginUser?.profile_img == nil { // Incomplete Profile
            
            let finishProfileVC = FinishProfileVC.instantiate(fromAppStoryboard: .Login)
            finishProfileVC.modalTransitionStyle = .crossDissolve
            finishProfileVC.modalPresentationStyle = .overCurrentContext
            self.present(finishProfileVC, animated: true)
            
        } else { // Completed Profile
            
            let profileVC = ProfileVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
            profileVC.navigationScreen = .currentUserProfile
            
            // Use a custom transition
            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
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
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    
    //@ethan
    private func setupUI() {
        let savedBalance = UserDefaults.standard.string(forKey: "userBalance") ?? "0"
        let savedUsdRate = UserDefaults.standard.string(forKey: "usdRate") ?? "0.0"
        let savedWalletAddress = UserDefaults.standard.string(forKey: "walletAddress") ?? ""
        let savedWalletLink = UserDefaults.standard.string(forKey: "walletLink") ?? ""
        updateBalance(savedBalance, usdRate: savedUsdRate, walletAddress: savedWalletAddress, link: savedWalletLink)
    }

    private func fetchBalanceFromNative() {
        let walletInfoBridge = WalletInfoBridge()
        walletInfoBridge.fetchBalance { [weak self] balance, usdRate, walletAddress, link in
            self?.updateBalance(balance, usdRate: usdRate, walletAddress: walletAddress, link: link)
        }
    }

    @objc private func handleBalanceUpdate(notification: Notification) {
        if let balance = notification.userInfo?["userBalance"] as? String,
           let usdRate = notification.userInfo?["usdRate"] as? String,
           let walletAddress = notification.userInfo?["walletAddress"] as? String,
           let link = notification.userInfo?["walletLink"] as? String {
            updateBalance(balance, usdRate: usdRate, walletAddress: walletAddress, link: link)
        }
    }

    func updateBalance(_ balance: String, usdRate: String, walletAddress: String, link: String) {
        if let balanceDouble = Double(balance), let usdRateDouble = Double(usdRate) {
            self.lblBSTBalance.text = "\(balanceDouble)"
            let BSTInUSD = self.returnTwoDigitAfterDecimal(balanceDouble * usdRateDouble)
            self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
            print(walletAddress)  // Print the wallet address
            self.lblWalletAddress.text = walletAddress // Uncomment this if you want to update the UI label as well
            // Save balance, USD rate, wallet address, and link to UserDefaults
            UserDefaults.standard.set(balance, forKey: "userBalance")
            UserDefaults.standard.set(usdRate, forKey: "usdRate")
            UserDefaults.standard.set(walletAddress, forKey: "walletAddress")
            UserDefaults.standard.set(link, forKey: "walletLink")
        }
    }
    
//    private func setProfileImage() {
//        
//        self.getLoginUserDataFromDB(userMode: UserLocalData.userMode) { isSuccess, userData in
//            
//            if isSuccess {
//                
//                DispatchQueue.main.async {
//                    
//                    if UserLocalData.userMode == "1" {
//                        
//                        //@ethan removed this
//                        //self.lblBSTBalance.text = "\(userData?.totalBST ?? 0)"
//                        
//                       // let BSTInUSD = self.returnTwoDigitAfterDecimal((Double(userData?.totalBST ?? 0) * 0.10))
//                        //self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
//                        
//                        self.fetchBalanceFromNative()
//                        
//                        if userData?.business_profileURL != "" && userData?.business_profileURL != nil {
//                            
//                            if let url = URL(string: userData?.business_profileURL ?? "") {
//                                self.imgProfile.af_setImage(withURL: url)
//                            }
//                            
//                        } else {
//                            
//                            if let firstName = userData?.business_firstName?.capitalized.first {
//                                self.businessFirstname = String(firstName)
//                                
//                            } else if let firstName = userData?.firstname?.capitalized.first {
//                                self.businessFirstname = String(firstName)
//                            }
//                            
//                            if let lastName = userData?.business_lastName?.capitalized.first {
//                                self.businessLastname = String(lastName)
//                                
//                            } else if let lastName = userData?.lastname?.capitalized.first {
//                                self.businessLastname = String(lastName)
//                            }
//                            
//                            self.imgProfile.image = UIImage.imageWithInitial(initial: "\(self.businessFirstname)\(self.businessLastname)", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
//                        }
//                        
//                    } else {
//                        
//                        self.fetchBalanceFromNative()
//                        
//                        //@ethan
//                        //self.lblBSTBalance.text = "\(userData?.totalBST ?? 0)"
//                        
//                        //let BSTInUSD = self.returnTwoDigitAfterDecimal((Double(userData?.totalBST ?? 0) * 0.10))
//                        //self.lblBSTInUSD.text = "$\(BSTInUSD) USD"
//                        
//                        if userData?.profile_img != "" && userData?.profile_img != nil {
//                            
//                            if let url = URL(string: userData?.profile_img ?? "") {
//                                self.imgProfile.af_setImage(withURL: url)
//                            }
//                            
//                        } else {
//                            
//                            self.imgProfile.image = UIImage.imageWithInitial(initial: "\(userData?.firstname?.capitalized.first ?? "A")\(userData?.lastname?.capitalized.first ?? "B")", imageSize: self.imgProfile.bounds.size, gradientColors: [UIColor.appBlueGradient1_495AFF(), UIColor.appBlueGradient2_0ACFFE()], font: UIFont(name: "RedHatDisplay-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16))
//                        }
//                    }
//                }
//            }
//        }
//    }
}
