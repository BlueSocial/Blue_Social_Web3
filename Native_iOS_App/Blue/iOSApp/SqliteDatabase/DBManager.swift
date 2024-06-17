//
//  DBManager.swift
//  Blue
//
//  Created by Blue.


import Foundation
import ObjectMapper

let tbl_NotificationHistory            = "NotificationHistory"
let tbl_UserData                       = "UserData"
let tbl_MultipleAccount                = "MultipleAccount"
let tbl_DeviceHistory                  = "DeviceHistory"
let tbl_AppPurchaseFeature             = "AppPurchaseFeature"
let tbl_productDataList                = "productDataList"
let tbl_eventDataList                  = "EventDataList"
let tbl_InsightsProfileData            = "InsightsProfileData"
let tbl_IndividualProofInteraction     = "IndividualProofInteraction"
let tbl_notificationList               = "NotificationList"

//tbl_History
let kNotiid                     = "id"
let kTitle                      = "title"
let kSubtitle                   = "subtitle"
let kLoginUserID                = "loginUserID"
let kUserId                     = "userid"
let kStatus                     = "status"
let kTime                       = "time"
let kSid                        = "sid"
let kUsertype                   = "usertype"

//tbl_UserData
let kID                         = "ID"
let kId                         = "id"
let kuserID                     = "userID"
let krequestBody                = "requestBody"
let kbusinessProfile            = "businessProfile"

//tbl_MultipleAccount
let kuserProfile                = "userProfile"
let kfullname                   = "fullname"
let kemail_S                    = "email"
let kpassword_S                 = "password"

//tbl_InsightsProfileData
let kProfileInsightsData        = "ProfileInsightsData"
let kLinkInsightsData           = "LinkInsightsData"

class DBManager {
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - AppDelegate -
    //----------------------------------------------------------------------------------------------------
    class func createInsightsProfileDataTable() -> Bool {
        
        let query = "CREATE TABLE IF NOT EXISTS InsightsProfileData (ID INT AUTO_INCREMENT PRIMARY KEY, userID TEXT, ProfileInsightsData TEXT, LinkInsightsData TEXT)"
        let result = SQLiteDB.shared.execute(sql: query)
        return result != 0
    }
    
    class func modifyUserDataTable() -> Bool {
        
        let query = "ALTER TABLE UserData ADD COLUMN businessProfile TEXT"
        let result = SQLiteDB.shared.execute(sql: query)
        return result != 0
    }
    
    class func createIndividualProofInteractionTable() -> Bool {
        
        let query = "CREATE TABLE IF NOT EXISTS IndividualProofInteraction (ID INT AUTO_INCREMENT PRIMARY KEY, userID TEXT, requestBody TEXT)"
        let result = SQLiteDB.shared.execute(sql: query)
        return result != 0
    }
    
    // Notification List Table - DB MIGRATION QUERY
    class func createNotificationListTable() -> Bool {
        
        let query = "CREATE TABLE IF NOT EXISTS NotificationList (ID INT AUTO_INCREMENT PRIMARY KEY, userID TEXT, requestBody TEXT)"
        let result = SQLiteDB.shared.execute(sql: query)
        return result != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - InsightProfileVC | InsightSocialLinksVC -
    //----------------------------------------------------------------------------------------------------
    // InsightProfileVC
    class func checkProfileInsightExist(userID: String) -> (isSuccess: Bool, userData: BlueInsightsProfileDetail?)  {
        
        let query: String = "SELECT \(kProfileInsightsData) FROM \(tbl_InsightsProfileData) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query)).first
        
        if data != nil && data!.count > 0 {
            return (isSuccess: true, userData: BlueInsightsProfileDetail(JSONString: data![kProfileInsightsData] as! String))
        } else {
            return (isSuccess: false, userData: nil)
        }
    }
    
    // InsightProfileVC
    class func updateProfileInsight(userID: String, requestBody: String) -> Bool {
        
        let query = "UPDATE \(tbl_InsightsProfileData) SET \(kProfileInsightsData) = '\(requestBody)' WHERE  \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    // InsightSocialLinksVC
    class func checkLinksInsightExist(userID: String) -> (isSuccess: Bool, userData: SocialClick?)  {
        
        let query: String = "SELECT \(kLinkInsightsData) FROM \(tbl_InsightsProfileData) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query)).first
        
