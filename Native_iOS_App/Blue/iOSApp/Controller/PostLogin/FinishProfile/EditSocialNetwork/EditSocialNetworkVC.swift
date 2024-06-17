//
//  EditSocialNetworkVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import IQKeyboardManagerSwift
import SKCountryPicker
import MobileCoreServices
import GooglePlaces
import MessageUI
import MapKit

protocol EditSocialNWDelegate: AnyObject {
    func updateBadgeCount()
}

protocol EditSocialNetworkDelegate: AnyObject {
    func editSNDismissed()
}

class EditSocialNetworkVC: BaseVC {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var contentView               : UIView!
    @IBOutlet weak var viewBlur                  : UIView!
    @IBOutlet weak var lblTitle                  : UILabel!
    @IBOutlet weak var imgSocialNetwork          : UIImageView!
    @IBOutlet weak var btnPreviewLink            : UIButton!
    @IBOutlet weak var heightBtnPreviewLink      : NSLayoutConstraint!
    @IBOutlet weak var topBtnPreviewLink         : NSLayoutConstraint!
    @IBOutlet weak var lblLinkTitle              : UILabel!
    @IBOutlet weak var viewLinkTitle             : UIView!
    @IBOutlet weak var txtLinkTitle              : UITextField!
    @IBOutlet weak var lblSocialNetworkUsername  : UILabel!
    @IBOutlet weak var viewSocialNetworkUsername : UIView!
    @IBOutlet weak var txtSocialNetworkUsername  : UITextField!
    @IBOutlet weak var lblSocialNetworkSampleLink: UILabel!
    @IBOutlet weak var viewCountryFlag_Code      : UIView!
    @IBOutlet weak var imgCountryFlag            : UIImageView!
    @IBOutlet weak var lblCountryCode            : UILabel!
    @IBOutlet weak var btnAddAnotherLink         : UIButton!
    @IBOutlet weak var imgPro                    : UIImageView!
    @IBOutlet weak var btnSaveLink               : UIButton!
    @IBOutlet weak var btnDelete                 : UIButton!
    @IBOutlet weak var scrollView                : UIScrollView!
    @IBOutlet weak var svSocialNWUserName        : UIStackView!
    
    // ----------------------------------------------------------
    //                MARK: - Property -
    // ----------------------------------------------------------
    private var swipeGesture: UISwipeGestureRecognizer?
    internal var objSocialNetworkList: Social_Network_List?
    internal var isFromFinishProfile: Bool = false
    internal var isFromLinkStoreAdd: Bool = false
    internal var isFromSocialVC: Bool = false
    private var timer: Timer?
    private var contentViewYPosition = 0.0
    private var keyboardContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var isSecondTimeDidLayoutSubviews: Bool = false
    weak var delegate: EditSocialNWDelegate?
    weak var editSocialNWDelegate: EditSocialNetworkDelegate?
    private var isAddAnotherLinkTapped: Bool = false
    private var phoneCountryNameCode = "us"
    internal var isFirstTimeTapped: Bool = false // To prompt alert for change social title
    let autocompleteController = GMSAutocompleteViewController()
    var latCoordinate = ""
    var longCoordinate = ""
    
    internal var isFromBusinessCardScan: Bool = false
    typealias SocialNetworkCompletionBlock = (Social_Network_List) -> Void
    private var socialNetworkCompletion: SocialNetworkCompletionBlock?
    
    // ----------------------------------------------------------
    //            MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnAddAnotherLink.isHidden = true
        self.imgPro.removeFromSuperview()
        
        IQKeyboardManager.shared.enable = false // Disable for this specific view controller
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if self.isFromFinishProfile { // MARK: To Hide Add Another Link Button
            
            self.imgPro.removeFromSuperview()
            self.btnAddAnotherLink.isHidden = true
            self.btnDelete.isHidden = true
        }
        
        if self.isFromLinkStoreAdd {
            
            self.imgPro.removeFromSuperview()
            self.btnAddAnotherLink.isHidden = true
            self.btnSaveLink.setTitle("Add link", for: .normal)
            self.btnDelete.isHidden = true
        }
        
        if isFromSocialVC { // MARK: To update sample link
            
            if (self.txtSocialNetworkUsername.text?.range(of: "http", options: .caseInsensitive) != nil) || (self.txtSocialNetworkUsername.text?.range(of: "https", options: .caseInsensitive) != nil) {
                // match
                self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: "", textUnit: self.objSocialNetworkList?.value ?? "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
                
            } else {
                // not match
                self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: (self.objSocialNetworkList?.social_help_input_type)!, textUnit: self.objSocialNetworkList?.value ?? "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
            }
        }
        
        self.addGestureRecognizerToDismissPopupView()
        
        self.setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        self.btnAddAnotherLink.isUserInteractionEnabled = true
        self.btnAddAnotherLink.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnAddAnotherLink.titleLabel?.textColor = UIColor.appBlack_031227()
        
        self.btnSaveLink.backgroundColor = UIColor.appGray_F2F3F4()
        self.btnSaveLink.titleLabel?.textColor = UIColor.appGray_98A2B1()
        self.btnSaveLink.isUserInteractionEnabled = false
        
        self.contentViewYPosition = self.contentView.frame.origin.y
        
        self.isSecondTimeDidLayoutSubviews = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true // Re-enable for other view controllers
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isSecondTimeDidLayoutSubviews {
            // Reset the frame to its original position
            self.contentView.frame.origin.y =  self.contentView.frame.origin.y - self.keyboardContentInsets.bottom
        }
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Action -
    // ----------------------------------------------------------
    @IBAction func onBtnBack(_ sender: UIButton) {
        
        self.dismiss(animated: true)
        self.editSocialNWDelegate?.editSNDismissed()
    }
    
