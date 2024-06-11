//
//  Response.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class Response: Mappable {
    
    required init?(map: Map) {
        // mapping(map: map)
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - COMMON -
    //----------------------------------------------------------------------------------------------------
    var status: String?
    var msg: String?
    var message: String?
    var data: [String: Any]?
    var success: Bool?
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - USED -
    //----------------------------------------------------------------------------------------------------
    // "register" - Register new user - StudentRegisterVC | PublicRegisterVC
    var register: Register?
    
    // "getUniversityList" - StudentRegisterVC
    var universityDetails: [UniversityDetails]?
    
    // "sendOtpEmail" - StudentRegisterVC | StudentForgetPasswordVC | PublicForgetPasswordVC
    var otp: String?
    
    // "uProfileImg" - ChangeProfilePhotoVC | AddPhotoVC | EditSocialNetworkVC (UploadResume) | BusinessCardProfileVC (UploadBusinessCard)
    var selfie: Selfie?
    
    // "getInfo" - Get User Social Detail Info
    var userDetail: UserDetail?
    
    // "getInterests" - AddInterestsVC | FilterInterestsVC
    var userInterest: [User_Interest]?
    
    // "getSocialList" - Get Social Network List - LinkStoreVC | AddSocialNetworkPopupVC | AddSocialNetworksVC | BusinessCardProfileVC
    var socialNetworkModel: SocialListModel?
    
    // "savelink" - Add Social Media URL Link - EditSocialNetworkVC
    var saveNetwork: SaveNetwork?
    
    // "getIndividualProofInteraction" - WalletVC
    var getIndividualProofInteraction: [IndividualProofInteractionModel]?
    
    // "addInteractionBst" - SendTokenVC
    var interactionBST: IndividualProofInteractionModel?
    
    // "getDeviceHistory" - Get User Interaction History - InteractionMapVC | InteractionListVC | SelectRecipientVC
    var deviceScanHistory: [DeviceScanHistory]?
    
    // "getDeviceHistory" - Get User Interaction History
    var totalPageIndex: Int?
    
    // "checkLockedMissedOpportunity" - InteractionListVC
    var isExist: Bool?
    
    // "getMissedOpportunity" - MissedOpportunitiesVC
    var missedOpportunityList: [MissedOpportunityList]?
    
    // "getBulkContent" - iBeaconManager - callGetBulkContentAPIToGetBeaconDetail
    var beacons: [Beacon]?
    
    // "getProfileData" - Get User Profile Analytics Data For Profile Insights screen - InsightProfileVC
    var blueInsightsProfileDetail: BlueInsightsProfileDetail?
    
    // "getInsightsChartData" - InsightProfileVC
    var insightsProfileChartDetail: InsightProfileChartDetail?
    
    // "getSocialLinks" - Get Social Link in Insights with no of taps - InsightSocialLinksVC
    var socialClick: SocialClick?
    
    // "getNotification" - Get Notification List - NotificationVC
    var notificationListModel: [NotificationList]!
    
    var appPurchaseFeature: [AppPurchaseFeature]?
    
    // "getReferralInviteData" - ReferralFriendListVC
    var getReferralInviteData: [ReferralInviteDataModel]?
    
    // "getReferralDataInsights" - ReferralOverviewVC
    var getReferralInsightsDataModel: ReferralInsightsDataModel?
    
    // "checkEmailVerified" - SecurityVC
    var is_verified: Bool?
    var verification_status: String?
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - NOT USED -
    //----------------------------------------------------------------------------------------------------
    //var socialNetwork                       : SocialNetwork?
    //var proofOfInteractionUserHistory       : [ProofOfInteractionUserHistory]?
    //var userNote                            : [UserNote]?
    //var productDataList                     : [ProductDataList]?
    //var getInfo                             : GetInfo?
    //var getProfileData                      : GetProfileData?
    //var getProfileDataFromValue             : GetProfileDataFromValue?
    //var myEventList                         : [MyEventList]?
    //var topic                               : [Topic]?
    //var referralsList                       : ReferralsList?
    //var historyInteraction                  : [InteractionUserHistory]?
    //var myEventDetails                      : MyEventDetails?
    //var total_interactions                  : String?
    //var add_link                            : Bool?
    //var last_downloaded_date                : String?
    //var private_mode                        : String?
    //var private_mode_list                   : [PrivateModeList]?
    //var business_private_mode               : String?
    //var business_private_mode_list          : [BusinessPrivateModeList]?
    //var yourself                            : yourself?
    //var mobileNumber                        : MobileNumber?
    
    func mapping(map: Map) {
        
        //----------------------------------------------------------------------------------------------------
        // MARK: - COMMON -
        //----------------------------------------------------------------------------------------------------
        status                              <- map["status"]
        msg                                 <- map["msg"]
        data                                <- map["data"]
        success                             <- map["success"]
        
        //----------------------------------------------------------------------------------------------------
        // MARK: - USED -
        //----------------------------------------------------------------------------------------------------
        register                            <- map["data"]
        universityDetails                   <- map["data"]
        otp                                 <- map["otp"]
        selfie                              <- map["data"]
        userDetail                          <- map["data"]
        userInterest                        <- map["data"]
        socialNetworkModel                  <- map["data"]
        saveNetwork                         <- map["data"]
        getIndividualProofInteraction       <- map["data"]
        interactionBST                      <- map["data"]
        deviceScanHistory                   <- map["data"]
        totalPageIndex                      <- map["totalPageIndex"]
        missedOpportunityList               <- map["data"]
        beacons                             <- map["data.iBeacon"]
        blueInsightsProfileDetail           <- map["data"]
        insightsProfileChartDetail          <- map["data"]
        socialClick                         <- map["data"]
        notificationListModel               <- map["data"]
        appPurchaseFeature                  <- map["data"]
        getReferralInviteData               <- map["data"]
        getReferralInsightsDataModel        <- map["data"]
        isExist                             <- map["data.isExist"]
        is_verified                         <- map["data.is_verified"]
        verification_status                 <- map["data.verification_status"]
        
        //----------------------------------------------------------------------------------------------------
        // MARK: - NOT USED -
        //----------------------------------------------------------------------------------------------------
        //socialNetwork                       <- map["data"]
        //proofOfInteractionUserHistory       <- map["data"]
        //userNote                            <- map["data"]
        //productDataList                     <- map["data"]
        //getInfo                             <- map["data"]
        //getProfileData                      <- map["data"]
        //getProfileDataFromValue             <- map["data"]
        //myEventList                         <- map["data"]
        //topic                               <- map["data"]
        //referralsList                       <- map["data"]
        //historyInteraction                  <- map["data"]
        //myEventDetails                      <- map["data"]
        //total_interactions                  <- map["total_interactions"]
        //add_link                            <- map["add_link"]
        //last_downloaded_date                <- map["last_downloaded_date"]
        //private_mode                        <- map["data"]
        //private_mode_list                   <- map["private_mode"]
        //business_private_mode               <- map["data"]
        //business_private_mode_list          <- map["business_private_mode_list"]
        //yourself                            <- map["data"]
        //mobileNumber                        <- map["data"]
    }
}
