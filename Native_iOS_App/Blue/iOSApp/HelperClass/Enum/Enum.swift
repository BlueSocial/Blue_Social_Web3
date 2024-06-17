//
//  Enum.swift
//  Blue
//
//  Created by Blue.

import Foundation
import UIKit

// ----------------------------------------------------------
//                       MARK: - API Helper -
// ----------------------------------------------------------
enum PurchaseType: Int {
    case simple = 0,
         autoRenewable,
         nonRenewing
}

// ----------------------------------------------------------
//                       MARK: - Device Model -
// ----------------------------------------------------------
public enum Model: String {
    
    //Simulator
    case simulator          = "simulator/sandbox",
         
         //iPod
         iPod1              = "iPod 1",
         iPod2              = "iPod 2",
         iPod3              = "iPod 3",
         iPod4              = "iPod 4",
         iPod5              = "iPod 5",
         
         //iPad
         iPad2              = "iPad 2",
         iPad3              = "iPad 3",
         iPad4              = "iPad 4",
         iPadAir            = "iPad Air ",
         iPadAir2           = "iPad Air 2",
         iPadAir3           = "iPad Air 3",
         iPad5              = "iPad 5", //iPad 2017
         iPad6              = "iPad 6", //iPad 2018
         iPad7              = "iPad 7", //iPad 2019
         
         //iPad Mini
         iPadMini           = "iPad Mini",
         iPadMini2          = "iPad Mini 2",
         iPadMini3          = "iPad Mini 3",
         iPadMini4          = "iPad Mini 4",
         iPadMini5          = "iPad Mini 5",
         
         //iPad Pro
         iPadPro9_7         = "iPad Pro 9.7\"",
         iPadPro10_5        = "iPad Pro 10.5\"",
         iPadPro11          = "iPad Pro 11\"",
         iPadPro12_9        = "iPad Pro 12.9\"",
         iPadPro2_12_9      = "iPad Pro 2 12.9\"",
         iPadPro3_12_9      = "iPad Pro 3 12.9\"",
         
         //iPhone
         iPhone4            = "iPhone 4",
         iPhone4S           = "iPhone 4S",
         iPhone5            = "iPhone 5",
         iPhone5S           = "iPhone 5S",
         iPhone5C           = "iPhone 5C",
         iPhone6            = "iPhone 6",
         iPhone6Plus        = "iPhone 6 Plus",
         iPhone6S           = "iPhone 6S",
         iPhone6SPlus       = "iPhone 6S Plus",
         iPhoneSE           = "iPhone SE",
         iPhone7            = "iPhone 7",
         iPhone7Plus        = "iPhone 7 Plus",
         iPhone8            = "iPhone 8",
         iPhone8Plus        = "iPhone 8 Plus",
         iPhoneX            = "iPhone X",
         iPhoneXS           = "iPhone XS",
         iPhoneXSMax        = "iPhone XS Max",
         iPhoneXR           = "iPhone XR",
         iPhone11           = "iPhone 11",
         iPhone11Pro        = "iPhone 11 Pro",
         iPhone11ProMax     = "iPhone 11 Pro Max",
         iPhoneSE2          = "iPhone SE 2nd gen",
         iPhone13_1         = "iPhone 12 mini",
         iPhone13_2         = "iPhone 12",
         iPhone13_3         = "iPhone 12 Pro",
         iPhone13_4         = "iPhone 12 Pro Max",
         iPhone14_4         = "iPhone 13 mini",
         iPhone14_5         = "iPhone 13",
         iPhone14_2         = "iPhone 13 Pro",
         iPhone14_3         = "iPhone 13 Pro Max",
         iPhone12_8         = "iPhone SE (2nd generation)",
         iPhone14_6         = "iPhone SE (3rd generation)",
         
         //Apple TV
         AppleTV            = "Apple TV",
         AppleTV_4K         = "Apple TV 4K",
         unrecognized       = "?unrecognized?"
}

enum BLEDeviceScanType: String {
    
