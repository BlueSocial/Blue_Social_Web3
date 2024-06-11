//
//  Global.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit
import CoreLocation
import Alamofire

protocol UpdateDate {
    func updateLastDownloadedDate(date: String)
}

extension NSMutableAttributedString {
    @discardableResult func setColor(_ color: UIColor, forText text: String) -> Self {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(.foregroundColor, value: color, range: range)
        }
        return self
    }
}

struct CustomContactList {
    
    var isSelected: Bool!
    var contactName: String!
    var contactNumber: String!
    var contactImage: UIImage!
    
    init(isSelected: Bool, contactName: String, contactNumber: String, contactImage: UIImage) {
        
        self.isSelected = isSelected
        self.contactName = contactName
        self.contactNumber = contactNumber
        self.contactImage = contactImage
    }
}

struct AppTheme {
    
    static var LeftBlue  = UIColor(red: 110.0/255.0, green: 218.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static var RightBlue = UIColor(red: 4.0/255.0, green: 134.0/255.0, blue: 253.0/255.0, alpha: 1.0)
    
    //    static var StartWhite  = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.24)
    //    static var EndWhite    = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.16)
}

struct Setting {
    
    var title: String?
    var settingOption = [SettingOption]()
}

struct SettingOption {
    
    var imgSetting: UIImage?
    var settingName: String?
}

struct Subscription {
    
    var imgSubscription: UIImage?
    var subscriptionTitle: String?
    var subscriptionDetail: String?
}

struct CalenderYear {
    
    var calenderYear: String = ""
    var isCalenderSelected: Bool = false
}

struct ProfieInsight {
    
    var insightTitle: String = ""
    var insightItemCount: Int = 0
    var isSelected: Bool = false
}

struct SetChartData {
    
    var value: String?
    var xAxisValue: String?
}

struct SocialNetworkLinksInsight {
    
    var title: String = ""
    var isExpanded: Bool = false
    var items: [String] = [""]
    var socialStepCount = [""]
}

struct SwitchUserProfile {
    
    var imageURL: String
    var firstName: String
    var lastName: String
    var userName: String
    var userID: String
    var isCheckMark: Bool
}

class Position: NSObject {
    
    var tag = 0
    var xPosition = 0
    var yPosition = 0
    var isReserved = false
    var center = CGPoint()
}

class Bubble: NSObject {
    
    var tag = 0
    var uuid: String!
    var major: String!
    var minor: String!
}

class ImageCache {
    
    static let shared = NSCache<NSString, UIImage>()
    
    func getImage(from url: URL, completion: @escaping ((UIImage?, Error?) -> (Void))) {
        
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            //print("Image from cache")
            completion(cachedImage, nil)
            
        } else {
            
            Alamofire.request(url, method: .get).responseImage { response in
                
                if let data = response.result.value {
                    ImageCache.shared.setObject(data, forKey: url.absoluteString as NSString)
                    completion(data, nil)
                }
            }
        }
    }
}

//----------------------------------------------------------------------------------------------------
// MARK: - USED -
//----------------------------------------------------------------------------------------------------
var loginUser                       : UserDetail? // currentLogedInUser
var arrAccount                      : [[String: Any]] = []
var pushNotificationToken           = ""
let appDelegate                     = UIApplication.shared.delegate as! AppDelegate
let kAppName                        = Bundle.main.infoDictionary!["CFBundleName"] as! String
let kOnesignalAppID                 = "db2370c0-9cbb-4a69-a598-cca8de557c1a"
var userDef                         = UserDefaults.standard
var isInternetAvailable             = false
let kNearbyMSGAPIKey                = "AIzaSyD6loib6XhVOc8zH2VwnwixligjPLOYlvo"
var oneSignalLaunchOption           : [UIApplication.LaunchOptionsKey: Any]!
var isUsernameAvailable             = true
let kYes                            = "Yes"
let kNo                             = "No"
let kregister                       = "register"
let kSuccess                        = "Success"
let kchange_password                = "change_password"
let kedit_profile                   = "edit_profile"
let customLoaderGIF                 = "Blue-Society-Logo-2"