    @IBAction func onBtnPreviewLink(_ sender: UIButton) {
        
        let type = (self.objSocialNetworkList?.social_name ?? "").lowercased().trime().replacingOccurrences(of: " ", with: "")
        
        switch type {
                
            case SocialNetworkCellType.Website.type(), SocialNetworkCellType.Calendly.type(), SocialNetworkCellType.CustomLink.type(), SocialNetworkCellType.GoogleMyBusiness.type(), SocialNetworkCellType.Linkedin.type(), SocialNetworkCellType.Slack.type():
                
                // TODO: Website, Calendly, CustomLink, GoogleMyBusiness, Linkedin, Slack
                
                if let value = self.txtSocialNetworkUsername.text, value.hasPrefix("http://") || value.hasPrefix("https://") {
                    
                    if let url = URL(string: self.txtSocialNetworkUsername.text ?? "") {
                        
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            self.showAlertWithOKButton(message: "Invalid URL")
                        }
                    }
                    
                } else {
                    self.showAlertWithOKButton(message: "Invalid URL")
                }
                break
                
            case SocialNetworkCellType.Resume.type():
                
                // TODO: Resume
                if let url = URL(string: self.txtSocialNetworkUsername.text ?? "") {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                }
                break
                
            default:
                
                // TODO: Instagram, Snapchat, Twitter, TikTok, Facebook, YouTube, Twitch, Pinterest, Apple Music, Spotify, SoundCloud, Venmo, Paypal, Cash app, Vimeo, Patreon, Apple Podcasts, Amazon, Etsy, Yelp, Discord, Telegram
                
                if let url = URL(string: self.lblSocialNetworkSampleLink.text ?? "") {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        self.showAlertWithOKButton(message: "Invalid URL")
                    }
                }
                break
        }
    }
    
    @IBAction func onBtnCountryCode(_ sender: UIButton) {
        
        let _ = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }
            
            self.manageKeyboard()
            
            if let lblTitleSring = self.lblTitle.text {
                
                if lblTitleSring.contains("Edit") {
                    
                    if self.phoneCountryNameCode != country.countryCode.lowercased() {
                        
                        self.btnSaveLink.isUserInteractionEnabled = true
                        self.btnSaveLink.backgroundColor = UIColor.appBlue_0066FF()
                        self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
                        
                    } else {
                        
                        self.btnSaveLink.isUserInteractionEnabled = false
                        self.btnSaveLink.backgroundColor = UIColor.appGray_F2F3F4()
                        self.btnSaveLink.titleLabel?.textColor = UIColor.appGray_98A2B1()
                    }
                }
            }
            
            self.imgCountryFlag.image = country.flag
            self.lblCountryCode.text = country.dialingCode
            self.phoneCountryNameCode = country.countryCode.lowercased()
        }
    }
    
    @IBAction func onBtnAddAnotherLink(_ sender: UIButton) {
        
        print("Add another link Link Tapped")
        self.btnSaveLink.setTitle("Add link", for: .normal)
        
        if loginUser?.subscriptionStatus == "1" { // User with subscription
            
            self.isAddAnotherLinkTapped = true
            
            self.lblTitle.text = "Add \(self.objSocialNetworkList?.social_name ?? "")".capitalized
            self.txtLinkTitle.text = "\(self.objSocialNetworkList?.social_name ?? "")".capitalized // i.e Instagram | we can customise it if having more than one same social n/w
            self.txtSocialNetworkUsername.text = "" // i.e. "" to add Username for social n/w like: mayur.mori1994
            
            self.btnAddAnotherLink.isUserInteractionEnabled = false
            self.btnAddAnotherLink.backgroundColor = UIColor.appGray_F2F3F4()
            self.btnAddAnotherLink.titleLabel?.textColor = UIColor.appBlack_031227()
            
        } else if loginUser?.subscriptionStatus == "0" { // User without subscription
            
        }
    }
    
    @IBAction func onBtnSaveLink(_ sender: UIButton) {
        
        print("Add|Save link Tapped")
        self.manageKeyboard()
        
        DispatchQueue.main.async {
            self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
        }
        
        if self.isFromBusinessCardScan {
            
            if self.objSocialNetworkList?.social_hint_type == "username" {
                
                self.objSocialNetworkList?.value = (self.objSocialNetworkList?.social_help_input_type ?? "") + (self.txtSocialNetworkUsername.text?.trime() ?? "")
                
            } else if self.objSocialNetworkList?.social_hint_type == "full_link" {
                
                if let value = self.txtSocialNetworkUsername.text, value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                    self.objSocialNetworkList?.value = value
                    
                } else {
                    self.showAlertWithOKButton(message: "Please Enter Valid Link", {
                        self.isSecondTimeDidLayoutSubviews = true
                    })
                    return
                }
            }
            
            //self.objSocialNetworkList?.value = self.txtSocialNetworkUsername.text ?? ""
            
            if let objSocialNetwork = self.objSocialNetworkList {
                self.socialNetworkCompletion?(objSocialNetwork)
            }
            self.dismiss(animated: true)
            
        } else {
            
            if self.isAddAnotherLinkTapped || self.isFromLinkStoreAdd { // Add
                
                if (self.txtLinkTitle.text?.trime().lowercased() == self.objSocialNetworkList?.social_name?.lowercased() || self.txtLinkTitle.text?.trime() == "Phone Number") && self.isFirstTimeTapped == false {
                    
                    if self.txtLinkTitle.text?.lowercased() == "email" {
                        
                        // Check if the email is valid
                        if self.txtSocialNetworkUsername.text!.isValidEmail() {
                            
                            // If valid, proceed with your existing logic
                            self.showAlertWith2Buttons(title: kAppName, message: kAlertChangeSocialTitle, btnOneName: kNo, btnTwoName: kYes) { btnAction in
                                
                                if btnAction == 1 { // NO
                                    self.callSaveLinkAPI(isEdit: false)
                                }
                                
                                if btnAction == 2 { // YES
                                    self.txtLinkTitle.becomeFirstResponder()
                                }
                            }
                            
                        } else {
                            
                            // If not valid, show a alert
                            self.view.makeToast(kAlertValidEmail)
                        }
                        
                    } else {
                        
                        self.showAlertWith2Buttons(title: kAppName, message: kAlertChangeSocialTitle, btnOneName: kNo, btnTwoName: kYes) { btnAction in
                            
                            if btnAction == 1 { // NO
                                self.callSaveLinkAPI(isEdit: false)
                            }
                            
                            if btnAction == 2 { // YES
                                self.txtLinkTitle.becomeFirstResponder()
                            }
                        }
                    }
                    
                } else { // self.isFirstTimeTapped
                    
                    if self.txtLinkTitle.text?.lowercased() == "email" {
                        
                        // Check if the email is valid
                        if self.txtSocialNetworkUsername.text!.isValidEmail() {
                            
                            // If valid, proceed with your existing logic
                            self.callSaveLinkAPI(isEdit: false)
                            
                        } else {
                            
                            // If not valid, show a alert
                            self.view.makeToast(kAlertValidEmail)
                        }
                        
                    } else {
                        self.callSaveLinkAPI(isEdit: false)
                    }
                }
                
            } else { // Edit
                
                if (self.txtLinkTitle.text?.lowercased() == self.objSocialNetworkList?.social_name?.lowercased() || self.txtLinkTitle.text?.trime() == "Phone Number") && self.isFirstTimeTapped == false {
                    
                    if self.txtLinkTitle.text?.lowercased() == "email" {
                        
                        // Check if the email is valid
                        if self.txtSocialNetworkUsername.text!.isValidEmail() {
                            
                            // If valid, proceed with your existing logic
                            self.showAlertWith2Buttons(title: kAppName, message: kAlertChangeSocialTitle, btnOneName: kNo, btnTwoName: kYes) { btnAction in
                                
                                if btnAction == 1 { // NO
                                    self.callSaveLinkAPI(isEdit: true)
                                }
                                
                                if btnAction == 2 { // YES
                                    self.txtLinkTitle.becomeFirstResponder()
                                }
                            }
                            
                        } else {
                            
                            // If not valid, show a alert
                            self.view.makeToast(kAlertValidEmail)
                        }
                        
                    } else {
                        
                        self.showAlertWith2Buttons(title: kAppName, message: kAlertChangeSocialTitle, btnOneName: kNo, btnTwoName: kYes) { btnAction in
                            
                            if btnAction == 1 { // NO
                                self.callSaveLinkAPI(isEdit: true)
                            }
                            
                            if btnAction == 2 { // YES
                                self.txtLinkTitle.becomeFirstResponder()
                            }
                        }
                    }
                    
                } else {
                    
                    if self.txtLinkTitle.text?.lowercased() == "email" {
                        
                        // Check if the email is valid
                        if self.txtSocialNetworkUsername.text!.isValidEmail() {
                            
                            // If valid, proceed with your existing logic
                            self.callSaveLinkAPI(isEdit: true)
                            
                        } else {
                            
                            // If not valid, show a alert
                            self.view.makeToast(kAlertValidEmail)
                        }
                        
                    } else {
                        self.callSaveLinkAPI(isEdit: true)
                    }
                }
            }
        }
    }
    
    @IBAction func onBtnDelete(_ sender: UIButton) {
        
        print("Delete Tapped")
        self.manageKeyboard()
        
        let title = self.objSocialNetworkList?.social_title ?? ""
        
        self.showAlertWith2ButtonswithColor(message: String(format: kAlertforRemovesocial, title), btnOneName: "Cancel", btnOneColor: UIColor.blue, btnTwoName: "Delete", btnTwoColor: UIColor.red, title: String(format: kAlertTitleforRemovesocial, title)) { (btn) in
            
            if btn == 2 {
                self.callRemoveLinkAPI()
            }
        }
    }
    
    @objc func textFieldResumeTapped() {
        
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG)
        
        if self.objSocialNetworkList?.social_name?.lowercased().replacingOccurrences(of: " ", with: "") == SocialNetworkCellType.File.type(){
            actionsheet.addAction(UIAlertAction(title: "video", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.chooseFileFunction(type: String(kUTTypeVideo))
            }))
            
            actionsheet.addAction(UIAlertAction(title: "Audio", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.chooseFileFunction(type: String(kUTTypeAudio))
            }))
        }
        
        if self.objSocialNetworkList?.social_name?.lowercased().replacingOccurrences(of: " ", with: "") == SocialNetworkCellType.Resume.type() {
            actionsheet.addAction(UIAlertAction(title: "PDF", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.chooseFileFunction(type: String(kUTTypePDF))
            }))
            
            actionsheet.addAction(UIAlertAction(title: "Document", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.chooseFileFunction(type: "", typedoc: true, typeExcel: false)
            }))
        }
        
        // TODO: Hide Image & Excel option From Choose resume actionsheet
        //        actionsheet.addAction(UIAlertAction(title: "Image", style: UIAlertAction.Style.default, handler: { (action) -> Void in
        //            self.chooseFileFunction(type: String(kUTTypeImage))
        //        }))
        //
        //        if self.objSocialNetworkList?.social_name?.lowercased().replacingOccurrences(of: " ", with: "") == SocialNetworkCellType.Resume.type() {
        //            actionsheet.addAction(UIAlertAction(title: "Excel", style: UIAlertAction.Style.default, handler: { (action) -> Void in
        //                self.chooseFileFunction(type: "", typedoc: false, typeExcel: true)
        //            }))
        //        }
        
        let actionButtonCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionButtonCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionsheet.popoverPresentationController?.sourceView = self.view
        actionsheet.addAction(actionButtonCancel)
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    @objc func textFieldAddressTapped() {
        
        self.autocompleteController.tableCellSeparatorColor = UIColor.gray
        self.autocompleteController.tableCellBackgroundColor = UIColor.white
        
        self.autocompleteController.delegate = self
        
        let nameField = GMSPlaceField.name.rawValue
        let placeIDField = GMSPlaceField.placeID.rawValue
        let coordinateField = GMSPlaceField.coordinate.rawValue
        let formattedAddressField = GMSPlaceField.formattedAddress.rawValue
        
        let rawValue = UInt64(nameField) | UInt64(placeIDField) | UInt64(coordinateField) | UInt64(formattedAddressField)
        let fields: GMSPlaceField = GMSPlaceField(rawValue: rawValue)
        
        self.autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        //filter.type = .noFilter
        self.autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        self.autocompleteController.modalPresentationStyle = .overFullScreen
        self.autocompleteController.modalTransitionStyle = .crossDissolve
        self.autocompleteController.view.backgroundColor = UIColor.appWhite_FFFFFF()
        
        present(self.autocompleteController, animated: true, completion: nil)
        
    }
    
    func callUploadResumeAPI(imgName: URL) {
        
        let url = BaseURL + APIName.kuProfileImg
        
        var content = "jpg"
        
        if (imgName.lastPathComponent).contains("pdf") {
            content = "pdf"
            
        } else if (imgName.lastPathComponent).contains("pages") {
            content = "pages"
            
        } else if (imgName.lastPathComponent).contains("docx") {
            content = "docx"
            
        } else if (imgName.lastPathComponent).contains("xlsx") {
            content = "xlsx"
            
        } else {
            content = "jpg"
        }
        
        let data = try! Data(contentsOf: imgName)
        
        let param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kUpload,
                                    APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kType: APIFlagValue.kResume,
                                    APIParamKey.kImg: data]
        
        self.showCustomLoader()
        APIManager.UploadResumeImg(postUrl: url, img: data, content, imgKey: APIParamKey.kImg, parameters: param) { (isSucess, msg, data) in
            self.hideCustomLoader()
            
            if isSucess {
                self.btnSaveLink.isUserInteractionEnabled = true
                self.btnSaveLink.backgroundColor = UIColor.appBlue_0066FF()
                self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
                
                DispatchQueue.main.async {
                    self.txtSocialNetworkUsername.text = data?.selfie?.resume
                }
                
            } else {
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    @objc func blurViewTap(_ sender: UITapGestureRecognizer?) {
        self.dismiss(animated: true)
        self.editSocialNWDelegate?.editSNDismissed()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // Get the keyboard size
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            self.keyboardContentInsets = contentInsets
            
            // Reset the frame to its original position
            self.contentView.frame.origin.y = self.contentViewYPosition
            
            // Adjust the frame of your UIView
            self.contentView.frame.origin.y =  self.contentView.frame.origin.y - contentInsets.bottom
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Reset the content inset when the keyboard is hidden
        self.contentView.frame.origin.y = self.contentViewYPosition // Reset the frame when the keyboard is hidden
    }
    
    @objc private func txtFieldEditingChanged(sender: UITextField) {
        
        // Reset the frame to its original position
        self.contentView.frame.origin.y = self.contentViewYPosition
        
        if sender == self.txtSocialNetworkUsername {
            
            if (sender.text?.range(of: "http", options: .caseInsensitive) != nil) || (sender.text?.range(of: "https", options: .caseInsensitive) != nil) {
                // match
                self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: "", textUnit: sender.text ?? "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
                
            } else {
                // not match
                self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: (self.objSocialNetworkList?.social_help_input_type)!, textUnit: sender.text ?? "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
            }
            
            if (self.objSocialNetworkList?.social_name?.lowercased().contains("email") ?? false) && sender.text != "" {
                
                self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: "", textUnit: sender.text ?? "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
            }
            
            let url = URL(string: self.txtSocialNetworkUsername.text!.replacingOccurrences(of: " ", with: ""))
            
            if url != nil {
                self.btnPreviewLink.isUserInteractionEnabled = true
                self.btnPreviewLink.alpha = 1
                
            } else {
                self.btnPreviewLink.isUserInteractionEnabled = false
                self.btnPreviewLink.alpha = 0.5
            }
            
            if url != nil && self.txtSocialNetworkUsername.text != self.objSocialNetworkList?.value {
                
                self.btnSaveLink.isUserInteractionEnabled = true
                self.btnSaveLink.backgroundColor = UIColor.appBlue_0066FF()
                self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
                
            } else {
                
                self.btnSaveLink.isUserInteractionEnabled = false
                self.btnSaveLink.backgroundColor = UIColor.appGray_F2F3F4()
                self.btnSaveLink.titleLabel?.textColor = UIColor.appGray_98A2B1()
            }
        }
        
        if sender == self.txtLinkTitle {
            
            if sender.text != "" && self.txtSocialNetworkUsername.text != "" && self.txtLinkTitle.text != self.objSocialNetworkList?.social_title {
                
                self.btnSaveLink.isUserInteractionEnabled = true
                self.btnSaveLink.backgroundColor = UIColor.appBlue_0066FF()
                self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
                
            } else {
                
                self.btnSaveLink.isUserInteractionEnabled = false
                self.btnSaveLink.backgroundColor = UIColor.appGray_F2F3F4()
                self.btnSaveLink.titleLabel?.textColor = UIColor.appGray_98A2B1()
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - API Calling -
    // ----------------------------------------------------------
    private func callSaveLinkAPI(isEdit: Bool) {
        
        let url = BaseURL + APIName.kSaveLink
        
        var param: [String: Any] = [APIParamKey.kFlag: APIFlagValue.kSaveLink,
                                    APIParamKey.kAppVersion: self.getAppVersion(),
                                    APIParamKey.kDeviceType: APIFlagValue.kiPhone,
                                    APIParamKey.kUserId: UserLocalData.UserID,
                                    APIParamKey.kType: UserLocalData.userMode,
                                    APIParamKey.kCategoryId: self.objSocialNetworkList?.categoryid ?? "",
                                    APIParamKey.kCategoryTypeId: self.objSocialNetworkList?.sid ?? "",
                                    APIParamKey.kTitle: self.txtLinkTitle.text?.trime() ?? ""]
        
        if self.objSocialNetworkList?.social_name?.lowercased() == "phone" || self.objSocialNetworkList?.social_name?.lowercased() == "whatsapp" {
            
            // Format the phone number for WhatsApp
            param[APIParamKey.kValue] = "\(self.phoneCountryNameCode)_\(self.lblCountryCode.text?.dropFirst() ?? "")_\(self.txtSocialNetworkUsername.text?.trime() ?? "")"
            
        } else if self.objSocialNetworkList?.social_hint_type == "full_link" || self.objSocialNetworkList?.social_hint_type == "username" {
            
            if self.objSocialNetworkList?.social_name?.lowercased() == "website" || self.objSocialNetworkList?.social_name?.lowercased() == "custom link" {
                
                param[APIParamKey.kValue] = self.txtSocialNetworkUsername.text?.trime()
                
            } else if self.objSocialNetworkList?.social_name?.lowercased() == "email" || self.objSocialNetworkList?.social_name?.lowercased() == "resume" || self.objSocialNetworkList?.social_name?.lowercased() == "zelle" {
                param[APIParamKey.kValue] = self.txtSocialNetworkUsername.text?.trime()
                
            } else if let value = self.txtSocialNetworkUsername.text, value.hasPrefix("http") || value.hasPrefix("https") {
                
                if self.txtSocialNetworkUsername.text == "https://" {
                    self.showAlertWithOKButton(message: "Please Enter Valid Link", {
                        self.isSecondTimeDidLayoutSubviews = true
                    })
                    return
                    
                } else if value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                    
                    if self.txtSocialNetworkUsername.text == self.objSocialNetworkList?.social_help_input_type {
                        self.showAlertWithOKButton(message: "Please Enter Valid Link", {
                            self.isSecondTimeDidLayoutSubviews = true
                        })
                        return
                        
                    } else {
                        param[APIParamKey.kValue] = value
                    }
                    
                } else {
                    self.showAlertWithOKButton(message: "Please Enter Valid URL", {
                        self.isSecondTimeDidLayoutSubviews = true
                    })
                    return
                }
                
            } else {
                
                if self.objSocialNetworkList?.social_hint_type == "full_link" {
                    
                    if let value = self.txtSocialNetworkUsername.text, value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                        param[APIParamKey.kValue] = value
                        
                    } else {
                        self.showAlertWithOKButton(message: "Please Enter Valid Link", {
                            self.isSecondTimeDidLayoutSubviews = true
                        })
                        return
                    }
                    
                } else {
                    param[APIParamKey.kValue] = (self.objSocialNetworkList?.social_help_input_type ?? "") + (self.txtSocialNetworkUsername.text?.trime() ?? "")
                }
            }
            
        } else {
            
            param[APIParamKey.kValue] = self.txtSocialNetworkUsername.text?.trime()
        }
        
        if !self.isFromLinkStoreAdd || isEdit {
            param[APIParamKey.kLinkId] = self.objSocialNetworkList?.user_link_id ?? ""
        }
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: param) { (isSuccess, msg, response) in
            
            if isSuccess, let objSaveNetwork = response?.saveNetwork {
                
                if UserLocalData.userMode == "0" { // Load Social Profile
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                    if let socialDetail = dbUserData.userData, dbUserData.isSuccess {
                        
                        if isEdit { // Edit
                            
                            if let socialNetwork = socialDetail.social_network {
                                
                                for (index, socialNetworkItem) in socialNetwork.enumerated() {
                                    
                                    if let socialNetworkList = socialNetworkItem.social_network_list {
                                        
                                        for (subIndex, obj) in socialNetworkList.enumerated() {
                                            
                                            if obj.user_link_id == self.objSocialNetworkList?.user_link_id {
                                                
                                                socialDetail.social_network?[index].social_network_list?[subIndex].social_title = self.txtLinkTitle.text?.trime() ?? ""
                                                
                                                if self.objSocialNetworkList?.social_name?.lowercased() == "phone" || self.objSocialNetworkList?.social_name?.lowercased() == "whatsapp" {
                                                    
                                                    // Format the phone number for WhatsApp
                                                    socialDetail.social_network?[index].social_network_list?[subIndex].value = "\(self.phoneCountryNameCode)_\(self.lblCountryCode.text?.dropFirst() ?? "")_\(self.txtSocialNetworkUsername.text?.trime() ?? "")"
                                                    
                                                } else if self.objSocialNetworkList?.social_hint_type == "full_link" || self.objSocialNetworkList?.social_hint_type == "username" {
                                                    
                                                    if self.objSocialNetworkList?.social_name?.lowercased() == "website" || self.objSocialNetworkList?.social_name?.lowercased() == "custom link" {
                                                        
                                                        socialDetail.social_network?[index].social_network_list?[subIndex].value = self.txtSocialNetworkUsername.text?.trime()
                                                        
                                                    } else if self.objSocialNetworkList?.social_name?.lowercased() == "email" || self.objSocialNetworkList?.social_name?.lowercased() == "resume" || self.objSocialNetworkList?.social_name?.lowercased() == "zelle" {
                                                        socialDetail.social_network?[index].social_network_list?[subIndex].value = self.txtSocialNetworkUsername.text?.trime()
                                                        
                                                    } else if let value = self.txtSocialNetworkUsername.text, value.hasPrefix("http") || value.hasPrefix("https") {
                                                        
                                                        if value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                                                            
                                                            if self.txtSocialNetworkUsername.text != self.objSocialNetworkList?.social_help_input_type {
                                                                socialDetail.social_network?[index].social_network_list?[subIndex].value = value
                                                            }
                                                        }
                                                        
                                                    } else {
                                                        
                                                        if self.objSocialNetworkList?.social_hint_type == "full_link" {
                                                            
                                                            if let value = self.txtSocialNetworkUsername.text, value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                                                                socialDetail.social_network?[index].social_network_list?[subIndex].value = value
                                                            }
                                                        } else {
                                                            socialDetail.social_network?[index].social_network_list?[subIndex].value = (self.objSocialNetworkList?.social_help_input_type ?? "") + (self.txtSocialNetworkUsername.text?.trime() ?? "")
                                                        }
                                                    }
                                                    
                                                } else {
                                                    
                                                    socialDetail.social_network?[index].social_network_list?[subIndex].value = self.txtSocialNetworkUsername.text?.trime()
                                                }
                                                
                                                self.setUserSocialInfoInDB(userID: UserLocalData.UserID, userJSON: socialDetail.toJSONString() ?? "")
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self.hideCustomLoader()
                            self.dismiss(animated: true)
                            self.editSocialNWDelegate?.editSNDismissed()
                            self.delegate?.updateBadgeCount()
                            
                        } else { // Add
                            
                            if let socialNetwork = socialDetail.social_network {
                                
                                for (index, socialNetworkItem) in socialNetwork.enumerated() {
                                    
                                    if let socialNetworkList = socialNetworkItem.social_network_list {
                                        
                                        for (subIndex, obj) in socialNetworkList.enumerated() {
                                            
                                            if socialNetworkItem.id == self.objSocialNetworkList?.categoryid {
                                                
                                                if socialNetworkItem.social_network_list?[subIndex].sid == self.objSocialNetworkList?.sid {
                                                    
                                                    self.objSocialNetworkList?.social_title = self.txtLinkTitle.text?.trime() ?? ""
                                                    
                                                    if self.objSocialNetworkList?.social_name?.lowercased() == "phone" || self.objSocialNetworkList?.social_name?.lowercased() == "whatsapp" {
                                                        
                                                        // Format the phone number for WhatsApp
                                                        self.objSocialNetworkList?.value = "\(self.phoneCountryNameCode)_\(self.lblCountryCode.text?.dropFirst() ?? "")_\(self.txtSocialNetworkUsername.text?.trime() ?? "")"
                                                        
                                                    } else if self.objSocialNetworkList?.social_hint_type == "full_link" || self.objSocialNetworkList?.social_hint_type == "username" {
                                                        
                                                        if self.objSocialNetworkList?.social_name?.lowercased() == "website" || self.objSocialNetworkList?.social_name?.lowercased() == "custom link" {
                                                            
                                                            self.objSocialNetworkList?.value = self.txtSocialNetworkUsername.text?.trime()
                                                            
                                                        } else if self.objSocialNetworkList?.social_name?.lowercased() == "email" || self.objSocialNetworkList?.social_name?.lowercased() == "resume" || self.objSocialNetworkList?.social_name?.lowercased() == "zelle" {
                                                            self.objSocialNetworkList?.value = self.txtSocialNetworkUsername.text?.trime()
                                                            
                                                        } else if let value = self.txtSocialNetworkUsername.text, value.hasPrefix("http") || value.hasPrefix("https") {
                                                            
                                                            if value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                                                                
                                                                if self.txtSocialNetworkUsername.text != self.objSocialNetworkList?.social_help_input_type {
                                                                    self.objSocialNetworkList?.value = value
                                                                }
                                                            }
                                                            
                                                        } else {
                                                            
                                                            if self.objSocialNetworkList?.social_hint_type == "full_link" {
                                                                
                                                                if let value = self.txtSocialNetworkUsername.text, value.hasPrefix(self.objSocialNetworkList?.social_help_input_type ?? "") {
                                                                    self.objSocialNetworkList?.value = value
                                                                }
                                                            } else {
                                                                self.objSocialNetworkList?.value = (self.objSocialNetworkList?.social_help_input_type ?? "") + (self.txtSocialNetworkUsername.text?.trime() ?? "")
                                                            }
                                                        }
                                                        
                                                    } else {
                                                        
                                                        self.objSocialNetworkList?.value = self.txtSocialNetworkUsername.text?.trime()
                                                    }
                                                    
                                                    self.objSocialNetworkList?.user_link_id = "\(objSaveNetwork.link_id ?? 0)"
                                                    
                                                    if self.objSocialNetworkList?.value != "" {
                                                        socialNetworkItem.social_network_list?.insert(self.objSocialNetworkList!, at: subIndex + 1)
                                                        
                                                    } else if self.objSocialNetworkList?.value == "" {
                                                        socialNetworkItem.social_network_list?[subIndex] = self.objSocialNetworkList!
                                                    }
                                                    
                                                    self.setUserSocialInfoInDB(userID: UserLocalData.UserID, userJSON: socialDetail.toJSONString() ?? "")
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self.hideCustomLoader()
                            self.dismiss(animated: true)
                            self.editSocialNWDelegate?.editSNDismissed()
                            self.delegate?.updateBadgeCount()
                        }
                    }
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    private func callRemoveLinkAPI() {
        
        let url = BaseURL + APIName.kRemoveLink
        
        let parameter: [String: Any] = [APIParamKey.kUserId: UserLocalData.UserID,
                                        APIParamKey.kType: UserLocalData.userMode,
                                        APIParamKey.kId: self.objSocialNetworkList?.user_link_id ?? ""]
        
        self.showCustomLoader()
        APIManager.postAPIRequest(postURL: url, parameters: parameter) { (isSuccess, msg, response) in
            
            if isSuccess {
                
                if UserLocalData.userMode == "0" { // Load Social Profile
                    
                    let dbUserData = DBManager.checkUserSocialInfoExist(userID: UserLocalData.UserID)
                    if let socialDetail = dbUserData.userData, dbUserData.isSuccess {
                        
                        // Delete
                        if let socialNetwork = socialDetail.social_network {
                            
                            for (index, socialNetworkItem) in socialNetwork.enumerated() {
                                
                                if let socialNetworkList = socialNetworkItem.social_network_list {
                                    
                                    for (subIndex, obj) in socialNetworkList.enumerated() {
                                        
                                        if obj.user_link_id == self.objSocialNetworkList?.user_link_id {
                                            
                                            // Replace the object at the specified index
                                            socialDetail.social_network?[index].social_network_list?[subIndex].value = ""
                                            socialDetail.social_network?[index].social_network_list?[subIndex].user_link_id = ""
                                            
                                            self.setUserSocialInfoInDB(userID: UserLocalData.UserID, userJSON: socialDetail.toJSONString() ?? "")
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.hideCustomLoader()
                        self.dismiss(animated: true)
                        self.editSocialNWDelegate?.editSNDismissed()
                        self.delegate?.updateBadgeCount()
                    }   
                }
                
            } else {
                
                self.hideCustomLoader()
                self.showAlertWithOKButton(message: msg)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Function -
    // ----------------------------------------------------------
    func saveSocialNetwork(myCompletion: @escaping SocialNetworkCompletionBlock) {
        self.socialNetworkCompletion = myCompletion
    }
    
    private func addGestureRecognizerToDismissPopupView() {
        
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(self.blurViewTap(_:)))
        self.viewBlur.addGestureRecognizer(blurViewTap)
    }
    
    private func manageKeyboard() {
        
        self.isSecondTimeDidLayoutSubviews = false
        self.txtLinkTitle.endEditing(true)
        self.txtSocialNetworkUsername.endEditing(true)
    }
    
    private func setUpUI() {
        
        self.txtLinkTitle.addTarget(self, action: #selector(self.txtFieldEditingChanged(sender:)), for: .editingChanged)
        self.txtSocialNetworkUsername.addTarget(self, action: #selector(self.txtFieldEditingChanged(sender:)), for: .editingChanged)
        
        if let obj = self.objSocialNetworkList {
            
            if !self.isFromLinkStoreAdd {
                
                self.lblTitle.text = "Edit \(obj.social_title ?? "")" // i.e. Edit Instagram
                
                if obj.social_name?.lowercased() == "phone" || obj.social_name?.lowercased() == "whatsapp" {
                    let component = obj.value?.components(separatedBy: "_")
                    
                    if component?.count ?? 1 >= 3 {
                        
                        self.imgCountryFlag.image = UIImage(named: component?[0].lowercased() ?? "")
                        self.phoneCountryNameCode = component?[0] ?? ""
                        self.lblCountryCode.text = "+" + (component?[1] ?? "")
                        self.txtSocialNetworkUsername.text = component?[2]
                        
                    } else if component?.count == 1 {
                        
                        self.imgCountryFlag.image = UIImage(named: "us")
                        self.phoneCountryNameCode = "us"
                        self.lblCountryCode.text = "+1"
                        self.txtSocialNetworkUsername.text = component?[0] ?? ""
                    }
                    
                } else {
                    self.txtSocialNetworkUsername.text = "\(obj.value ?? "")" // i.e. mayur.mori1994
                }
                
                if self.txtSocialNetworkUsername.text != nil {
                    self.btnPreviewLink.isUserInteractionEnabled = true
                    self.btnPreviewLink.alpha = 1
                    
                } else {
                    self.btnPreviewLink.isUserInteractionEnabled = false
                    self.btnPreviewLink.alpha = 0.5
                }
                
            } else {
                
                self.lblTitle.text = "Add \(obj.social_title ?? "")" // i.e. Add Instagram
                self.txtSocialNetworkUsername.text = "" // i.e. "" to add Username for social n/w like: mayur.mori1994
                
                self.btnPreviewLink.isUserInteractionEnabled = false
                self.btnPreviewLink.alpha = 0.5
            }
            
            if let url = URL(string: obj.social_icon ?? "") {
                self.imgSocialNetwork.af_setImage(withURL: url)
            }
            
            self.txtLinkTitle.text = "\(obj.social_title ?? "")".capitalized // i.e Instagram | we can customise it if having more than one same social n/w
            
            // MARK: - Keep commented code For Validation Purpose
            
            //self.lblSocialNetworkUsername.text = "\(obj.social_name ?? "") \(obj.social_hint_type ?? "")".capitalized // i.e. Instagram Username
            //self.lblSocialNetworkSampleLink.text = "\(obj.social_help_input_type ?? "")\(obj.value ?? "")" // i.e. https://www.instagram.com/mayur.mori1994
            
            // if self.objSocialNetworkList?.social_name?.lowercased().contains("slack") ?? false {
            //     self.lblSocialNetworkUsername.text = (self.objSocialNetworkList?.social_name?.capitalized ?? "") + " " + "Channel/Member-Id"
            //
            // } else if self.objSocialNetworkList?.social_name?.lowercased().contains("linkedin") ?? false {
            //     self.lblSocialNetworkUsername.text = "Linkedin link"
            //
            // } else if self.objSocialNetworkList?.social_name?.lowercased().contains("youtube") ?? false {
            //     self.lblSocialNetworkUsername.text = "YouTube Link"
            //
            // } else {
            //     self.lblSocialNetworkUsername.text = (self.objSocialNetworkList?.social_name?.capitalized ?? "") + " " + "Username"
            // }
            
            self.lblSocialNetworkUsername.text = self.objSocialNetworkList?.social_place_holder
            
            self.lblSocialNetworkSampleLink.setupAttributedTextOFLabelForThreeString(text: (self.objSocialNetworkList?.social_help_input_type)!, textUnit: "", textColor: UIColor.appGray_98A2B1(), textUnitColor: UIColor.appBlue_0066FF(), suffixString: "")
            
            if loginUser != nil {
                
                self.imgPro.isHidden = loginUser?.subscriptionStatus == "1" ? true : false
            }
            
            if obj.social_name?.lowercased() == "resume".lowercased() || obj.social_name?.lowercased() == "custom_files".lowercased() {
                
                // Add tap gesture recognizer to the text field
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldResumeTapped))
                self.txtSocialNetworkUsername.addGestureRecognizer(tapGesture)
                
            } else if obj.social_name?.lowercased() == "address".lowercased() {
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldAddressTapped))
                self.txtSocialNetworkUsername.addGestureRecognizer(tapGesture)
                
            } else if obj.social_name?.lowercased() == "phone" || obj.social_name?.lowercased() == "whatsapp" {
                
                self.viewCountryFlag_Code.isHidden = false
                self.txtSocialNetworkUsername.keyboardType = .numberPad
                self.lblSocialNetworkUsername.isHidden = true
                self.lblSocialNetworkSampleLink.isHidden = true
            }
        }
        
        let type = (self.objSocialNetworkList?.social_name ?? "").lowercased().trime().replacingOccurrences(of: " ", with: "")
        
        switch type {
                
            case SocialNetworkCellType.email.type(), SocialNetworkCellType.Phone.type(), SocialNetworkCellType.Whatsapp.type(), SocialNetworkCellType.Address.type(), SocialNetworkCellType.EthereumAddress.type(), SocialNetworkCellType.BitcoinWalletAddress.type(), SocialNetworkCellType.Zelle.type(), SocialNetworkCellType.Wechat.type(), SocialNetworkCellType.PokemonGo.type(), SocialNetworkCellType.Xbox.type(), SocialNetworkCellType.PlayStation.type():
                
                self.heightBtnPreviewLink.constant = 0.0
                self.topBtnPreviewLink.constant = 0.0
                self.btnPreviewLink.isHidden = true
                break
                
            case SocialNetworkCellType.Website.type(), SocialNetworkCellType.Calendly.type(), SocialNetworkCellType.CustomLink.type(), SocialNetworkCellType.GoogleMyBusiness.type(), SocialNetworkCellType.Linkedin.type(), SocialNetworkCellType.Slack.type():
                
                self.lblSocialNetworkSampleLink.text = "Paste full link, example https://"
                self.heightBtnPreviewLink.constant = 31.0
                self.topBtnPreviewLink.constant = 24.0
                self.btnPreviewLink.isHidden = false
                break
                
            default:
                
                self.heightBtnPreviewLink.constant = 31.0
                self.topBtnPreviewLink.constant = 24.0
                self.btnPreviewLink.isHidden = false
                break
        }
    }
    
    private func openMapForPlace(lat: String, long: String, placeName: String) {
        
        let lat1: NSString = lat as NSString
        let lng1: NSString = long as NSString
        
        let latitude: CLLocationDegrees = lat1.doubleValue
        let longitude: CLLocationDegrees = lng1.doubleValue
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }
}

//--------------------------------------------------------
//      MARK: - UITextFieldDelegate -
//--------------------------------------------------------
extension EditSocialNetworkVC : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField {
                
            case self.txtLinkTitle:
                self.viewLinkTitle.layer.borderWidth = 1
                self.viewLinkTitle.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                break
                
            default:
                break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtLinkTitle:
                self.viewLinkTitle.layer.borderWidth = 1
                self.viewLinkTitle.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                break
                
            case self.txtSocialNetworkUsername:
                self.viewSocialNetworkUsername.layer.borderWidth = 1
                self.viewSocialNetworkUsername.layer.borderColor = UIColor.appBlue_0066FF().cgColor
                break
                
            default:
                break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
                
            case self.txtLinkTitle:
                self.viewLinkTitle.layer.borderWidth = 0
                break
                
            case self.txtSocialNetworkUsername:
                self.viewSocialNetworkUsername.layer.borderWidth = 0
                break
                
            default:
                break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Combine the existing text with the replacement text
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        switch textField {
                
            case self.txtLinkTitle:
                let maxLength = 25
                return newText.count <= maxLength
                
            default:
                break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
                
            case self.txtLinkTitle:
                self.txtSocialNetworkUsername.becomeFirstResponder()
                break
                
            case self.txtSocialNetworkUsername:
                self.txtSocialNetworkUsername.resignFirstResponder()
                break
                
            default:
                break
        }
        return true
    }
}

extension EditSocialNetworkVC: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else { return }
        
        print("import result : \(myURL)")
        self.callUploadResumeAPI(imgName: myURL)
    }
    
    func chooseFileFunction(type: String = "", typedoc: Bool = false, typeExcel: Bool = false) {
        
        let doctype = type != "" ? [type] : typedoc ? ["org.openxmlformats.wordprocessingml.document","com.apple.iwork.pages.pages"] : ["org.openxmlformats.spreadsheetml.sheet","com.apple.iwork.pages.pages"]
        
        let importMenu = UIDocumentPickerViewController(documentTypes: doctype, in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
}

//---------------------------------------------------------------------
//          MARK: -  GMSAutocompleteViewControllerDelegate Methods -
//---------------------------------------------------------------------
extension EditSocialNetworkVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        dismiss(animated: true) {
            self.btnSaveLink.isUserInteractionEnabled = true
            self.btnSaveLink.backgroundColor = UIColor.appBlue_0066FF()
            self.btnSaveLink.titleLabel?.textColor = UIColor.appWhite_FFFFFF()
            let value = place.formattedAddress
            self.latCoordinate = "\(place.coordinate.latitude)"
            self.longCoordinate = "\(place.coordinate.longitude)"
            self.txtSocialNetworkUsername.text = value
            self.isSecondTimeDidLayoutSubviews = false
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditSocialNetworkVC: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setPreferredSendingEmailAddress(loginUser?.email ?? "")
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
        
        // Handle the result
        switch result {
            case .cancelled:
                // Handle cancellation
                // You can perform any action you want when the user cancels composing the email
                print("User cancelled composing the email")
            case .saved:
                // Handle saving
                print("Email saved as a draft")
            case .sent:
                // Handle sending
                print("Email sent successfully")
            case .failed:
                // Handle failure
                print("Email sending failed")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            @unknown default:
                fatalError("Unknown case")
        }
    }
}
