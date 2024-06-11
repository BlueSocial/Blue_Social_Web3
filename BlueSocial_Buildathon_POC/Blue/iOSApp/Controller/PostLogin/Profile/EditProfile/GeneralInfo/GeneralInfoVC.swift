//
//  GeneralInfoVC.swift
//  Blue
//
//  Created by Blue.

import UIKit

protocol GeneralInfoVCDelegate: AnyObject {
    func updateSaveButtonState(isValidaData: Bool, firstName: String, lastName: String, userName: String, companyOrUniversity: String, bio: String, switchPrivateMode: String)
}

class GeneralInfoVC: BaseVC {
    
    // ----------------------------------------------------------
    //                MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var generalInfoScrollView: UIScrollView!
    @IBOutlet weak var viewFirstName: CustomView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var lblErrorFirstName: UILabel!
    
    @IBOutlet weak var viewLastName: CustomView!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var lblErrorLastName: UILabel!
    
    @IBOutlet weak var viewUserName: CustomView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var lblErrorUserName: UILabel!
    
    @IBOutlet weak var switchPrivateMode: UISwitch!
    @IBOutlet weak var lblPrivateMode: UILabel!
    @IBOutlet weak var topLblPrivateMode: NSLayoutConstraint!
    @IBOutlet weak var cvGeneralInfo: UICollectionView!
    @IBOutlet weak var heightCVGeneralInfo: NSLayoutConstraint!
    @IBOutlet weak var topCVGeneralInfo: NSLayoutConstraint!
    
    @IBOutlet weak var switchMissedOppurtunities: UISwitch!
    @IBOutlet weak var lblMissedOppurtunities: UILabel!
    @IBOutlet weak var heightLblMissedOppurtunities: NSLayoutConstraint!
    @IBOutlet weak var topLblMissedOppurtunities: NSLayoutConstraint!
    @IBOutlet weak var cvGeneralInfo1: UICollectionView!
    @IBOutlet weak var heightCVGeneralInfo1: NSLayoutConstraint!
    @IBOutlet weak var topCVGeneralInfo1: NSLayoutConstraint!
    
    @IBOutlet weak var lblUniversity: UILabel!
    @IBOutlet weak var viewUniversity: UIView!
    @IBOutlet weak var txtUniversity: UITextField!
    
    @IBOutlet weak var padddingViewBio: CustomView!
    @IBOutlet weak var txtViewBio: UITextView!
    @IBOutlet weak var lblBioCount: UILabel!
    @IBOutlet weak var btnSave: CustomButton!
    @IBOutlet weak var heightBtnSave: NSLayoutConstraint!
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var imgViewStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    //private var arrGeneralType1 = [String]()
    private var isSelected: Bool = true
    private let spacing: CGFloat = 8
    internal var socialDetail: UserDetail?
    internal var businessDetail: UserDetail?
    private var arrPrivateModeList = [PrivateModeList]()
    private var arrBusinessPrivateModeList = [BusinessPrivateModeList]()
    //private var url: String = ""
    private var timer: Timer?
    private var isUsernameAvailable: Bool = false
    weak var delegate: GeneralInfoVCDelegate?
    private var txtBio = ""
    private var txtCompanyOrUniversity = ""
    private var isErrorFoundInFirstName: Bool = false
    private var isErrorFoundInLastName: Bool = false
    private var isErrorFoundInUserName: Bool = false
    