//getAppVersionAndBuildNumber | getAppVersion - BaseVC
let getCFBundleVersion = "CFBundleVersion"
let getCFBundleShortVersionString = "CFBundleShortVersionString"

let kALERT_MaxAccount = "Maximum 4 accounts you can add."
let kALERT_AppVersion = "We’re continuously making changes to our platform to provide you with a better experience."
let kALERT_Update = "Update App"
let kOk = "OK"
let kTurnOnBluetooth = "Please 'turn on' Bluetooth to scan nearest devices"
let kTerms = "Terms"
let kPrivacy_Policy = "Privacy Policy."
let kSelect_photo_from_gallery = "Choose photo"
let kCapture_photo_from_camera = "Take photo"
let kCancel = "Cancel"
let kuuidString = "90cc74b7-56d8-4e4d-8232-05e5b934ab0f"//"e2c56db5dffb48d2b060d0f5a71096e0000b000c"//"70f7be4ba2bf4794aa13b6b959c1b64200030004"
//"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
let kBeSocial = "Find out who and introduce yourself. #BeSocial"
let kNFCError = "Update tag failed. Please try again."
let kNFCSuccess = "Profile written to the NFC tag successfully!"
let kNFCAlert = "Your contact card is now activated with this NFC chip. Go share your contact now."
let kPlease_enter_new_password = "Please enter your new password"
let alertFirstNameShouldContainMinTwoChar = "First name should contain minimum 2 character"
let alertLastNameShouldContainMinTwoChar = "Last name should contain minimum 2 character"
let alertInvalidEmail = "Invalid email"
let alertInvalidPhoneNumber = "Phone Number must be at least 7 digits"
let alertSelectStudentNetwork = "Please select a student network to register with this email"
let alertEnterEmailWithEduDomain = "Please enter your .edu email associated with your school"
let alertNewAndConfirmPasswordDoNotMatch = "New password and confirm password do not match"
let kActivatePRofile = "Hold the Blue Smart Card on the upper back of your phone to activate profile."
let kNFCSupport = "Your device does not support NFC"
let kUpdateV13 = "Please update your iOS version 13.0 or more to use this feature."
let kAlertforRemovesocial = "This will delete %@ from your profile."
let kAlertTitleforRemovesocial = "Remove %@?"
let kAlertValidEmail = "Please enter valid email"
let kAlertChangeSocialTitle = "Would you like to change the Social Title?"
let kPlease_connect_Internet = "Please connect Internet"
let kViewProfile = "Hold the Blue Smart Card on the upper back of your phone to view profile."
let kResendEmailSuccess = "Please check your email inbox. The email has been sent successfully"
let ALERT_UserNameMin = "Username should be minimum of 4 characters"
let kSwitchAccount = "Are you sure you want to switch account?"
let kLeaveWithoutSave = "Are you sure you want to exit without saving changes?"
let kALERT_CANCEL = "CANCEL"
let kALERT_EXIT = "EXIT"
let kUpgradeToBlueProForAddingMoreSocialNetwork = "You can only add one of each link. To add more than one upgrade to Blue Pro."
let kALERT_Title = "Blue"
let kALERT_Title_Blue_Pro = "Blue Pro"
let kALERT_AddToWidget = "Go to Home Screen & Long tap to add widget"
let kALERT_SomethingWentWrong = "Something went wrong, please try again!"
let kSave_error = "Save error"
let kSavedSimple = "Saved"
let kYour_QR_code_saved = "Your QR code has been saved to your photos."
let kyou_sure_logout = "Are you sure you want to logout?"
let kPlease_enter_valid_email = "Please enter valid email"
let kPlease_enter_valid_PhoneNumber = "Please enter valid phone number"
let kPlease_enter_OTP = "Please enter OTP"
let ALERT_Invalid_OTP = "Invalid OTP"
let kPlease_enter_Retype_Password = "Please enter retype password"
let kPasswords_on_both_fields = "Please insert your new passwords on both fields."
let ALERT_EmailAlreadyRegistered = "This email is already registered"
let ALERT_PleaseEnterNewEmail = "Please enter new email"

