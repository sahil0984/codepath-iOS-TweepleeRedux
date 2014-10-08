//
//  Tweet.swift
//  tweeple
//
//  Created by Sahil Arora on 9/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class Tweet : NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var retweetedStatus: NSDictionary?
    var retweetedId: String?
    var isFavorited: Bool?
    var isRetweeted: Bool?
    var retweetedCount: Int?
    var favoritedCount: Int?
    
    var tweetIdString: String?
    
    var mediaUrl: String?
    
    var retweetByUser: User?
    
    init (dictionary: NSDictionary) {
        
        retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        
        if (retweetedStatus) != nil {
            
            user = User(dictionary: retweetedStatus!["user"] as NSDictionary)
            text = retweetedStatus!["text"] as? String
            
            retweetByUser = User(dictionary: dictionary["user"] as NSDictionary)
            
        } else {
            
            user = User(dictionary: dictionary["user"] as NSDictionary)
            text = dictionary["text"] as? String
            
        }
        
        retweetedId = nil
        
        createdAtString = dictionary["created_at"] as? String
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        
        isFavorited = dictionary["favorited"] as? Bool
        isRetweeted = dictionary["retweeted"] as? Bool
        
        retweetedCount = dictionary["retweet_count"] as? Int
        favoritedCount = 0 //dictionary[""] as? String
        
        tweetIdString = dictionary["id_str"] as? String
        
        var extendedEntities = dictionary["extended_entities"] as? NSDictionary
        if extendedEntities != nil {
            var mediaEntities = extendedEntities!["media"] as? [NSDictionary]
            mediaUrl = (mediaEntities![0])["media_url"] as? String
            println("Ext: \(mediaUrl)")
        } else {
            mediaUrl = nil
        }

    }
    
    override init() {
        
    }
    
    
    class func tweetsWithArray (array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}