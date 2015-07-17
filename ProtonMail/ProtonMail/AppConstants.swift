//
//  AppConstants.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 6/4/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation


class AppConstants {

    static let CacheVersion : Int = 45
    static let AuthCacheVersion : Int = 3
    static let SpaceWarningThreshold: Double = 80
    
    static var AppVersion : Int = 1;
    static let BaseURLString : String = "https://api.protonmail.ch"
    //static let BaseURLString : String = "https://test-api.protonmail.ch"
    //private let BaseURLString = "http://protonmail.xyz"
    //static let BaseURLString : String = "http://feng.api.com"
    //private let BaseURLString = "https://dev-api.protonmail.ch"
    
    static var getDebugOption : String {
        get {
            #if DEBUG
                return "?XDEBUG_SESSION_START=\(18073)"
            #else
                return ""
            #endif
        }
    }
}