//----------------------------------------------------------------------------------------------------
// MARK: - NOT USED -
//----------------------------------------------------------------------------------------------------
//  let kPublishData                    = "publishData"
//  let kIsAgree                        = "agree"
//  let kMobileRegister                 = "MobileRegister"
//  let kDescription                    = "description"
//  let kTooltipQRCode                  = "tooltipQRCode"
//  let kDynamicLink                    = "DynamicLink"
//  let kDynamicLinkURL                 = "DynamicLinkURL"
//  let shouldShowTourScreen            = "ShouldShowTourScreen"
//  var linkcameat                      = ""
//  let kSendGridURL                    = "https://api.sendgrid.com/v3/mail/send"
//  let kSendGridContectURL             = "https://api.sendgrid.com/v3/marketing/contacts"
//  let kRefCodeFlag                    = "ref_code"
//  let kRefAlert                       = "Pleace enter reference code."
//  let kImageName                      = "ImageName"
//  let kDescriptions                   = "Description"
//  let kgender                         = "gender"
//  let kgenders                        = "genders"
//  let kdob                            = "dob"
//  let kbusiness_title                 = "business_title"
//  let kbusiness_link                  = "business_link"
//  let kbusiness_private_mode_list     = "business_private_mode_list"
//  let kprofile_bg                     = "profile_bg"
//  let kuBioOnly                       = "uBioOnly"
//  let kprivate_mode_list              = "private_mode_list"
//  let kmissed_oppurtunities           = "missed_oppurtunities"
//  let kcuSocialNetworks               = "cuSocialNetworks"
//  let kuser_social                    = "user_social"
//  let kinstagram                      = "instagram"
//  let ksnapchat                       = "snapchat"
//  let ktwitter                        = "twitter"
//  let kfacebook                       = "facebook"
//  let klinkedin                       = "linkedin"
//  let kvenmo                          = "venmo"
//  let kyoutube                        = "youtube"
//  let kpinterest                      = "pinterest"
//  let kwhatsapp                       = "whatsapp"
//  let kapplemusic                     = "applemusic"
//  let kspotify                        = "spotify"
//  let klink                           = "link"
//  let kphone                          = "phone"
//  let kpaypal                         = "paypal"
//  let ksoundcloud                     = "soundcloud"
//  let ks_email                        = "s_email"
//  let ktidal                          = "tidal"
//  let ktiktok                         = "tiktok"
//  let kcashapp                        = "cashapp"
//  let ktwitch                         = "twitch"
//  let kpatreon                        = "patreon"
//  let kamazon                         = "amazon"
//  let kapplepodcasts                  = "applepodcasts"
//  let kzelle                          = "zelle"
//  let ktelegram                       = "telegram"
//  let kslack                          = "slack"
//  let kdiscord                        = "discord"
//  let kyelp                           = "yelp"
//  let ketsy                           = "etsy"
//  let ktumblr                         = "tumblr"
//  let kvimeo                          = "vimeo"
//  let khouseparty                     = "houseparty"
//  let kcalendly                       = "calendly"
//  let kwechat                         = "wechat"
//  let kordering                       = "ordering"
//  let krowisExpanded                  = "rowisExpanded"
//  let ksocial_category_title          =  "social_category_title"
//  let kseq_order                      = "seq_order"
//  let ksocial_newtork_list            = "social_newtork_list"
//  let kSocial_networkExpand           = "Social_networkExpand"
//  let ksocial_PhoneNumber             = "Phone Number"
//  let ksocial_networks                = "social networks"
//  let ksocial_CustomLinks             = "Custom Links"
//  let kref_userid                     = "ref_userid"
//  let ksendOtpEmail                   = "sendOtpEmail"
//  let kuserAffiliateLink              = "userAffiliateLink"
//  let khas_affiliate                  = "has_affiliate"
//  let kbluetooth_mode                 = "bluetooth_mode"
//  let kHttps                          = "https://"
//  let kPastfulllink                   = "Paste full link, example https://"
//  let kPasteId                        = "Paste ID"
//  let kto                             = "to"
//  let kfrom                           = "from"
//  let kcontent                        = "content"
//  let ktxtPlaceHolder                 = "txtPlaceHolder"
//  let ktxtData                        = "txtData"
//  let kimgname                        = "imgname"
//  let kupdate_grid                    = "update_grid"
//  let kis_list_grid                   = "is_list_grid"
//  let kmultipleLogin                  = "multipleLogin"
//  let kclicked_chart                  = "clicked_chart"
//  let ksocialid                       = "socialid"
//  let Kchart_type                     = "chart_type"
//  let kstart_date                     = "start_date"
//  let kend_date                       = "end_date"
//  let kcurrent_year                   = "current_year"
//  let kday                            = "day"
//  var nearbyMSG                       = NearbyMessages()
//  var kSetImage                       = "SetImage"

