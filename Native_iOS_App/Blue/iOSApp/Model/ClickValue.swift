//
//  ClickValue.swift
//  Blue
//
//  Created by Blue.

import UIKit
import ObjectMapper

class ClickValue: Mappable {
    
    required init?(map: Map) {}
    
    var applemusic                  : Int?
    var facebook                    : Int?
    var instagram                   : Int?
    var link                        : Int?
    var linkedin                    : Int?
    var phone                       : Int?
    var pinterest                   : Int?
    var sEmail                      : Int?
    var snapchat                    : Int?
    var spotify                     : Int?
    var twitter                     : Int?
    var venmo                       : Int?
    var website                     : Int?
    var whatsapp                    : Int?
    var youtube                     : Int?
    var paypal                      : Int?
    var soundcloud                  : Int?
    var address                     : Int?
    var tidal                       : Int?
    var tiktok                      : Int?
    var cashapp                     : Int?
    var twitch                      : Int?
    var patreon                     : Int?
    var amazon                      : Int?
    var applepodcasts               : Int?
    var zelle                       : Int?
    var telegram                    : Int?
    var slack                       : Int?
    var discord                     : Int?
    var yelp                        : Int?
    var etsy                        : Int?
    var tumblr                      : Int?
    var vimeo                       : Int?
    var houseparty                  : Int?
    var calendly                    : Int?
    var wechat                      : Int?
    var resume                      : Int?
    
    func mapping(map: Map) {
        
        address                     <- map["address"]
        applemusic                  <- map["applemusic"]
        paypal                      <- map["paypal"]
        soundcloud                  <- map["soundcloud"]
        facebook                    <- map["facebook"]
        instagram                   <- map["instagram"]
        link                        <- map["link"]
        linkedin                    <- map["linkedin"]
        phone                       <- map["phone"]
        pinterest                   <- map["pinterest"]
        sEmail                      <- map["s_email"]
        snapchat                    <- map["snapchat"]
        spotify                     <- map["spotify"]
        twitter                     <- map["twitter"]
        venmo                       <- map["venmo"]
        website                     <- map["website"]
        whatsapp                    <- map["whatsapp"]
        youtube                     <- map["youtube"]
        tidal                       <- map["tidal"]
        tiktok                      <- map["tiktok"]
        cashapp                     <- map["cashapp"]
        twitch                      <- map["twitch"]
        patreon                     <- map["patreon"]
        amazon                      <- map["amazon"]
        applepodcasts               <- map["applepodcasts"]
        zelle                       <- map["zelle"]
        telegram                    <- map["telegram"]
        slack                       <- map["slack"]
        discord                     <- map["discord"]
        yelp                        <- map["yelp"]
        etsy                        <- map["etsy"]
        tumblr                      <- map["tumblr"]
        vimeo                       <- map["vimeo"]
        houseparty                  <- map["houseparty"]
        calendly                    <- map["calendly"]
        wechat                      <- map["wechat"]
        resume                      <- map["resume"]   
    }
}
