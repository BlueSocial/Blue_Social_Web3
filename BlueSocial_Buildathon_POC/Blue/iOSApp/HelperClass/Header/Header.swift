//
//  Header.swift
//  Blue
//
//  Created by Blue.

import UIKit

struct APIName {
    
    // Register new user - PublicRegisterVC
    static var kRegister = "register"
    
    // Update User Settings - callDeleteUserAccountAPI - DeleteVC
    static var kUpdateSettings = "updateSettings"
    
    // Get User Interaction History - InteractionListVC
    static var kGetDeviceHistory = "getDeviceHistory"
    
    // To add nearByUser in Interactions List - callDeviceScanAPI - BaseVC - (ProfileVC | DiscoverVC)
    static var kDeviceScan = "deviceScan"
    
    // Get Social Network List - callGetSocialListAPI - LinkStoreVC | AddSocialNetworkPopupVC | AddSocialNetworksVC
    static var kGetSocialList = "getSocialList"
    
    // Get User Social Detail Info - BaseVC
    static var kGetInfo = "getInfo"
    
    // Get User Social Detail (Only Required Details for Discover Screen) Info - BaseVC
    static var kGetUserInfo = "getUserInfo"
    
    // Update User Social Profile - EditProfileVC
    static var kuPBS = "uPBS"
    
    // User Login - callLoginAPI | PublicLoginVC | DeleteVC | LogoutVC
    static var kLogin = "login"
    
    // Logout - DeleteVC | LogoutVC | AddAccountVC
    static var kLogout = "logout"
    
    // Change User Password - ChangePasswordVC
    static var kChangePassword = "changePassword"
    
    // Send OTP Email on Forgot Password - PublicForgetPasswordVC
    static var kSendOtpEmail = "sendOtpEmail"
    
    // Reset User Password - ResetPasswordVC | ChangePasswordVC
    static var kResetPassword = "resetPassword"
    
    // Get Reference Connect - getInviteClick - ProfileVC
    static var kGetReferenceConnect = "getReferenceConnect"
    
    // Save click Social link Count - ProfileVC
    static var kClickSocialLink = "clickSociallink"
    
    // Get Social Link in Insights with no of taps - InsightSocialLinksVC
    static var kGetSocialLinks = "getSocialLinks"
    
    // Get Bulk Content for Beacon - callGetBulkContentAPIToGetBeaconDetail - iBeaconManager
    static var kGetBulkContent = "getBulkContent"
    
    // Check if Username exist for both Social & Business Username - GeneralInfoVC | AddUserNameVC
    static var kCheckUsername = "checkUsername"
    
    // Update Username - AddUserNameVC
    static var kUpdateUsername = "uUsernameOnly"
    
    // AddInterestsVC | FilterInterestsVC
    static var kGetInterests = "getInterests"
    
    // AddInterestsVC | FilterInterestsVC
    static var kUpdateInterests = "updateInterests"
    
    // callCheckEmailExistAPI - PublicRegisterVC | PublicForgetPasswordVC
    static var kGetEmailCheck = "getEmailCheck"
    
    // WalletVC
    static var kGetIndividualProofInteraction = "getIndividualProofInteraction"
    
    // Get User Profile Analytics Data For Profile Insights screen - InsightProfileVC
    static var kGetProfileData = "getProfileData"
    
    // Add Social Media URL Link - EditSocialNetworkVC
    static var kSaveLink = "savelink"
    
    // Remove Link - EditSocialNetworkVC
    static var kRemoveLink = "removelink"
    
    // Get wallet URL - MyQRCodeVC | ShareQRCodeVC
    static var kGetWalletDetails = "getWalletdetails"
    
    // NearbyProofOfInteractionVC
    static var kProofOfInteraction = "proofOfInteraction"
    
    // EmailOTPVerificationVC
    static var kVerifyOtpEmail = "verifyOtpEmail"
    
    // Update User Profile Image - ChangeProfilePhotoVC | AddPhotoVC | EditSocialNetworkVC
    static var kuProfileImg = "uProfileImg"
    
    // Send Token to Receiver - BaseVC | SendTokenVC
    static var kAddInteractionBst = "addInteractionBst"
    
    // InsightProfileVC
    static var kGetInsightProfileChartData = "getInsightsChartData"
    
    // Post User Notes - AddNoteVC
    static var kAddNotes = "addNotes"
    
    // To Send | Accept | Reject BreakTheIceRequest - BaseVC | ProfileVC | NearbyRequestVC | NearbyWaitingApprovalVC | NearbyDistanceVC | NearbyDirectionVC | NearbyProofOfInteractionVC | BreakTheIcePopupVC
    static var kBreakTheIceRequest = "breakTheIceRequest"
    
    // Exchange Contact - BaseVC | ProfileVC
    static var kNotifyConnectUser = "notifyconnectUser"
    
    // BluetoothStatusVC
    static var kSaveBleCaption = "saveBleCaption"
    
    // NearbyDistanceVC | NearbyDirectionVC
    static var kNotifyInRangeUser = "notifyInRangeUser"
}

struct APIParamKey {
    