//  let kAccepted                                       = "Accepted"
//  let kDeclined                                       = "Declined"
//  let kToolTip_QRMessage                              = "Tap to share profile to \n phones without NFC"
//  let kToolTip_MultiLogin                             = "Switch profiles by tapping here"
//  let kChange_Profile_Photo                           = "Change Profile Photo"
//  let kNearbyMSGBlEOnOof                              = "Nearby works better if Bluetooth is turned on"
//  let kAboutDesc                                      = "We believe that reinventing the name tag represents our greatest opportunity to build a more socially connected world. \n\nBuilding a world of friends by amplifying social networking and making it easy form users to form authentic connections with others around them on Blue. Encouraging more human interactions through in-person social interactions."
//  let kaboutTerms                                     = "About our Terms and Privacy Policy."
//  let kPlease_enter_your_old_password                 = "Please enter your old password"
//  let kPlease_enter_ConfirmPassword                   = "Please enter confirm password"
//  let kPassword_not_match                             = "Password not match"
//  let alertCurrentAndNewPasswordShouldNotSame         = "For security reasons, you are required to change your password. You can no longer use your old password."
//  let ALERT_BLANK_EVENT_COVERIMAGE                    = "Please add a event cover photo"
//  let ALERT_BLANK_EVENT_TITLE                         = "Please enter event title"
//  let ALERT_BLANK_EVENT_DESCRIPTION                   = "Please enter event description"
//  let ALERT_BLANK_EVENT_LOCATION                      = "Please enter event location"
//  let ALERT_BLANK_EVENT_STARTDATE                     = "Please enter event start date"
//  let ALERT_BLANK_EVENT_ENDDATE                       = "Please enter event end date"
//  let kAlertUsername                                  = "Please enter username."
//  let kAlertUrl                                       = "Please enter url."
//  let kAlertValiadUrl                                 = "Please enter valiad url."
//  let kAlertSocialTitle                               = "Please enter title."
//  let kAlertphonenumber                               = "Please enter phone number."
//  let kAlertSocialUsername                            = "Please enter %@."
//  let kAlertSocialFile                                = "Please select file."
//  let STORY_ID_CreateEventVC                          = "CreateEventVC"
//  let STORY_ID_EventDetailVC                          = "EventDetailVC"
//  let STORY_ID_MyEventListViewVC                      = "MyEventListViewVC"
//  let STORY_ID_ExportVC                               = "ExportVC"
//  let STORY_ID_EditButtonActionVC                     = "EditButtonActionVC"
//  let kHistoryInfo                                    = "We sent an email to the email address on file for your account. When you receive the email, click the link to download your account leads into a CSV file."
//  let kNoHistoryFound                                 = "When you cross paths with someone or exchange profiles, their contact cards will appear here."
//  let ALERT_RefCode                                   = "Pleace enter reference code."
//  let ALERT_InvalidRefCode                            = "Reference code not valid."
//  let ALERT_NoteTitle                                 = "Please enter note title"
//  let ALERT_NoteDescription                           = "Please enter note description"
//  let kMenuTitle                                      = "MenuTitle"
//  let kMenuImage                                      = "MenuImage"
//  let kMenuList                                       = "MenuImage"
//  let kInviteSuccess                                  =  "You invited %@ to the Blue network. Now go Be Social!"
//  let kPlease_select_the_profile_picture              = "Please add a profile photo"
//  let kPlease_enter_full_name                         = "Please enter full name"
//  let kPlease_enter_user_name                         = "Please enter user name"
//  let ALERT_FirstName                                 = "Please enter first name"
//  let ALERT_LastName                                  = "Please enter last name"
//  let ALERT_ConfirmPassword                           = "Please enter confirm password"
//  let ALERT_Passowrd_NotMatch                         = "The passwords are not matching. Please try again." // Password and Confirm Password not matched"
//  let ALERT_Passowrd_MinLength                        = "Please choose a password with at least 8 characters" // Password and Confirm Password not matched"
//  let ALERT_Passowrd_MaxLength                        = "Please choose a password up to 20 characters"
//  let kPlease_enter_ButtonTitle                       = "Please enter button title"
//  let kPlease_enter_WebSiteUrl                        = "Please enter website URL"
//  let kPlease_enter_valiaduser_name                   = "Please enter valiad user name"
//  let ALERT_BusinessFirstName                         = "Please enter first name in business profile"
//  let ALERT_BusinessLastName                          = "Please enter last name in business profile"
//  let kPlease_Business_user_name                      = "Please enter valid user name in business profile"
//  let kPleaseEnterFirstNameLastName                   = "Please enter first name and last name"
//  let kPleaseEnterBusinessOrCompanyName               = "Please enter business or company name"
//  let kPleaseEnterAddress                             = "Please enter address"
//  let kPlease_enter_password                          = "Please enter password"
//  let kAgree                                          = "Please agree for Terms & Conditions & Privacy Policy"
//  let kSharedText                                     = "Hey, business cards are a thing of the past. Check out my new Social Card. You can add my social networks and contact information directly into your contacts. Save the trees!"
//  let kyou_sure_deactivate_profile                    = "Are you sure you want to deactivate?"
//  let kyou_sure_delete_profile                        = "Deleting your profile will remove all of your data."
//  let kPlease_enter_email                             = "Please enter email"
//  let kPlease_enter_mobile_number                     = "Please enter a mobile number"
//  let kSaved                                          = "Saved!"
//  let ktoolTipMSG                                     = "Long press to switch the user"
//  let kNetworkMessage                                 = "Be social with people you cross paths with in real life. When turned off, you’re hidden."
//  let kPaste_WeChat_ID                                = "Paste WeChat Id"
//  let kPaste_full_link_here                           = "Paste full link here."
//  let kAffiliateMSG                                   = "Get Paid Monthly by Referring Friends!\n\nIf you love the Blue Smart Card, tell your friends and receive 15% commission!\n\nWe know you're a social person, so why not get paid to be social? 🙂\n\nOnce you sign up you will get a custom affiliate link that you can share to start earning affiliate commissions with, as well as access to custom affiliate resources and live progress monitoring as your affiliate commissions roll in."
//  let kGetStarted                                     = "Get Started"
//  let kPlease_enter_name                              = "Please enter name"
//  let kPlease_enter_firstname                         = "Please enter first name"
//  let kPlease_enter_lastname                          = "Please enter last name"
//  let kPlease_enter_username                          = "Please enter username"
//  let kPlease_select_birthdate                        = "Please select birthdate"
//  let kPlease_select_gender                           = "Please select gender"
//  let kPlease_UserNameExist                           = "Username already exist"
//  let kCustomFile_Message                             = "Add a custom field with a photo, title field, and custom link."
//  let kPleaseEnterSocialBio                           = "Please enter social bio"
//  let ALERT_UserNameMix                               = "Username should be maximum of 20 characters"
//  let ALERT_CharMin                                   = "%@ should be minimum of 4 characters"
//  let ALERT_CharMix                                   = "%@ should be maximum of 50 characters"
//  let ALERT_UserSubscription                          = "Would you like to purchase BluePlus features?"
//  let ALERT_MaxNumSocialNetwork                       = "Maximum 5 same social networks you can add."
//  let ALERT_BioMessage                                = "Bio data should be allow upto 150 characters"
//  let ALERT_BusinessUserNameMin                       = "Business Username should be minimum of 4 characters"
//  let ALERT_BusinessUserNameMix                       = "Business Username should be maximum of 20 characters"
//  let kPlease_BusinessUserNameExist                   = "Business Username already exist"
//  let kPlease_enter_your_mobile_number                = "Please enter your mobile number"
//  let kALERT_OpenApp                                  = "Open Profile"
//  let kALERT_OpenBrowser                              = "Open in Browser"
//  let kALERT_FoundURL                                 = "Found URL: "
//  let kALERT_No                                       = "No"
//  let kALERT_Yes                                      = "Yes"