        if data != nil && data!.count > 0 {
            
            if data![kLinkInsightsData] as! String == "" {
                return (isSuccess: true, userData: nil)
            } else {
                return (isSuccess: true, userData: SocialClick(JSONString: data![kLinkInsightsData] as! String))
            }
            
        } else {
            return (isSuccess: false, userData: nil)
        }
    }
    
    // InsightSocialLinksVC
    class func updateLinksInsight(userID: String, requestBody: String) -> Bool {
        
        let query = "UPDATE \(tbl_InsightsProfileData) SET \(kLinkInsightsData) = '\(requestBody)' WHERE  \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    // InsightProfileVC | InsightSocialLinksVC
    class func insertProfileInsight(userID: String, profileInsightsData: String, linkInsightsData: String) -> Bool {
        
        let query = "INSERT OR REPLACE INTO \(tbl_InsightsProfileData) (\(kuserID), \(kProfileInsightsData), \(kLinkInsightsData)) VALUES(?,?,?)"
        let param = [userID, profileInsightsData, linkInsightsData] as [Any]
        let rcs   = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC | ProfileVC -
    //----------------------------------------------------------------------------------------------------
    // BaseVC | ProfileVC
    class func insertUserData(userID: String, requestBody: String, businessProfile: String) -> Bool {
        
        var query: String = "INSERT OR REPLACE INTO \(tbl_UserData) (\(kuserID), \(krequestBody), \(kbusinessProfile)) VALUES(?,?,?)"
        if UserLocalData.userMode == "0" {
            query = "INSERT OR REPLACE INTO \(tbl_UserData) (\(kuserID), \(krequestBody), \(kbusinessProfile)) VALUES(?,?,?)"
        } else if UserLocalData.userMode == "1" {
            query = "INSERT OR REPLACE INTO \(tbl_UserData) (\(kuserID), \(krequestBody), \(kbusinessProfile)) VALUES(?,?,?)"
        }
        
        let param   = [userID, requestBody, businessProfile] as [Any]
        let rcs     = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - DiscoverVC -
    //----------------------------------------------------------------------------------------------------
    class func getUserData(userID: String) -> UserDetail? {
        
        let query = "SELECT \(krequestBody) FROM \(tbl_UserData) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query)).first
        
        if data != nil && data!.count > 0 {
            return UserDetail(JSONString: data![krequestBody] as! String)
        } else {
            return nil
        }
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC | UIViewControllerExtension | DiscoverVC | ProfileVC | EditProfileVC | SwitchProfileVC | AddPhotoVC | ChangeProfilePhotoVC | InterestVC | FilterInterestVC | SocialVC | AddSocialNetworkVC | EditSocialNetworkVC | NearbyRequestVC | NearbyDeclinedRequestVC | NearbyDistanceVC | NearbyDirectionVC -
    //----------------------------------------------------------------------------------------------------
    class func checkUserSocialInfoExist(userID: String ) -> (isSuccess: Bool, userData: UserDetail?)  {
        
        let query: String = "SELECT \(krequestBody) FROM \(tbl_UserData) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query)).first
        
        if data != nil && data!.count > 0 {
            //print("Data :: \n \(data ?? [:])")
            return (isSuccess: true, userData: UserDetail(JSONString: data![krequestBody] as! String))
        } else {
            //print("Data :: \n \(data ?? [:])")
            return (isSuccess: false, userData: nil)
        }
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC | UIViewControllerExtension | ProfileVC | AddPhotoVC | ChangeProfilePhotoVC | FilterInterestVC -
    //----------------------------------------------------------------------------------------------------
    class func updateSocialProfile(userID: String, requestBody: String) -> Bool {
        
        //let temp = (requestBody.replacingOccurrences(of: "\\n", with: "")).replacingOccurrences(of: "'", with: "")
        let temp = (requestBody.replacingOccurrences(of: "'", with: ""))
        let query = "UPDATE \(tbl_UserData) SET \(krequestBody) = '\(temp)' WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print(rcs)
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC -
    //----------------------------------------------------------------------------------------------------
    class func removeCurrentUserData(userID: String) -> Bool {
        
        let query = "DELETE FROM \(tbl_UserData) WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
    
    class func isMultipleAccountExist(userID: String) -> Bool? {
        