    static let kFlag                                = "flag"
    static let kName                                = "name"
    static let kFirstName                           = "firstname"
    static let kLastName                            = "lastname"
    static let kUniversity                          = "university"
    static let kEmail                               = "email"
    static let kPassword                            = "password"
    static let kMobile                              = "mobile"
    static let kPushToken                           = "push_token"
    static let kDeviceType                          = "device_type"
    static let kIsAuth                              = "is_auth"
    static let kProfessionType                      = "profession_type"
    static let kUserId                              = "userid"
    static let kUser_Id                             = "user_id"
    static let kImg                                 = "img"
    static let kType                                = "type"
    static let kProfilePic                          = "profile_pic"
    static let kBusinessProfilePic                  = "business_profile_pic"
    static let kStatus                              = "status"
    static let kLogin                               = "login"
    static let kAppVersion                          = "app_version"
    static let kValue                               = "value"
    static let kLinkId                              = "link_id"
    static let kUsername                            = "username"
    static let kId                                  = "id"
    static let kLat                                 = "lat"
    static let kLng                                 = "lng"
    static let kSlug                                = "slug"
    static let kSubscriptionStatus                  = "subscription_status"
    static let kOTP                                 = "otp"
    static let kSid                                 = "sid"
    static let kBio                                 = "bio"
    static let kPrivateMode                         = "private_mode"
    static let kCompanyName                         = "company_name"
    static let kSocialNetwork                       = "social_network"
    static let kBusinessFirstName                   = "business_firstname"
    static let kBusinessLastName                    = "business_lastname"
    static let kBusinessUserName                    = "business_username"
    static let kBusinessBio                         = "business_bio"
    static let kBusinessPrivateMode                 = "business_private_mode"
    static let kBusinessCompany                     = "business_company"
    static let kBusinessNetwork                     = "business_network"
    static let kReceiverId                          = "receiverid"
    static let kReceiver_Id                         = "receiver_id"
    static let kTitle                               = "title"
    static let kAddress                             = "address"
    static let kWebsite                             = "website"
    static let kSocialNetworks                      = "social_networks"
    static let kOldPw                               = "old_pw"
    static let kNewPw                               = "new_pw"
    static let kNotes                               = "notes"
    static let kInteraction_user_Id                 = "interaction_user_id"
    static let kDeviceScanType                      = "device_scan_type"
    static let kNFC_URL                             = "nfc_url"
    static let kNFC_Code                            = "nfccode"
    static let kIsDeleted                           = "is_deleted"
    static let kUserMode                            = "usermode"
    static let kCategoryId                          = "category_id"
    static let kCategoryTypeId                      = "category_type_id"
    static let kTransactionId                       = "transaction_id"
    static let kSubscriptionId                      = "subscription_id"
    static let kSubscriptionType                    = "subscription_type"
    static let kAmount                              = "amount"
    static let kBeaconId                            = "beaconid"
    static let kIsEnter                             = "isEnter"
    static let kiBeacon                             = "iBeacon"
    static let kUUID                                = "uuid"
    static let kMajor                               = "major"
    static let kMinor                               = "minor"
    static let kRPassword                           = "rpassword"
    static let kSenderId                            = "sender_id"
    static let kDuration                            = "duration"
    static let kBST                                 = "bst"
    static let kPageIndex                           = "page_index"
    static let kCalenderType                        = "type"
    static let kIsProfileCompleted                  = "is_profile_completed"
    static let kUserInterest                        = "user_interest"
    static let kIsBusinessProfile                   = "is_business_profile"
    static let kuwb_token                           = "uwb_token"
    static let kis_u1_chip_available                = "is_u1_chip_available"
    static let kCaption                             = "caption"
    static let kLabel                               = "label"
    static let kUser_referral_code                  = "user_referral_code"
    static let kIsIntialTransaction                 = "isIntialTransaction"
    static let kSubscription_date                   = "subscription_date"
}

struct APIFlagValue {
    
    static let kSignup                              = "signup"
    static let kLogin                               = "login"
    static let kSlug                                = "slug"
    static let kEditBusinessProfile                 = "edit_business_profile"
    static let kResume                              = "resume"
    static let kiPhone                              = "iPhone"
    static let kMonthly                             = "monthly"
    static let kBusinessCard                        = "businesscard"
    static let kDeviceScan                          = "device_scan"
    static let kDeviceHistory                       = "device_history"
    static let kExportLead                          = "exportlead"
    static let kDelete                              = "delete"
    static let kGetBusinessProfile                  = "get_business_profile"
    static let kSaveLink                            = "save_link"
    static let kSentOtp                             = "sent_otp"
    static let kSentOtpRegister                     = "sent_otp_register"
    static let kVerifyOtp                           = "verify_otp"
    static let kResetPassword                       = "reset_password"
    static let kEmailCheck                          = "email_check"
    static let kCheckUsername                       = "check_username"
    static let kGetAppVersion                       = "get_app_version"
    static let kLogout                              = "logout"
    static let kUpload                              = "upload"
    static let kGetProfileData                      = "get_profile_data"
    static let kSocialClicks                        = "social_clicks"
    static let kGetProfile                          = "get_profile"
    static let kSubmitClick                         = "submit_click"
    static let kResendMail                          = "resend_mail"
    static let kGetBulkContent                      = "get_bulk_content"
    static let kRegisterBusinessCard                = "register_businesscard"
    static let kSend                                = "send"
    static let kSent                                = "sent"
    static let kAccept                              = "accept"
    static let kReject                              = "reject"
    static let kInProcessReject                     = "in_process_reject"
    static let kExchangeTokenReceived               = "exchange_token_received"
    static let kSentOtpChangeEmail                  = "sent_otp_change_email"
}