//struct Constants {
//    
//    struct UserDefault {
//        
//        static let autoUpdate                       = "AutoUpdate"
//        static let debugLog                         = "DebugLog"
//        static let loginInfo                        = "LoggedIn"
//        static let FirmwareURL                      = "FirmwareFile"
//        static let FirmwareLocalFileVersion         = "FirmwareLocalFileVerson"
//        static let AuthenticateClient               = "AuthenticateClient"
//        static let TempToken                        = "TempToken"
//        static let SitStandValue                    = "SitStandValue"
//        static let SitLastUpdated                   = "SitLastUpdated"
//        static let SitLastPresent                   = "SitLastPresent"
//        static let BLENotify                        = "BLENotify"
//    }
//}

//struct ProfileInfo {
//    
//    var firstName               : String?
//    var lastName                : String?
//    var socialUserName          : String?
//    var company                 : String?
//    var title                   : String?
//    var bio                     : String?
//    var isPrivateMode           : String?
//    var isPaidOn                : String?
//    var affilateURL             : String?
//    var businessFirstName       : String?
//    var businessLastName        : String?
//    var businessUserName        : String?
//    var businessCompany         : String?
//    var businessTitle           : String?
//    var businessBio             : String?
//}

//struct Contact {
//    
//    var profileImg: UIImage?
//    var name: String
//    var phoneNo: String?
//}

