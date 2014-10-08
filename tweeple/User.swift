//
//  User.swift
//  tweeple
//
//  Created by Sahil Arora on 9/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User : NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var profileImageUrlBigger: String?
    var tagline: String?
    var isVerified: Bool?
    var userTagline: String?
    var followersCnt: Int?
    var followingCnt: Int?
    var tweetsCnt: Int?
        
    var dictionary: NSDictionary
 
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        isVerified = dictionary["verified"] as? Bool
        
        userTagline = dictionary["description"] as? String
        followersCnt = dictionary["followers_count"] as? Int
        followingCnt = dictionary["friends_count"] as? Int
        tweetsCnt = dictionary["statuses_count"] as? Int
        
        profileImageUrlBigger = profileImageUrl?.stringByReplacingOccurrencesOfString("normal", withString: "bigger")
        
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                var data = NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}