    case BLE        = "BLE"
    case NFC        = "NFC"
    case QR         = "QR"
    case Missed     = "Missed"
}

enum PostImageFor: String {
    
    case editProfile          = "editProfile"
    case newSocialNetworkData = "newSocialNetworkData"
    case customIcon           = "custom_icon"
    case customFile           = "custom_file"
    
    func type() -> String {
        return self.rawValue
    }
}

enum NavigationScreen {
    
    case currentUserProfile // Login User
    case switchProfile
    case discover // NearByUser
    case QRScan
    case deviceHistory // Interaction List
    case map
    case businessCardScan
    case notification
    case dynamicLink
    case none
}

enum RegisterNavigationScreen {
    
    case RegisterAddNetwork
    case LoginAddNetwork
    case None
}

enum PlanType: String {
    
    case MostPopular        = "Most Popular"
    case Exclusive          = "Exclusive"
    
    func type() -> String {
        return self.rawValue
    }
}

enum NotificationType: String {
    
    case View               = "1"
    case TapToBe            = "2"
    case Email              = "4"
    case Mobile             = "5"
    case AppUpdate          = "6"
    case AddFriend          = "3"
    case Notification       = "7"
    case ReceivedToken      = "8"
    case BreakTheIceSent    = "9"
    case BreakTheIceAccept  = "10"
    case BreakTheIceReject  = "11"
    case InProcessReject    = "12"
    case InRange            = "13"
    case Accepted           = "Accepted"
    case Decline            = "Decline"
    case TapToBes           = "TapToBe"
    case Event              = "Event"
    case TapToBeN           = "Tap To Be"
    case BLEAccept          = "BLEAccept"
    case BLEDecline         = "BLEDecline"
    
    func type() -> String {
        return self.rawValue
    }
}

enum DBVersion: String {
    
    case Blank         = ""
    case Zero          = "0"
    case First         = "1"
    case Second        = "2"
    case Third         = "3"
    
    func type() -> String {
        return self.rawValue
    }
}

enum BroadCastType: String {
    
    case User         = "User"
    case Event        = "Event"
    
    func type() -> String {
        return self.rawValue
    }
}

enum SocialNetworkCellType: String {
    
    case PhoneNumber             = "phonenumber"
    case Phone                   = "phone"
    case File                    = "custom_files"
    case Address                 = "address"
    case Email                   = "s_email"
    case email                   = "email"
    case Wechat                  = "wechat"
    case Paypal                  = "paypal"
    case Analytics               = "fb_analytics"
    case Resume                  = "resume"
    case Whatsapp                = "whatsapp"
    case CustomLink              = "customlink"
    case Zelle                   = "zelle"
    case Website                 = "website"
    case Calendly                = "calendly"
    case GoogleMyBusiness        = "googlemybusiness"
    case PokemonGo               = "pokemongo"
    case Linkedin                = "linkedin"
    case Slack                   = "slack"
    case EthereumAddress         = "ethereumaddress"
    case BitcoinWalletAddress    = "bitcoinwalletaddress"
    case PlayStation             = "playstation"
    case Xbox                    = "xbox"
    
    init(raw: String) {
        self = SocialNetworkCellType(rawValue: raw)!
    }
    
    func type() -> String {
        return self.rawValue
    }
}

enum SocialNetworkCategoryType: String  {
    
    case AnalysisAdvertising      = "Analysis/Advertising"
    case CustomFiles              = "CustomFiles"
    case CustomLinks              = "CustomLinks"
    case PersonalContacts         = "PersonalContacts"
    
    init(raw: String) {
        self = SocialNetworkCategoryType(rawValue: raw)!
    }
    
    func type() -> String {
        return self.rawValue
    }
}

enum SocialHintType: String {
    
    case full_link      = "full_link"
    case username       = "username"
    case paste_id       = "paste_id"
    
    init(raw: String) {
        self = SocialHintType(rawValue: raw)!
    }
    
    func type() -> String {
        return self.rawValue
    }
}

