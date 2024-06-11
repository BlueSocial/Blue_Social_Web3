//
//  UserLocalData.swift
//  Blue
//
//  Created by Blue.

import Foundation

final class UserLocalData {
    
    private enum DataKey: String {
        
        case UserMigrate // Used for DBVersioning
        case UserID
        case userMode // "0" - Social, "1" - Business
        case ShouldShowTourScreen // Tutorial Screen
        case lastOpenedTourScreen
        case BLENotify
        case timeStamp
        case arrCustomInterest
        case userName
        case isNetworkmode
        case referralInviteUrl
        case branchParam // referalCode
        case BreakTheICE // breakTheICE
        case multipleLogin // arrOfAccountData
        case transactionIdIAP
        case amountIAP
        case subscriptionDateIAP
        case isbtnBLEOn
        case isEmailVerify
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - USED -
    //----------------------------------------------------------------------------------------------------
    static var UserMigrate: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.UserMigrate.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.UserMigrate.rawValue)
            defaults.synchronize()
        }
    }
    
    static var UserID: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.UserID.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.UserID.rawValue)
            defaults.synchronize()
        }
    }
    
    static var userMode: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.userMode.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.userMode.rawValue)
            defaults.synchronize()
        }
    }
    
    static var ShouldShowTourScreen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DataKey.ShouldShowTourScreen.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.ShouldShowTourScreen.rawValue)
            defaults.synchronize()
        }
    }
    
    static var lastOpenedTourScreen: Int {
        get {
            return UserDefaults.standard.integer(forKey: DataKey.lastOpenedTourScreen.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.lastOpenedTourScreen.rawValue)
            defaults.synchronize()
        }
    }
    
    static var BLENotify: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.BLENotify.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.BLENotify.rawValue)
            defaults.synchronize()
        }
    }
    
    static var arrCustomInterest: [User_Interest]? {
        get {
            if let data = UserDefaults.standard.data(forKey: DataKey.arrCustomInterest.rawValue) {
                
                do {
                    if let arrCustomInterest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, User_Interest.self], from: data) as? [User_Interest] {
                        return arrCustomInterest
                    }
                } catch {
                    return []
                }
            }
            // If the data object is nil, initialize arrCustomInterest to an empty array.
            return []
        }
        set {
            let defaults = UserDefaults.standard
            if let newValue = newValue {
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
                    defaults.set(data, forKey: DataKey.arrCustomInterest.rawValue)
                    defaults.synchronize()
                } catch {
                    defaults.removeObject(forKey: DataKey.arrCustomInterest.rawValue)
                }
            } else {
                defaults.removeObject(forKey: DataKey.arrCustomInterest.rawValue)
            }
        }
    }
    
    static var userName: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.userName.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.userName.rawValue)
            defaults.synchronize()
        }
    }
    
    static var isNetworkmode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DataKey.isNetworkmode.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.isNetworkmode.rawValue)
            defaults.synchronize()
        }
    }
    
    static var referalInviteUrl: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.referralInviteUrl.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.referralInviteUrl.rawValue)
            defaults.synchronize()
        }
    }
    
    static var referalCode: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.branchParam.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.branchParam.rawValue)
            defaults.synchronize()
        }
    }
    
    static var breakTheICE: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DataKey.BreakTheICE.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.BreakTheICE.rawValue)
            defaults.synchronize()
        }
    }
    
    static var arrOfAccountData: [[String: Any]] {
        get {
            if let foundArrData = UserDefaults.standard.value(forKey: DataKey.multipleLogin.rawValue)  as? [[String : Any]] {
                return foundArrData
            } else {
                return [[String: Any]]()
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = DataKey.multipleLogin.rawValue
            defaults.set(newValue, forKey: key)
            defaults.synchronize()
        }
    }
    
    static var amountIAP: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.amountIAP.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.amountIAP.rawValue)
            defaults.synchronize()
        }
    }
    
    static var isbtnBLEOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: DataKey.isbtnBLEOn.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.isbtnBLEOn.rawValue)
            defaults.synchronize()
        }
    }
    
    static var isEmailVerify: String {
        get {
            return UserDefaults.standard.string(forKey: DataKey.isEmailVerify.rawValue) ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: DataKey.isEmailVerify.rawValue)
            defaults.synchronize()
        }
    }
    
    static func removeUserName() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: DataKey.userName.rawValue)
        defaults.synchronize()
    }
    
    static func clearAllUserData() {
        
        let defaults = UserDefaults.standard
        
        let keysToRemove: [String] = [
            DataKey.UserID.rawValue,
            DataKey.userMode.rawValue,
            DataKey.ShouldShowTourScreen.rawValue,
            DataKey.lastOpenedTourScreen.rawValue,
            DataKey.BLENotify.rawValue,
            DataKey.timeStamp.rawValue,
            DataKey.arrCustomInterest.rawValue,
            DataKey.userName.rawValue,
            DataKey.isNetworkmode.rawValue,
            DataKey.referralInviteUrl.rawValue,
            DataKey.branchParam.rawValue,
            DataKey.BreakTheICE.rawValue,
            DataKey.transactionIdIAP.rawValue,
            DataKey.amountIAP.rawValue,
            DataKey.subscriptionDateIAP.rawValue,
            DataKey.isbtnBLEOn.rawValue,
            DataKey.isEmailVerify.rawValue
        ]
        
        for key in keysToRemove {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    //----------------------------------------------------------------------------------------------------
    // MARK: - NOT USED -
    //----------------------------------------------------------------------------------------------------
    //    static var timeStamp: Double {
    //        get {
    //            return UserDefaults.standard.double(forKey: DataKey.timeStamp.rawValue)
    //        }
    //        set {
    //            let defaults = UserDefaults.standard
    //            defaults.set(newValue, forKey: DataKey.timeStamp.rawValue)
    //            defaults.synchronize()
    //        }
    //    }
    
    //    static var arrCustomInterest: [String] {
    //        get {
    //            return UserDefaults.standard.stringArray(forKey: DataKey.arrCustomInterest.rawValue) ?? []
    //        }
    //        set {
    //            let defaults = UserDefaults.standard
    //            defaults.set(newValue, forKey: DataKey.arrCustomInterest.rawValue)
    //            // You don't need to synchronize UserDefaults for arrays; it's usually done automatically.
    //        }
    //    }
    
    //    static var arrCustomInterest: [InterestsList]? {
    //        get {
    //            if let data = UserDefaults.standard.data(forKey: DataKey.arrCustomInterest.rawValue) {
    //
    //                if let arrCustomInterest = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, InterestsList.self], from: data) as? [InterestsList] {
    //                    return arrCustomInterest
    //                }
    //            }
    //            // If the data object is nil, initialize arrCustomInterest to an empty array.
    //            return []
    //        }
    //        set {
    //            let defaults = UserDefaults.standard
    //            if let newValue = newValue {
    //
    //                if let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) {
    //                    defaults.set(data, forKey: DataKey.arrCustomInterest.rawValue)
    //                    defaults.synchronize()
    //                }
    //
    //            } else {
    //                defaults.removeObject(forKey: DataKey.arrCustomInterest.rawValue)
    //            }
    //        }
    //    }
}
