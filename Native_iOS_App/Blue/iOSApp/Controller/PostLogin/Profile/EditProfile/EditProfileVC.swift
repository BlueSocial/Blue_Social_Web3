//
//  EditProfileVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

class EditProfileVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var cvEditProfile: UICollectionView!
    @IBOutlet weak var containerViewEditProfile: UIView!
    @IBOutlet weak var btnSave: CustomButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var arrCategory = [String]()
    private var currentSelectedIndex = 0
    
    private var arrSocialNetwork = [Social_Network]()
    private var arrSocialNetworkList = [Social_Network_List]()
    
    // Declare your child view controllers as properties
    lazy var generalInfoVC: GeneralInfoVC = {
        return GeneralInfoVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
    }()
    
    lazy var interestVC: InterestVC = {
        return InterestVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
    }()
    
    lazy var socialVC: SocialVC = {
        return SocialVC.instantiate(fromAppStoryboard: .BlueProUserProfile)
    }()
    
    private var socialDetail: UserDetail?
    private var businessDetail: UserDetail?
    
    private var url: String = ""
    
    private var firstName: String = ""
    private var lastName: String = ""
    private var userName: String = ""
    private var companyOrUniversity: String = ""
    private var bio: String = ""
    private var switchPrivateMode: String = ""
    
    private var isUserChangeAnyData: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserProfileData()
        
        // setup initial save button state
        self.btnSave.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnSave.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        self.btnSave.isUserInteractionEnabled = false
        
        self.arrCategory = ["General info", "Interests", "Social Networks"]
        
        self.generalInfoVC.view.frame = self.containerViewEditProfile.bounds
        self.containerViewEditProfile.addSubview(self.generalInfoVC.view)
        self.generalInfoVC.delegate = self
        
        self.cvEditProfile.reloadData()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        //self.btnSave.isUserInteractionEnabled = true
        
        if self.isUserChangeAnyData {
            
            self.showAlertWith2ButtonswithColor(message: kLeaveWithoutSave, btnOneName: kALERT_CANCEL, btnOneColor: UIColor.appBlue_0066FF(), btnTwoName: kALERT_EXIT, btnTwoColor: UIColor.appRed_E13C3C(), title: kAppName) { btnAction in
                
                if btnAction == 1 { // CANCEL
                    self.dismiss(animated: true)
                } else if btnAction == 2 { // EXIT
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnSave(_ sender: UIButton) {
        
        self.calluPBSAPI(name: self.firstName + " " + self.lastName, firstName: self.firstName, lastName: self.lastName, userName: self.userName, companyOrUniversity: self.companyOrUniversity, bio: self.bio, privateMode: self.switchPrivateMode, arrSocialNetwork: self.arrSocialNetwork)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func calluPBSAPI(name: String, firstName: String, lastName: String, userName: String, companyOrUniversity: String, bio: String, privateMode: String, arrSocialNetwork: [Social_Network]) {
        
        var param: [String: Any] = [APIParamKey.kId: UserLocalData.UserID,
                                    APIParamKey.kName: name,
                                    APIParamKey.kLat: loginUser?.lat ?? 0.0,
                                    APIParamKey.kLng: loginUser?.lng ?? 0.0]
        
        if UserLocalData.userMode == "0" {
            
            self.url = BaseURL + APIName.kuPBS
            
            param[APIParamKey.kFlag] = kedit_profile
            param[APIParamKey.kFirstName] = firstName
            param[APIParamKey.kLastName] = lastName
            param[APIParamKey.kUsername] = userName
            param[APIParamKey.kBio] = bio
            param[APIParamKey.kPrivateMode] = privateMode
            
            // TODO: For Private Mode Checkbox Options
            // let nonOptionalArray1 = self.arrPrivateModeList.map { dictionary in
            //     [
            //         "name": dictionary.name ?? "abc",
            //         "selected": dictionary.selected ?? "0"
            //     ]
            // }
            // param[kprivate_mode_list] = nonOptionalArray1
            
            if loginUser?.profession_type == "1" {
                param[APIParamKey.kCompanyName] = companyOrUniversity
            } else {
                param[APIParamKey.kUniversity] = companyOrUniversity
            }
            
            param[APIParamKey.kSocialNetwork] = arrSocialNetwork.toJSON()
            
        }
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: self.url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                if UserLocalData.userMode == "0" { // Load Social Profile
                    
                    self.callGetInfoAPI(needToShowAlertForFailure: true, UserID: UserLocalData.UserID) { isSuccess, response in
                        self.hideCustomLoader()
                        
                        if isSuccess {
                            self.showAlertWithOKButton(message: msg, {
                                // Handle any other actions you need after tapping "OK" in the alert
                            }, {
                                self.navigationController?.popViewController(animated: true) // Dismiss the second view controller
                            })
                        }
                    }
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    // Function to remove child view controllers
    private func removeChildViewControllers() {
        self.generalInfoVC.removeFromParent()
        self.interestVC.removeFromParent()
        self.socialVC.removeFromParent()
        self.containerViewEditProfile.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func getUserProfileData() {
        
        if UserLocalData.userMode == "0" {
            
            let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
            
            if let dbUserModel = dbUserData.userData, dbUserData.isSuccess {
                
                self.socialDetail = dbUserModel
                
                self.firstName = self.socialDetail?.firstname ?? ""
                self.lastName = self.socialDetail?.lastname ?? ""
                self.userName = self.socialDetail?.username ?? ""
                self.bio = self.socialDetail?.bio ?? ""
                
                if self.socialDetail?.profession_type == "1" {
                    self.companyOrUniversity = self.socialDetail?.company_name ?? ""
                    
                } else if self.socialDetail?.profession_type == "2" {
                    self.companyOrUniversity = self.socialDetail?.university ?? ""
                }
                
                self.switchPrivateMode = self.socialDetail?.private_mode ?? ""
            }
            
            self.generalInfoVC.socialDetail = self.socialDetail
            
        }
        
        addChild(self.generalInfoVC)
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
extension EditProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = self.cvEditProfile.dequeueReusableCell(withReuseIdentifier: EditProfileCVCell.identifier, for: indexPath) as? EditProfileCVCell {
            cell.configureCell(IndexPath: indexPath.item, selectedIndex: currentSelectedIndex, title: self.arrCategory[indexPath.item])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView Delegate -
// ----------------------------------------------------------
extension EditProfileVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.currentSelectedIndex = indexPath.item
        
        // Remove existing child view controllers
        self.removeChildViewControllers()
        
        // Add the selected child view controller
        switch indexPath.item {
            case 0:
                addChild(self.generalInfoVC)
                self.generalInfoVC.view.frame = self.containerViewEditProfile.bounds
                self.containerViewEditProfile.addSubview(self.generalInfoVC.view)
                
                if UserLocalData.userMode == "0" { // Load Social Profile
                    
                    self.generalInfoVC.socialDetail = self.socialDetail
                    self.generalInfoVC.isUserChangeAnyData = self.isUserChangeAnyData
                    
                } else if UserLocalData.userMode == "1" { // Load Business Profile
                    
                    self.generalInfoVC.socialDetail = self.businessDetail
                }
                
            case 1:
                addChild(self.interestVC)
                self.interestVC.view.frame = self.containerViewEditProfile.bounds
                self.containerViewEditProfile.addSubview(self.interestVC.view)
                
            case 2:
                if loginUser != nil {
                    
                    if UserLocalData.userMode == "0" { // loginUser?.user_mode // Social
                        
                        if loginUser?.social_network != nil {
                            
                            self.arrSocialNetwork = loginUser?.social_network ?? [Social_Network]()
                            self.arrSocialNetworkList = self.arrSocialNetwork[self.currentSelectedIndex - 2].social_network_list ?? []
                        }
                        
                    } else if UserLocalData.userMode == "1" { // Business
                        
                        if loginUser?.business_network != nil {
                            
                            self.arrSocialNetwork = loginUser?.business_network ?? [Social_Network]()
                            self.arrSocialNetworkList = self.arrSocialNetwork[self.currentSelectedIndex - 2].social_network_list ?? []
                        }
                    }
                }
                
                addChild(self.socialVC)
                self.socialVC.view.frame = self.containerViewEditProfile.bounds
                self.containerViewEditProfile.addSubview(self.socialVC.view)
                self.socialVC.delegate = self
                
            default:
                if loginUser != nil {
                    
                    if UserLocalData.userMode == "0" { // loginUser?.user_mode // Social
                        
                        self.arrSocialNetwork = loginUser?.social_network ?? [Social_Network]()
                        self.arrSocialNetworkList = self.arrSocialNetwork[self.currentSelectedIndex - 2].social_network_list ?? []
                        
                    } else if UserLocalData.userMode == "1" { // Business
                        
                        self.arrSocialNetwork = loginUser?.business_network ?? [Social_Network]()
                        self.arrSocialNetworkList = self.arrSocialNetwork[self.currentSelectedIndex - 2].social_network_list ?? []
                    }
                }
                
                addChild(self.socialVC)
                self.socialVC.view.frame = self.containerViewEditProfile.bounds
                self.containerViewEditProfile.addSubview(self.socialVC.view)
        }
        
        self.cvEditProfile.reloadData()
    }
}

extension EditProfileVC: GeneralInfoVCDelegate {
    
    func updateSaveButtonState(isValidaData: Bool, firstName: String, lastName: String, userName: String, companyOrUniversity: String, bio: String, switchPrivateMode: String) {
        
        if isValidaData {
            
            // Update save button state when all conditions are met
            self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
            self.btnSave.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
            self.btnSave.isUserInteractionEnabled = true
            
            self.isUserChangeAnyData = true
            
        } else {
            
            // Reset save button state when any condition is not met
            self.btnSave.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnSave.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
            self.btnSave.isUserInteractionEnabled = false
            
            self.isUserChangeAnyData = false
        }
        
        print("firstName :: \(firstName)")
        print("lastName :: \(lastName)")
        print("userName :: \(userName)")
        
        print("companyOrUniversity :: \(companyOrUniversity)")
        print("Bio :: \(bio)")
        print("switchPrivateMode :: \(switchPrivateMode)")
        
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.companyOrUniversity = companyOrUniversity
        self.bio = bio
        self.switchPrivateMode = switchPrivateMode
    }
}

extension EditProfileVC: SocialVCDelegate {
    
    func getSocialNetworkOrder(arrSocialNetwork: [Social_Network]) {
        
        self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
        self.btnSave.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        self.btnSave.isUserInteractionEnabled = true
        
        self.isUserChangeAnyData = true
        
        //        print("---------------------------------------------------")
        //
        //        for index1 in 0 ... (arrSocialNetwork.count) - 1 {
        //
        //            for index2 in 0 ... (arrSocialNetwork[index1].social_network_list!.count) - 1 {
        //
        //                if arrSocialNetwork[index1].social_network_list![index2].value != nil && arrSocialNetwork[index1].social_network_list![index2].value != "" {
        //
        //                    print("social_name :: \(arrSocialNetwork[index1].social_network_list![index2].social_name ?? ""), social_app_order :: \(arrSocialNetwork[index1].social_network_list![index2].social_app_order ?? "")")
        //                }
        //            }
        //        }
        
        self.arrSocialNetwork = arrSocialNetwork
    }
}