//struct Recommended {
//    
//    var socialNetworkImg: UIImage?
//    var socialNetworkName: String
//}

//struct Transaction {
//    
//    var profileImg: UIImage?
//    var transactionType: String
//    var name: String?
//    var date: String?
//    var tokens: String?
//}

//struct ButtonTitle {
//    
//    static var AddToContact                            = "Add Contact"
//    static var Share                                   = "Share"
//    static var ShareProfile                            = "Share Profile"
//    static var SendToken                               = "Send Token"
//    static var EditProfile                             = "Edit Profile"
//    static var QRCode                                  = "QR Code"
//}

//struct TapNearByKey {
//    
//    static var SenderID                             = "sender_id"
//    static var ReceiverID                           = "receiver_id"
//    static var SenderName                           = "sender_name"
//    static var BLEToken                             = "BLEToken"
//    static var Message                              = "message"
//    static var Notify                               = "notify"
//    static var BLEAds                               = "bleads"
//}

//struct MenuOption {
//    
//    static var About                                = "About"
//    static var Shop                                 = "Shop"
//    static var BluePlus                             = "Blue Plus"
//    static var Settings                             = "Settings"
//    static var History                              = "History"
//    static var Logout                               = "Log Out"
//    static var NetworkingMode                       = "Networking Mode"
//    static var ActivateBSD                          = "Activate NFC"
//    static var Notification                         = "Notifications"
//    static var ReferFriends                         = "Refer Friends"
//    static var Analytics                            = "Analytics"
//    static var EditProfile                          = "Edit Profile"
//    static var CreateEvent                          = "Event"
//    static var UnlockPremiumFeatures                = "Unlock Premium Features"
//    static var Historyofinteractions                = "History of interactions"
//    static var HowitWorks                           = "How it Works"
//    static var LeaveAppFeedback                     = "Feedback"
//}

// ----------------------------------------------------------
//                       MARK: - set TableView Height -
// ----------------------------------------------------------
//class SelfSizedTableView: UITableView {
//    
//    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
//    
//    override func reloadData() {
//        super.reloadData()
//        self.invalidateIntrinsicContentSize()
//        self.layoutIfNeeded()
//    }
//    
//    override var intrinsicContentSize: CGSize {
//        super.setNeedsLayout()
//        super.layoutIfNeeded()
//        
//        let height = min(contentSize.height, maxHeight)
//        return CGSize(width: contentSize.width, height: height)
//    }
//}

//protocol UpdateSubscriptionStatus {
//    func updateScreen()
//}
