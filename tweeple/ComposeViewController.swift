//
//  ComposeViewController.swift
//  tweeple
//
//  Created by Sahil Arora on 9/28/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol ComposeViewControllerDelegate {
    func newTweetPosted(newTweetObj : Tweet, showOnTimeline : Bool) -> Void
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var currNameLabel: UILabel!
    @IBOutlet weak var currUsernameLabel: UILabel!
    @IBOutlet weak var currProfileImageView: UIImageView!
    
    @IBOutlet weak var newTweet: UITextView!
    @IBOutlet weak var charCount: UILabel!
    
    @IBOutlet weak var tweetButton: UIButton!
    
    var newTweetFont: UIFont!

    var delegate: ComposeViewControllerDelegate?
    var templateTweet: Tweet?
    var newTweetType: Int? = 0 // 0=newTweet or default
                               // 1=reply
                               // 2=retweet
    
    let newTweetDefaultText = "Compose a new Tweet..."
    //let newTweetDefaultTextLength = "0"
    var tweetTextLengthLeft = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newTweet.delegate = self
        
        AddEmptyTweetHint()
        
        currNameLabel.text = User.currentUser?.name
        currUsernameLabel.text = "@\((User.currentUser?.screenname)!)"
        currProfileImageView.setImageWithURL(NSURL(string: (User.currentUser?.profileImageUrlBigger)!))
        
        
        var templateTweetText = templateTweet?.text as NSString!
        if templateTweetText? != nil {
            var tweetText: NSString

            if newTweetType == 1 {
                //Reply:
                //Set the usernames of retweetedByUser, postedByUser and anyone tagged
                if templateTweet?.retweetedStatus != nil {
                    tweetText = "@\((templateTweet?.retweetByUser?.screenname)!) "
                } else {
                    tweetText = ""
                }
                tweetText = tweetText + "@\((templateTweet?.user?.screenname)!) "
                newTweet.text = tweetText
                tweetTextLengthLeft = 140 - tweetText.length
                charCount.text = "\(tweetTextLengthLeft)"
                setTweetFont()
            } else if newTweetType == 2 {
                //Retweet:
                //Set the text same as original tweet
                //Set it not editable
                tweetText = templateTweetText
                newTweet.text = tweetText
                newTweet.editable = false
                tweetTextLengthLeft = 140 - tweetText.length
                charCount.text = "\(tweetTextLengthLeft)"
                setTweetFont()
            }
        }
        
        if templateTweet?.isRetweeted == true {
            tweetButton.setTitle("X-Retweet", forState: UIControlState.Normal)
        }
        
        newTweetFont = newTweet.font
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        println("text changed1")
        var tweetText = newTweet.text as NSString
        tweetTextLengthLeft = 140 - tweetText.length
        charCount.text = "\(tweetTextLengthLeft)"
        
        if tweetTextLengthLeft < 0 {
            charCount.textColor = UIColor.redColor()
        } else {
            charCount.textColor = UIColor.blackColor()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        println("text changed2")
        //newTweet.textColor = UIColor.blackColor()
        //newTweet.font = UIFont.systemFontOfSize(14)
        setTweetFont()

        if tweetTextLengthLeft == 140 {
            newTweet.text = ""
        }
        return true
    }
    
    
    @IBAction func onTweet(sender: AnyObject) {
        //Call POST API to post a tweet
        
        if tweetTextLengthLeft >= 0 && tweetTextLengthLeft != 140 {
            
            //Create a newTweetObj to send back to TweetsViewController
            var newTweetObj = Tweet()
            
            newTweetObj.user = User.currentUser
            newTweetObj.text = newTweet.text
            newTweetObj.createdAt = NSDate()
            //newTweetObj.createdAtString = NSDate() as String
            newTweetObj.retweetedStatus = nil
            newTweetObj.isFavorited = false
            newTweetObj.isRetweeted = false
            newTweetObj.retweetedCount = 0
            newTweetObj.favoritedCount = 0
            newTweetObj.retweetByUser = nil
            
            var params: [String:String] = [String:String]()
            
            params["status"] = newTweet.text
            
            var tweetVisible = false
            
            if newTweetType == 1 { //Reply
                params["in_reply_to_status_id"] = templateTweet?.tweetIdString
                tweetVisible = true
            } else if newTweetType == 0 {
                tweetVisible = true
            }
            
            if newTweetType == 2 { //Retweet
                newTweetObj = templateTweet!
                
                if templateTweet?.isRetweeted == false {
                    TwitterClient.sharedInstance.postRetweet(templateTweet?.tweetIdString, completion: { (tweet: Tweet?, error: NSError?) -> () in
                        //Do something
                        //newTweetObj.retweetedStatusId = tweet.
                        //var retTweet = tweet
                        newTweetObj.retweetedId = tweet?.tweetIdString
                        println("retweetedId:\(newTweetObj.retweetedId)")
                    })
                    newTweetObj.isRetweeted = true
                    newTweetObj.retweetedCount = newTweetObj.retweetedCount! + 1
                    
                } else {
                    
                    println("retweetStatus:\(templateTweet?.isRetweeted)")
                    println("tweetId:\(templateTweet?.tweetIdString)")
                    println("retweetedId:\(templateTweet?.retweetedId)")
                    TwitterClient.sharedInstance.destroyRetweet(templateTweet?.retweetedId, completion: { (tweet, error) -> () in
                        //Do something
                    })
                    newTweetObj.isRetweeted = false
                    newTweetObj.retweetedStatus = nil
                    newTweetObj.retweetedCount = newTweetObj.retweetedCount! - 1
                }
                println("retweetStatus:\(newTweetObj.isRetweeted)")
                println("tweetId:\(newTweetObj.tweetIdString)")
                println("retweetedId:\(templateTweet?.retweetedId)")
            } else {
                TwitterClient.sharedInstance.postTweetWithParams(params, completion: { (tweet, error) -> () in
                    //Do something
                })
            }

            delegate?.newTweetPosted(newTweetObj, showOnTimeline: tweetVisible)
            
            
            
            self.dismissViewControllerAnimated(true, completion: nil)

        } else {
            //Send message to user about the length
        }
        

    }
    

    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
        
        AddEmptyTweetHint()
    }
    
    func AddEmptyTweetHint() {
        if tweetTextLengthLeft == 140 {
            charCount.text = "\(tweetTextLengthLeft)"
            newTweet.text = newTweetDefaultText
            setHintFont()
        }
        
    }
    
    func setHintFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        newTweet.textColor = UIColor.grayColor()
        //newTweet.toggleItalics(self)
    }
    func setTweetFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        //newTweet.toggleItalics(self)
        newTweet.textColor = UIColor.blackColor()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