        let data = DBManager.getMultipleAccount(userID: userID)
        
        if data != nil && data!.id == userID {
            return true
        } else {
            return false
        }
    }
    
    class func getMultipleAccount(userID: String) -> UserDetail? {
        
        let query = "SELECT * FROM \(tbl_MultipleAccount) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query)).first
        
        if data != nil && data!.count > 0 {
            return UserDetail(JSONString: data![kuserProfile] as! String)
        } else {
            return nil
        }
        //return Mapper<UserDetail>().mapArray(JSONArray: SQLiteDB.shared.query(sql: query))
    }
    
    class func removeCurrentFromMultipleAccount(userID: String) -> Bool {
        
        let query = "DELETE FROM \(tbl_MultipleAccount) WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - InteractionListVC | SelectRecipientVC -
    //----------------------------------------------------------------------------------------------------
    class func insertDeviceHistory(userID: String, requestBody: String) -> Bool {
        
        let query = "INSERT OR REPLACE INTO \(tbl_DeviceHistory) (\(kuserID), \(krequestBody) ) VALUES(?,?)"
        let param = [userID, requestBody] as [Any]
        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - InteractionMapVC | InteractionListVC | SelectRecipientVC -
    //----------------------------------------------------------------------------------------------------
    class func getDeviceHistory(userID: String) -> [DeviceScanHistory]? {

        let query = "SELECT \(krequestBody) FROM \(tbl_DeviceHistory) WHERE \(kuserID) = '\(userID)'"
        let data = SQLiteDB.shared.query(sql: query)

        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
            return Mapper<DeviceScanHistory>().mapArray(JSONString: body )
        } else {
            return nil
        }
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC | InteractionListVC | SelectRecipientVC -
    //----------------------------------------------------------------------------------------------------
    class func isDeviceHistoryExist(userID: String) -> Bool {
        
        let query = "SELECT \(krequestBody) FROM \(tbl_DeviceHistory) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query))
        
        if data.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - InteractionListVC | SelectRecipientVC -
    //----------------------------------------------------------------------------------------------------
    class func setDeviceHistory(userID: String, requestBody: String) -> Bool{
        
        let query = "UPDATE \(tbl_DeviceHistory) SET \(krequestBody) = '\(requestBody)' WHERE  \(kuserID) = '\(userID)'"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - BaseVC -
    //----------------------------------------------------------------------------------------------------
    class func removeCurrentDeviceHistory(userID: String) -> Bool {
        
        let query = "DELETE FROM \(tbl_DeviceHistory) WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
    
    class func isproductDataListExist(userID: String) -> Bool {
        
        let query = "SELECT \(krequestBody) FROM \(tbl_productDataList) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query))
        