enum ProfileDataType: String  {
    
    case ProfileVisit      = "ProfileVisit"
    case SmartCard         = "SmartCard"
    case QRCard            = "QRCard"
    case ProfileSave       = "ProfileSave"
    case NearBy            = "NearBy"
    case TopLocation       = "TopLocation"
    case Gender            = "Gender"
    
    init(raw : String) {
        self = ProfileDataType(rawValue: raw)!
    }
    
    func type() -> String {
        return self.rawValue
    }
}

enum NFCOperationType {
    case WriteWithPassword
    case RemovePassword
}

// ----------------------------------------------------------
//                       MARK: - WebContent VC -
// ----------------------------------------------------------
enum ContentType {
    
    case Terms, PrivacyPolicy, Help, WorldHealthOraganization, BlueSocial, QuestionMark, DashboardQues, Shop, Invest, PreSale, QRCodeProfile, BuyTokens, WhitePaper
    
    public init(rawValue: Int) {
        
        switch rawValue {
            case 0:
                self = .Terms
                
            case 1:
                self = .PrivacyPolicy
                
            case 2:
                self = .Help
                
            case 3:
                self = .WorldHealthOraganization
                
            case 4:
                self = .BlueSocial
                
            case 5:
                self = .QuestionMark
                
            case 6:
                self = .DashboardQues
                
            case 7:
                self = .Shop
                
            case 8:
                self = .Invest
                
            case 9:
                self = .PreSale
                
            case 10:
                self = .QRCodeProfile
                
            case 11:
                self = .BuyTokens
                
            case 12:
                self = .WhitePaper
                
            default:
                self = .Terms
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - Navigation menu -
// ----------------------------------------------------------
//enum NavigationItem: CaseIterable {
//    
//    case bluePro
//    case activateSmartDevice
//    case shop
//    case feedback
//    case faq
//    case settings
//    case tellAFriend
//    // case logout
//    
//    var name: String {
//        
//        switch self {
//                
//            case .bluePro:
//                return "Blue Pro"
//                
//            case .activateSmartDevice:
//                return "Activate Smart Device"
//                
//            case .shop:
//                return "Shop"
//                
//            case .feedback:
//                return "Feedback"
//                
//            case .faq:
//                return "Tutorial"
//                
//            case .settings:
//                return "Settings"
//                
//            case .tellAFriend:
//                return "Tell A Friend"
//                
//                // case .logout:
//                // return "Log Out"
//        }
//    }
//    
//    var itemImage: UIImage {
//        
//        switch self {
//                
//            case .bluePro:
//                return UIImage(named: "ic_bluepro") ?? UIImage()
//                
//            case .activateSmartDevice:
//                return UIImage(named: "nfC") ?? UIImage()
//                
//            case .shop:
//                return UIImage(named: "shop") ?? UIImage()
//                
//            case .feedback:
//                return UIImage(named: "feedback") ?? UIImage()
//                
//            case .faq:
//                return UIImage(named: "faQ") ?? UIImage()
//                
//            case .settings:
//                return UIImage(named: "settings") ?? UIImage()
//                
//            case .tellAFriend:
//                return UIImage(named: "tellAFriend") ?? UIImage()
//                
//                // case .logout:
//        }
//    }
//}

// ----------------------------------------------------------
//                       MARK: - Production Service Type -
// ----------------------------------------------------------
enum ServiceType: Int {
    
    case sandbox
    case production
}

enum enumAttachmentType: String {
    
    case camera, photoLibrary
    case video
}

enum enumTransactionType: String {
    
    case all = "All"
    case proofOfInteraction = "Proof of Interaction"
    case breakTheIce = "Break the ice"
    case exchangeContact = "Exchange Contact"
    case received = "Received"
    case sentTokens = "Sent Tokens"
    case referral = "Referral"
}

enum ProfileType {
    
    case socialProfile
    case businessProfile
}

enum enumCalander: String {
    
    case week        = "Week"
    case month       = "Month"
    case year        = "Year"
}
