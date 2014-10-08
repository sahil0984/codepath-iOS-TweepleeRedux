//
//  TwitterClient.swift
//  tweeple
//
//  Created by Sahil Arora on 9/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

let twitterConsumerKey = "fuyZmUGh0x902HXGviIfbgCnw"
let twitterConsumerSecret = "1L1KcaxKvn0L1VWnuoyG1gT4ITSBbReAaSIISo0gLpTWez4UOl"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)

        }
        return Static.instance
    }
    
    func homeTimelineWithParams (params: NSDictionary?, completion:  (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("timeline: \(response)")
            var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
            
            for tweet in tweets {
                println("text: \(tweet.text), created: \(tweet.createdAt)")
            }
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("error getting timeline")
            completion(tweets: nil, error: error)
        })
    }

    func mentionsTimelineWithParams (params: NSDictionary?, completion:  (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/mentions_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("timeline: \(response)")
            var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
            
            for tweet in tweets {
                println("text: \(tweet.text), created: \(tweet.createdAt)")
            }
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting timeline")
                completion(tweets: nil, error: error)
        })
    }
    
    func userTimelineWithParams (params: NSDictionary?, completion:  (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/user_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("timeline: \(response)")
            var tweets = Tweet.tweetsWithArray(response as [NSDictionary])
            
            for tweet in tweets {
                println("text: \(tweet.text), created: \(tweet.createdAt)")
            }
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting timeline")
                completion(tweets: nil, error: error)
        })
    }
    
    func postTweetWithParams (params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("https://api.twitter.com/1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("Tweet posted successfully")
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("Error posting a tweet: \(error)")
        })
    }
    
    func postRetweet (tweetId: NSString?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("https://api.twitter.com/1.1/statuses/retweet/\(tweetId!).json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            var tweet = Tweet(dictionary: response as NSDictionary)
            
            completion(tweet: tweet, error: nil)
            
            println("Retweet posted successfully")
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("Error posting a retweet: \(error)")
            completion(tweet: nil, error: error)
        })
    }
    
    func destroyRetweet (tweetId: NSString?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("https://api.twitter.com/1.1/statuses/destroy/\(tweetId!).json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("Retweet destroyed successfully")
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("Error destroying retweet: \(error)")
        })
    }
    
    func postToggleFavorite (params: NSDictionary?, isFav: Bool, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var urlString: NSString
        if isFav == true {
            urlString = "destroy"
        } else {
            urlString = "create"
        }
        POST("https://api.twitter.com/1.1/favorites/\(urlString).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println("Tweet favorited successfully")
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("Error favoriting a tweet:")
                println("\(error)")

        })
    }
    
    
    
    func loginWithCompletion (completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // Fetch my request token and redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "tweeplee://oauth"), scope: nil, success: { (requestToken: BDBOAuthToken!) -> Void in
            println("Got the request token")
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL)
        }) { (error: NSError!) -> Void in
                println("Failed to get the request token.")
                self.loginCompletion?(user: nil, error: error)
        }
        
    }
    
    
    func userBannerWithParams (params: NSDictionary?, completion:  (bannerUrl: String?, error: NSError?) -> ()) {
        GET("1.1/users/profile_banner.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println("timeline: \(response)")
            var banners = response as NSDictionary
            var bannerSizes = banners["sizes"] as NSDictionary
            var bannerDict = bannerSizes["mobile_retina"] as NSDictionary
            var bannerUrl = bannerDict["url"] as String

            completion(bannerUrl: bannerUrl, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting timeline")
                completion(bannerUrl: nil, error: error)
        })
    }
    
    func openUrl (url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuthToken(queryString: url.query), success: { (accessToken: BDBOAuthToken!) -> Void in
            println("Got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //println("user: \(response)")
                var user = User(dictionary: response as NSDictionary)
                User.currentUser = user
                println("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting current user")
                self.loginCompletion?(user: nil, error: error)

            })
            
        }) { (error: NSError!) -> Void in
            println("Failed to receive access token")
            self.loginCompletion?(user: nil, error: error)
        }
    }
    

    
    
   
}