        if data.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func removeCurrentproductDataList(userID: String) -> Bool {
        
        let query = "DELETE FROM \(tbl_productDataList) WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
    
    class func isDeviceEventDataExist(userID: String) -> Bool {
        
        let query = "SELECT \(krequestBody) FROM \(tbl_eventDataList) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query))
        
        if data.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func setEventData(userID: String,requestBody : String) -> Bool {
        
        let query = "UPDATE \(tbl_eventDataList) SET \(krequestBody) = '\(requestBody)' WHERE  \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    class func removeCurrentEventData(userID: String) -> Bool {
        
        let query = "DELETE FROM \(tbl_eventDataList) WHERE \(kuserID) = \(userID)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - AppDelegate -
    //----------------------------------------------------------------------------------------------------
    class func deleteFrom(table: String) -> Bool {
        
        let query = "DELETE FROM \(table)"
        let rcs = SQLiteDB.shared.execute(sql: query)
        print("clearAllRecord Result:->\(rcs)")
        return rcs != 0 ? true : false
    }
 
    //----------------------------------------------------------------------------------------------------
    // MARK: - WalletVC -
    //----------------------------------------------------------------------------------------------------
    class func insertIndividualProofInteraction(userID: String, requestBody: String) -> Bool {
        
        let query = "INSERT OR REPLACE INTO \(tbl_IndividualProofInteraction) (\(kuserID), \(krequestBody) ) VALUES(?,?)"
        let param = [userID, requestBody] as [Any]
        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
        return rcs != 0
    }

    class func getIndividualProofInteraction(userID: String) -> [IndividualProofInteractionModel]? {
    
        let query = "SELECT \(krequestBody) FROM \(tbl_IndividualProofInteraction) WHERE \(kuserID) = '\(userID)'"
        let data = SQLiteDB.shared.query(sql: query)
    
        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
            return Mapper<IndividualProofInteractionModel>().mapArray(JSONString: body )
        } else {
            return nil
        }
    }
    
    class func isIndividualProofInteraction(userID: String) -> Bool {
    
        let query = "SELECT \(krequestBody) FROM \(tbl_IndividualProofInteraction) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query))
        if data.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func setIndividualProofInteraction(userID: String, requestBody: String) -> Bool{
    
        let query = "UPDATE \(tbl_IndividualProofInteraction) SET \(krequestBody) = '\(requestBody)' WHERE  \(kuserID) = '\(userID)'"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - NotificationVC -
    //----------------------------------------------------------------------------------------------------
    class func insertNotificationList(userID: String, requestBody: String) -> Bool {
        
        let query = "INSERT OR REPLACE INTO \(tbl_notificationList) (\(kuserID), \(krequestBody) ) VALUES(?,?)"
        let param = [userID, requestBody] as [Any]
        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
        return rcs != 0
    }

    class func getNotificationList(userID: String) -> [NotificationList]? {
    
        let query = "SELECT \(krequestBody) FROM \(tbl_notificationList) WHERE \(kuserID) = '\(userID)'"
        let data = SQLiteDB.shared.query(sql: query)
    
        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
            return Mapper<NotificationList>().mapArray(JSONString: body )
        } else {
            return nil
        }
    }
    
    class func isNotificationList(userID: String) -> Bool {
    
        let query = "SELECT \(krequestBody) FROM \(tbl_notificationList) WHERE \(kuserID) = '\(userID)'"
        let data = (SQLiteDB.shared.query(sql: query))
        if data.count > 0 {
            return true
        } else {
            return false
        }
    }

    class func setNotificationList(userID: String, requestBody: String) -> Bool{
    
        let query = "UPDATE \(tbl_notificationList) SET \(krequestBody) = '\(requestBody)' WHERE  \(kuserID) = '\(userID)'"
        let rcs = SQLiteDB.shared.execute(sql: query)
        return rcs != 0
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - NOT USED -
    //----------------------------------------------------------------------------------------------------
    //    class func insertHistoryData(title: String, subTitle: String, loginUserID: String, userid: String, status: String, time: String) -> Bool {
    //
    //        let query = "INSERT OR REPLACE INTO \(tbl_NotificationHistory) (\(kTitle), \(kSubtitle), \(kLoginUserID), \(kUserId), \(kStatus), \(kTime)) VALUES(?,?,?,?,?,?)"
    //        let param = [title, subTitle, loginUserID, userid, status, time] as [Any]
    //        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
    //        return rcs != 0
    //    }
    
    //    class func getNotificationData(currentID: String, notifyType: String) -> [NotificationViewModel] {
    //
    //        let query = "SELECT * FROM \(tbl_NotificationHistory) WHERE \(kLoginUserID) = '\(currentID)' AND \(kStatus) = '\(notifyType)'"
    //        return Mapper<NotificationViewModel>().mapArray(JSONArray: SQLiteDB.shared.query(sql: query))
    //    }
    
    //    class func setCurrentUserNotification(notificationStatus: String, currentID: String, notifiationID: String) -> Bool{
    //
    //        let query = "UPDATE \(tbl_NotificationHistory) SET \(kStatus) = '\(notificationStatus)' WHERE  \(kLoginUserID) = \(currentID) AND \(kId) = \(notifiationID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        return rcs != 0
    //    }
    
    //    class func removeCurrentNotifiation(indexID: String) -> Bool {
    //
    //        let query = "DELETE FROM \(tbl_NotificationHistory) WHERE \(kNotiid) = \(indexID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        print("clearAllRecord Result:->\(rcs)")
    //        return rcs != 0 ? true : false
    //    }
    
    //    class func getBusinessUserData(userID: String) -> UserDetail? {
    //
    //        let query = "SELECT \(kbusinessProfile) FROM \(tbl_UserData) WHERE \(kuserID) = '\(userID)'"
    //        let data = (SQLiteDB.shared.query(sql: query)).first
    //
    //        if data != nil && data!.count > 0 {
    //            return UserDetail(JSONString: data![kbusinessProfile] as! String)
    //        } else {
    //            return nil
    //        }
    //    }
    
    //    class func insertMultipleAccount(userID: String, userProfile: String, fullname: String, email: String, password : String) -> Bool {
    //
    //        let query = "INSERT OR REPLACE INTO \(tbl_MultipleAccount) (\(kuserID), \(kuserProfile) ,\(kfullname), \(kemail_S), \(kpassword_S) ) VALUES(?,?,?,?,?)"
    //        let param = [userID, userProfile, fullname, email, password] as [Any]
    //        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
    //        return rcs != 0
    //    }
    
    //    class func setCurrentMultipleAccount(userID: String, userProfile: String, fullname: String, email: String, password : String) -> Bool{
    //
    //        let query = "UPDATE \(tbl_MultipleAccount) SET \(kuserProfile)  = '\(userProfile)', \(kfullname) = '\(fullname)' , \(kemail_S) = '\(email)', \(kpassword_S) = '\(password)' WHERE  \(kuserID) = \(userID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        return rcs != 0
    //    }
    
    //    class func getAppPurchaseFeature(userID: String) -> [AppPurchaseFeature]? {
    //
    //        let query = "SELECT \(krequestBody) FROM \(tbl_AppPurchaseFeature) WHERE \(kuserID) = '\(userID)'"
    //        let data = SQLiteDB.shared.query(sql: query)
    //
    //        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
    //            return  Mapper<AppPurchaseFeature>().mapArray(JSONString: body )
    //        } else {
    //            return nil
    //        }
    //    }
    
    //    class func insertproductDataList(userID: String, requestBody: String) -> Bool {
    //
    //        let query = "INSERT OR REPLACE INTO \(tbl_productDataList) (\(kuserID), \(krequestBody) ) VALUES(?,?)"
    //        let param = [userID, requestBody] as [Any]
    //        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
    //        return rcs != 0
    //    }
    
    //    class func getproductDataList(userID: String) -> [ProductDataList]? {
    //
    //        let query = "SELECT \(krequestBody) FROM \(tbl_productDataList) WHERE \(kuserID) = '\(userID)'"
    //        let data = SQLiteDB.shared.query(sql: query)
    //
    //        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
    //            return  Mapper<ProductDataList>().mapArray(JSONString: body )
    //        } else {
    //            return nil
    //        }
    //    }
    
    //    class func setproductDataList(userID: String,requestBody : String) -> Bool{
    //
    //        let query = "UPDATE \(tbl_productDataList) SET \(krequestBody) = '\(requestBody)' WHERE  \(kuserID) = \(userID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        return rcs != 0
    //    }
    
    //    class func insertEventData(userID: String, requestBody: String) -> Bool {
    //
    //        let query = "INSERT OR REPLACE INTO \(tbl_eventDataList) (\(kuserID), \(krequestBody) ) VALUES(?,?)"
    //        let param = [userID, requestBody] as [Any]
    //        let rcs = SQLiteDB.shared.execute(sql: query, parameters: param as [AnyObject])
    //        return rcs != 0
    //    }
    
    //    class func getEventData(userID: String) -> [MyEventList]? {
    //
    //        let query = "SELECT \(krequestBody) FROM \(tbl_eventDataList) WHERE \(kuserID) = '\(userID)'"
    //        let data = SQLiteDB.shared.query(sql: query)
    //
    //        if let requestBody = data.first, let body = requestBody[krequestBody] as? String {
    //            return  Mapper<MyEventList>().mapArray(JSONString: body )
    //        } else {
    //            return nil
    //        }
    //    }
    
    //    class func removeIndividualProofInteraction(userID: String) -> Bool {
    //
    //        let query = "DELETE FROM \(tbl_IndividualProofInteraction) WHERE \(kuserID) = \(userID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        print("clearAllRecord Result:->\(rcs)")
    //        return rcs != 0 ? true : false
    //    }
    
    //    class func removeNotificationList(userID: String) -> Bool {
    //
    //        let query = "DELETE FROM \(tbl_notificationList) WHERE \(kuserID) = \(userID)"
    //        let rcs = SQLiteDB.shared.execute(sql: query)
    //        print("clearAllRecord Result:->\(rcs)")
    //        return rcs != 0 ? true : false
    //    }
}
