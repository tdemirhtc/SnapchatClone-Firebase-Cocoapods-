//
//  userSingleton.swift
//  SnapchatClone
//
//  Created by Hatice Taşdemir on 5.11.2024.
//

import Foundation


class userSingleton{
    
    static let sharedUserInfo = userSingleton()
    
    var email = ""
    var username = ""
    
    private init(){
        
    }
}