    // ----------------------------------------------------------
    //                MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // ----------------------------------------------------------
    //                MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnSave(_ sender: UIButton) {
        
    }
    
    @IBAction func onBtnStatus(_ sender: UIButton) {
        
    }
    
    @objc func switchPrivateModeValueChanged(_ sender: UISwitch) {
        
        self.updateSaveButtonState()
    }
    
    @objc func switchMissedOppurtunitiesValueChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            self.topLblMissedOppurtunities.constant = 12.0
            self.lblMissedOppurtunities.isHidden = false
            self.heightLblMissedOppurtunities.constant = 38.0
            
        } else {
            self.topLblMissedOppurtunities.constant = 0.0
            self.lblMissedOppurtunities.isHidden = true
            self.heightLblMissedOppurtunities.constant = 0.0
        }
    }
    
    @objc func onUsernameChange(_ textField: UITextField) {
        
        let updatedString = textField.text
        print("UpdatedString :: \(updatedString ?? "")")
        
        let textString = self.txtUserName.text!.replacingOccurrences(of: " ", with: "_")
        self.txtUserName.text = textString
        self.timer?.invalidate()
        
        if updatedString?.count ?? 0 > 3 {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
                
                let userName = self.txtUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if userName != self.socialDetail?.username {
                    self.callCheckUserNameExistAPI()
                }
            })
            
        } else {
            
            self.timer?.invalidate()
            
            self.isUsernameAvailable = false
            self.txtUserName.shake()
            
            self.lblErrorUserName.isHidden = false
            self.lblErrorUserName.text = ALERT_UserNameMin
            self.isErrorFoundInUserName = true
            
            self.viewUserName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
            self.viewUserName.layer.borderWidth = 1
            
            self.updateSaveButtonState()
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callCheckUserNameExistAPI() {
        
        let url = BaseURL + APIName.kCheckUsername
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kCheckUsername,
                                    APIParamKey.kUsername: self.txtUserName.text!.trime()]
        
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSucess, msg, response) in
            
            if isSucess {
                
                self.isUsernameAvailable = true
                self.isErrorFoundInUserName = false
                
                self.lblErrorUserName.isHidden = true
                self.lblErrorUserName.text = ""
                
                self.viewUserName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                self.viewUserName.layer.borderWidth = 1
                
            } else {
                
                self.isUsernameAvailable = false
                self.txtUserName.shake()
                self.isErrorFoundInUserName = true
                
                self.lblErrorUserName.isHidden = false
                self.lblErrorUserName.text = msg
                
                self.viewUserName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                self.viewUserName.layer.borderWidth = 1
            }
            
            self.updateSaveButtonState()
        }
    }
    
    // ----------------------------------------------------------
    //                MARK: - Function -
    // ----------------------------------------------------------
    private func setupUI() {
        
        self.btnSave.isHidden = true
        self.heightBtnSave.constant = 0.0
        
        self.heightCVGeneralInfo.constant = 0.0
        self.heightCVGeneralInfo1.constant = 0.0
        self.heightLblMissedOppurtunities.constant = 0.0
        
        // TODO: For Private Mode
        self.switchPrivateMode.addTarget(self, action: #selector(switchPrivateModeValueChanged(_:)), for: .valueChanged)
        
        self.switchMissedOppurtunities.addTarget(self, action: #selector(switchMissedOppurtunitiesValueChanged(_:)), for: .valueChanged)
        
        self.lblErrorFirstName.isHidden = true
        self.lblErrorLastName.isHidden = true
        self.lblErrorUserName.isHidden = true
        
        self.btnSave.isEnabled = true
        self.txtViewBio.delegate = self
        
        self.txtFirstName.delegate = self
        self.txtLastName.delegate = self
        self.txtUserName.delegate = self
        self.txtUniversity.delegate = self
        
        self.txtUserName.addTarget(self, action: #selector(onUsernameChange(_:)), for: .editingChanged)
        
        if UserLocalData.userMode == "0" {
            self.setUserSocialDetail()
            
        } else if UserLocalData.userMode == "1" {
            self.setUserBusinessDetail()
        }
    }
    
    private func setUserSocialDetail() {
        
        self.txtFirstName.text = self.socialDetail?.firstname
        self.txtLastName.text = self.socialDetail?.lastname
        self.txtUserName.text = self.socialDetail?.username ?? ""
        
        //self.txtViewBio.text = self.socialDetail?.bio
        //self.txtBio = self.socialDetail?.bio ?? ""
        
        if (self.socialDetail?.bio ?? "").count >= 500 {
            self.txtViewBio.text = String((self.socialDetail?.bio ?? "").prefix(500))
            self.txtBio = String((self.socialDetail?.bio ?? "").prefix(500))
            self.lblBioCount.text = "500/500"
            
        } else {
            // Handle the case where the string has less than 500 characters
            self.txtViewBio.text = self.socialDetail?.bio ?? ""
            self.txtBio = self.socialDetail?.bio ?? ""
            self.lblBioCount.text = "\(self.socialDetail?.bio?.count ?? 0)/500"
        }
        
        if self.socialDetail?.profession_type == "1" {
            
            self.lblUniversity.text = "Company"
            self.txtUniversity.text = self.socialDetail?.company_name ?? ""
            self.txtUniversity.isUserInteractionEnabled = true
            self.txtCompanyOrUniversity = self.socialDetail?.company_name ?? ""
            
        } else if self.socialDetail?.profession_type == "2" {
            
            self.lblUniversity.text = "University"
            self.txtUniversity.text = self.socialDetail?.university ?? ""
            self.txtUniversity.isUserInteractionEnabled = false
            self.txtCompanyOrUniversity = self.socialDetail?.university ?? ""
        }
        
        self.switchPrivateMode.isOn = (self.socialDetail?.private_mode == "1") ? true : false
        
        // TODO: For Private Mode Checkbox Options
        /*
         self.arrPrivateModeList = self.socialDetail?.private_mode_list ?? [PrivateModeList]()
         print(self.arrPrivateModeList)
         
         if self.socialDetail?.private_mode == "0" {
         
         self.switchPrivateMode.isOn = false
         self.topCVGeneralInfo.constant = 0.0
         self.cvGeneralInfo.isHidden = true
         self.heightCVGeneralInfo.constant = 0.0
         
         } else if self.socialDetail?.private_mode == "1" && self.socialDetail?.private_mode_list == nil {
         
         self.switchPrivateMode.isOn = true
         self.topCVGeneralInfo.constant = 0.0
         self.cvGeneralInfo.isHidden = true
         self.heightCVGeneralInfo.constant = 0.0
         
         } else {
         
         self.switchPrivateMode.isOn = true
         self.topCVGeneralInfo.constant = 16.0
         self.cvGeneralInfo.isHidden = false
         self.heightCVGeneralInfo.constant = 120.0
         }
         */
        return
    }
    
    private func setUserBusinessDetail() {
        
        if self.businessDetail?.business_firstName != nil && self.businessDetail?.business_firstName != "" {
            self.txtFirstName.text = self.businessDetail?.business_firstName
            
        } else {
            self.txtFirstName.text = self.socialDetail?.firstname
        }
        
        if self.businessDetail?.business_lastName != nil && self.businessDetail?.business_lastName != "" {
            self.txtLastName.text = self.businessDetail?.business_lastName
            
        } else {
            self.txtLastName.text = self.socialDetail?.lastname
        }
        
        self.txtUserName.text = self.businessDetail?.business_username ?? ""
        
        //self.txtViewBio.text = self.businessDetail?.business_bio ?? ""
        //self.txtBio = self.businessDetail?.bio ?? ""
        
        if (self.socialDetail?.bio ?? "").count >= 500 {
            self.txtViewBio.text = String((self.businessDetail?.business_bio ?? "").prefix(500))
            self.txtBio = String((self.businessDetail?.business_bio ?? "").prefix(500))
            self.lblBioCount.text = "500/500"
            
        } else {
            // Handle the case where the string has less than 500 characters
            self.txtViewBio.text = self.businessDetail?.business_bio ?? ""
            self.txtBio = self.businessDetail?.bio ?? ""
            self.lblBioCount.text = "\(self.businessDetail?.business_bio?.count ?? 0)/500"
        }
        
        if self.businessDetail?.profession_type == "1" {
            
            self.lblUniversity.text = "Company"
            self.txtUniversity.text = self.businessDetail?.business_company ?? ""
            self.txtUniversity.isUserInteractionEnabled = true
            self.txtCompanyOrUniversity = self.businessDetail?.company_name ?? ""
            
        } else if self.businessDetail?.profession_type == "2" {
            
            self.lblUniversity.text = "University"
            self.txtUniversity.text = self.businessDetail?.business_university ?? ""
            self.txtUniversity.isUserInteractionEnabled = false
            self.txtCompanyOrUniversity = self.businessDetail?.business_university ?? ""
        }
        
        self.switchPrivateMode.isOn = (self.businessDetail?.business_private_mode == "1") ? true : false
        
        // TODO: For Private Mode Checkbox Options
        /*
         self.arrBusinessPrivateModeList = self.businessDetail?.business_private_mode_list ?? [BusinessPrivateModeList]()
         
         if self.businessDetail?.business_private_mode == "0" {
         
         self.switchPrivateMode.isOn = false
         self.topCVGeneralInfo.constant = 0.0
         self.cvGeneralInfo.isHidden = true
         self.heightCVGeneralInfo.constant = 0.0
         
         } else if self.businessDetail?.business_private_mode == "1" && self.businessDetail?.business_private_mode_list == nil {
         
         self.switchPrivateMode.isOn = true
         self.topCVGeneralInfo.constant = 0.0
         self.cvGeneralInfo.isHidden = true
         self.heightCVGeneralInfo.constant = 0.0
         
         } else {
         
         self.switchPrivateMode.isOn = true
         self.topCVGeneralInfo.constant = 16.0
         self.cvGeneralInfo.isHidden = false
         self.heightCVGeneralInfo.constant = 120.0
         }
         */
        return
    }
    
    private func updateCharacterCount(_ count: Int? = nil) {
        
        let currentCount = count ?? self.txtViewBio.text.count
        self.lblBioCount.text = "\(currentCount)/500"
    }
    
    // FirstName | LastName | UserName
    @IBAction func textFieldEditingChanged(_ senders: [UITextField]) {
        self.updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        
        var isValidData = true
        
        let firstName = self.txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = self.txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let userName = self.txtUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
//        if firstName.isEmpty || lastName.isEmpty || userName.isEmpty || self.isErrorFoundInFirstName || self.isErrorFoundInLastName || self.isErrorFoundInUserName {
//            
//            isValidaData = false
//        }
        
        let companyOrUniversity = self.txtCompanyOrUniversity.trimmingCharacters(in: .whitespacesAndNewlines)
        let bio = self.txtBio.trimmingCharacters(in: .whitespacesAndNewlines)
        let switchPrivateMode = self.switchPrivateMode.isOn ? "1" : "0"
        
        if firstName.isEmpty || lastName.isEmpty || userName.isEmpty || self.isErrorFoundInFirstName || self.isErrorFoundInLastName || self.isErrorFoundInUserName || (firstName == self.socialDetail?.firstname && lastName == self.socialDetail?.lastname && userName == self.socialDetail?.username && switchPrivateMode == self.socialDetail?.private_mode && self.txtCompanyOrUniversity == self.socialDetail?.company_name && bio == self.socialDetail?.bio) || (firstName == self.businessDetail?.business_firstName && lastName == self.businessDetail?.business_lastName && userName == self.businessDetail?.business_username && switchPrivateMode == self.businessDetail?.business_private_mode && self.txtCompanyOrUniversity == self.businessDetail?.business_company && bio == self.businessDetail?.business_bio) {
            
            isValidData = false
        }
        
//        delegate?.updateSaveButtonState(isValidaData: isValidaData, firstName: firstName, lastName: lastName, userName: userName, companyOrUniversity: companyOrUniversity, bio: bio, switchPrivateMode: switchPrivateMode)
        
        delegate?.updateSaveButtonState(isValidaData: isValidData, firstName: firstName, lastName: lastName, userName: userName, companyOrUniversity: self.txtCompanyOrUniversity, bio: bio, switchPrivateMode: switchPrivateMode)
    }
}

// ----------------------------------------------------------
//                MARK: - UICollectionView DataSource -
// ----------------------------------------------------------
// TODO: For Private Mode Checkbox Options
//extension GeneralInfoVC: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        if collectionView == self.cvGeneralInfo {
//
//            if UserLocalData.userMode == "0" {
//                return self.arrPrivateModeList.count
//            } else {
//                return self.arrBusinessPrivateModeList.count
//            }
//
//        } else if collectionView == self.cvGeneralInfo1 {
//            return self.arrGeneralType1.count
//        }
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        if let cell = self.cvGeneralInfo.dequeueReusableCell(withReuseIdentifier: GeneralInfoCVCell.identifier, for: indexPath) as? GeneralInfoCVCell {
//
//            if UserLocalData.userMode == "0" {
//                cell.configureCell(name: self.arrPrivateModeList[indexPath.row].name ?? "")
//
//            } else {
//                cell.configureCell(name: self.arrBusinessPrivateModeList[indexPath.row].name ?? "")
//            }
//
//            cell.selectedItem = {
//                switch indexPath.row {
//
//                    case 0:
//                        if UserLocalData.userMode == "0" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrPrivateModeList[indexPath.row].selected = "0"
//                            }
//
//                        } else if UserLocalData.userMode == "1" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "0"
//                            }
//                        }
//                        break
//
//                    case 1:
//                        if UserLocalData.userMode == "0" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrPrivateModeList[indexPath.row].selected = "0"
//                            }
//
//                        } else if UserLocalData.userMode == "1" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "0"
//                            }
//                        }
//                        break
//
//                    case 2:
//                        if UserLocalData.userMode == "0" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrPrivateModeList[indexPath.row].selected = "0"
//                            }
//
//                        } else if UserLocalData.userMode == "1" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "0"
//                            }
//                        }
//                        break
//
//                    case 3:
//                        if UserLocalData.userMode == "0" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrPrivateModeList[indexPath.row].selected = "0"
//                            }
//
//                        } else if UserLocalData.userMode == "1" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "0"
//                            }
//                        }
//                        break
//
//                    case 4:
//                        if UserLocalData.userMode == "0" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrPrivateModeList[indexPath.row].selected = "0"
//                            }
//
//                        } else if UserLocalData.userMode == "1" {
//                            if cell.btnCheckbox.currentImage == UIImage(named: "ic_checkbox_fill") {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "1"
//                            } else {
//                                self.arrBusinessPrivateModeList[indexPath.row].selected = "0"
//                            }
//                        }
//                        break
//
//                    default:
//                        break
//                }
//            }
//
//            switch indexPath.row {
//
//                case 0:
//
//                    if UserLocalData.userMode == "0" {
//                        if self.arrPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//
//                    } else if UserLocalData.userMode == "1" {
//
//                        if self.arrBusinessPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//                    }
//                    break
//
//                case 1:
//                    if UserLocalData.userMode == "0" {
//                        if self.arrPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//
//                    } else if UserLocalData.userMode == "1" {
//
//                        if self.arrBusinessPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//                    }
//                    break
//
//                case 2:
//                    if UserLocalData.userMode == "0" {
//                        if self.arrPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//
//                    } else if UserLocalData.userMode == "1" {
//
//                        if self.arrBusinessPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//                    }
//                    break
//
//                case 3:
//                    if UserLocalData.userMode == "0" {
//                        if self.arrPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//
//                    } else if UserLocalData.userMode == "1" {
//
//                        if self.arrBusinessPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//                    }
//                    break
//
//                case 4:
//                    if UserLocalData.userMode == "0" {
//                        if self.arrPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//
//                    } else if UserLocalData.userMode == "1" {
//
//                        if self.arrBusinessPrivateModeList[indexPath.row].selected == "1" {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox_fill"), for: .normal)
//                        } else {
//                            cell.btnCheckbox.setImage(UIImage(named: "ic_checkbox"), for: .normal)
//                        }
//                    }
//                    break
//
//                default:
//                    break
//            }
//
//            return cell
//        }
//
//        if let cell = self.cvGeneralInfo1.dequeueReusableCell(withReuseIdentifier: GeneralInfoCVCell.identifier, for: indexPath) as? GeneralInfoCVCell {
//
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//}

// ----------------------------------------------------------
//                MARK: - UITextField Delegate -
// ----------------------------------------------------------
extension GeneralInfoVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtFirstName:
                if self.isErrorFoundInFirstName {
                    self.viewFirstName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewFirstName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                self.viewFirstName.layer.borderWidth = 1
                break
                
            case self.txtLastName:
                if self.isErrorFoundInLastName {
                    self.viewLastName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewLastName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                self.viewLastName.layer.borderWidth = 1
                break
                
            case self.txtUserName:
                if self.isErrorFoundInUserName {
                    self.viewUserName.layer.borderColor = UIColor.appRed_E13C3C().cgColor
                } else {
                    self.viewUserName.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                }
                self.viewUserName.layer.borderWidth = 1
                break
                
            case self.txtUniversity:
                self.viewUniversity.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                self.viewUniversity.layer.borderWidth = 1
                break
                
            default:
                break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtFirstName:
                self.viewFirstName.layer.borderWidth = 0
                break
                
            case self.txtLastName:
                self.viewLastName.layer.borderWidth = 0
                break
                
            case self.txtUserName:
                self.viewUserName.layer.borderWidth = 0
                break
                
            case self.txtUniversity:
                self.viewUniversity.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Define the allowed characters for Username
        let allowedCharacterSetForUserName = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.")
        
        // Allow only letters in FirstName and LastName
        let allowedCharacters = CharacterSet.letters
        
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let updatedStringCount = (textField.text ?? "").count + string.count - range.length
        
        switch textField {
                
            case self.txtFirstName:
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                if updatedStringCount < 2 {
                    self.isErrorFoundInFirstName = true
                    self.lblErrorFirstName.isHidden = false
                    self.lblErrorFirstName.text = alertFirstNameShouldContainMinTwoChar
                    self.viewFirstName.BordeColor = UIColor.appRed_E13C3C()
                    
                } else {
                    self.isErrorFoundInFirstName = false
                    self.lblErrorFirstName.isHidden = true
                    self.lblErrorFirstName.text = ""
                    self.viewFirstName.BordeColor = UIColor.appBlue_0066FF()
                }
                
                return updatedStringCount <= 20 // Allow only if the new length is 20 or less
                
            case self.txtLastName:
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                if updatedStringCount < 2 {
                    self.isErrorFoundInLastName = true
                    self.lblErrorLastName.isHidden = false
                    self.lblErrorLastName.text = alertLastNameShouldContainMinTwoChar
                    self.viewLastName.BordeColor = UIColor.appRed_E13C3C()
                    
                } else {
                    self.isErrorFoundInLastName = false
                    self.lblErrorLastName.isHidden = true
                    self.lblErrorLastName.text = ""
                    self.viewLastName.BordeColor = UIColor.appBlue_0066FF()
                }
                
                return updatedStringCount <= 20 // Allow only if the new length is 20 or less
                
            case self.txtUserName:
                // Check if the entered string contains only allowed characters
                let enteredCharacterSet = CharacterSet(charactersIn: string)
                return allowedCharacterSetForUserName.isSuperset(of: enteredCharacterSet)
                
            case self.txtUniversity:
                self.txtCompanyOrUniversity = updatedString ?? ""
                self.updateSaveButtonState()
                
            default:
                break
        }
        
        //        let firstName = self.txtFirstName.text ?? ""
        //        let lastName = self.txtLastName.text ?? ""
        //        let userName = self.txtUserName.text ?? ""
        //
        //        if firstName.isEmpty || lastName.isEmpty || userName.isEmpty {
        //
        //            self.btnSave.backgroundColor = UIColor.appGray_F2F3F4()
        //            self.btnSave.setTitleColor(UIColor.appGray_98A2B1(), for: .normal)
        //            self.btnSave.isEnabled = false
        //
        //        } else {
        //
        //            self.btnSave.backgroundColor = UIColor.appBlue_0066FF()
        //            self.btnSave.setTitleColor(UIColor.appWhite_FFFFFF(), for: .normal)
        //            self.btnSave.isEnabled = true
        //        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
                
            case self.txtFirstName:
                self.txtLastName.becomeFirstResponder()
                break
                
            case self.txtLastName:
                self.txtUserName.becomeFirstResponder()
                break
                
            case self.txtUserName:
                self.txtUniversity.becomeFirstResponder()
                break
                
            case self.txtUniversity:
                self.txtViewBio.becomeFirstResponder()
                break
                
            default:
                break
        }
        return true
    }
}

// ----------------------------------------------------------
//                MARK: - UITextView Delegate -
// ----------------------------------------------------------
extension GeneralInfoVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.padddingViewBio.layer.borderColor = UIColor.appBlue_0066FF().cgColor
        self.padddingViewBio.layer.borderWidth = 1.0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.padddingViewBio.layer.borderWidth = 0.0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let updatedString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let updatedStringCount = updatedString.count
        
        self.txtBio = updatedString
        self.updateSaveButtonState()
        
        let characterLimit = 500
        
        if updatedStringCount <= characterLimit {
            self.updateCharacterCount(updatedStringCount)
            return true
            
        } else {
            
            // If pasting, truncate the text to the character limit
            if range.length == 0 {
                let index = updatedString.index(updatedString.startIndex, offsetBy: characterLimit)
                textView.text = String(updatedString.prefix(upTo: index))
                self.updateCharacterCount(characterLimit)
            }
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateCharacterCount()
    }
}

// -------------------------------------------------------------
//                MARK: - UICollectionViewDelegateFlowLayout -
// -------------------------------------------------------------
// TODO: For Private Mode Checkbox Options
//extension GeneralInfoVC: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let spacing: CGFloat = 8.0 // Adjust this value based on your spacing needs
//
//        let availableWidth = collectionView.frame.width - (2 * spacing) // Subtract spacing and leading/trailing insets
//        let cellWidth = availableWidth / 2 // Display 2 items side by side
//        let cellHeight: CGFloat = 24 // Adjust this height as needed
//
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8.0
//    }
//}
