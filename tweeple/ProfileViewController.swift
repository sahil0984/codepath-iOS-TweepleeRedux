//
//  ProfileViewController.swift
//  tweeple
//
//  Created by Sahil Arora on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit



class ProfileViewController: UIViewController, UIScrollViewDelegate, TweetsTableViewScrollDelegate {
    
    @IBOutlet weak var viewTopMarginConst: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var bannerImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerImageViewTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageViewTopMarginConst: NSLayoutConstraint!
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var titleTweetsCntLabel: UILabel!
    @IBOutlet weak var titleLabelTopMargin: NSLayoutConstraint!
    
    func tweetTableViewScrolled(scrollYPos: CGFloat) {
        println("Scroll captured: \(scrollYPos)")
        var savedScrollYPos2: CGFloat!
        
        if scrollYPos <= 0.0 && scrollYPos > -200.0 {
            bannerImageViewTopMargin.constant = 0
            viewTopMarginConst.constant = 0

            bannerImageViewHeight.constant = 50 - scrollYPos
            //profileImageViewTopMarginConst.constant = 60 - scrollYPos

            titleNameLabel.hidden = true
            titleTweetsCntLabel.hidden = true
        }
        
        if scrollYPos > 0.0 && scrollYPos < 75.0 {
            viewTopMarginConst.constant = 0 - scrollYPos
            
            titleNameLabel.hidden = true
            titleTweetsCntLabel.hidden = true
        }
        
        if scrollYPos >= 75.0 && scrollYPos < 100.0 {
            savedScrollYPos2 = 74.9
            profileImageViewTopMarginConst.constant = 60 - (scrollYPos - savedScrollYPos2)
            
            titleNameLabel.hidden = false
            titleTweetsCntLabel.hidden = false
            
            
            titleLabelTopMargin.constant = 45 - (scrollYPos - savedScrollYPos2)
            
            titleNameLabel.alpha = (scrollYPos-75.0)/25.0
            titleTweetsCntLabel.alpha = (scrollYPos-75.0)/25.0


        }
        
        if scrollYPos >= 100.0 {
            savedScrollYPos2 = 74.9
            profileImageViewTopMarginConst.constant = 60 - (scrollYPos - savedScrollYPos2)
            
            titleNameLabel.hidden = false
            titleTweetsCntLabel.hidden = false
        }
        
//        if scrollYPos == 75.0 {
//            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
//            visualEffectView.frame = userBannerImageView.bounds
//            userBannerImageView.addSubview(visualEffectView)
//        }
        
        self.userTimelineViewController.view.frame = self.userTimelineView.bounds
    }
    
    var userTimelineViewController: TweetsViewController!
    
    @IBOutlet weak var userTimelineView: UIView!
    @IBOutlet weak var userBannerImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreennameLabel: UILabel!
    @IBOutlet weak var userTaglineLabel: UILabel!
    @IBOutlet weak var userFollowingCntLabel: UILabel!
    @IBOutlet weak var userFollowersCntLabel: UILabel!
    @IBOutlet weak var userTweetsCntLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newTweetButton: UIButton!
    
    var profileUser: User?
    var isBack: Bool = false
    
    var tweets: [Tweet] = [Tweet]()
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        if isBack {
            self.backButton.hidden = false
        } else {
            self.backButton.hidden = true
        }
        
        if profileUser?.screenname == User.currentUser?.screenname {
            self.newTweetButton.hidden = false
        } else {
            self.newTweetButton.hidden = true
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.navigationBar.hidden = false
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        titleNameLabel.text = profileUser?.name
        titleTweetsCntLabel.text = "\((profileUser?.tweetsCnt)!) Tweets"
        titleNameLabel.hidden = true
        titleTweetsCntLabel.hidden = true
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        userTimelineViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as TweetsViewController
        
        userTimelineViewController.scrollDelegate = self
        
        //Populate header items
        var params: [String: String] = [String:String]()
        params["screen_name"] = profileUser?.screenname!
        TwitterClient.sharedInstance.userBannerWithParams(params, completion: { (bannerUrl: String?, error: NSError?) -> () in
            if error != nil {
                println(error)
            } else {
                self.userBannerImageView.setImageWithURL(NSURL(string: (bannerUrl)!))
            }
        })
        
        userNameLabel.text = profileUser?.name
        userScreennameLabel.text = profileUser?.screenname
        userProfileImageView.setImageWithURL(NSURL(string: (profileUser?.profileImageUrlBigger)!))
        userTaglineLabel.text = profileUser?.userTagline
        userFollowersCntLabel.text = "\((profileUser?.followersCnt)!)"
        userFollowingCntLabel.text = "\((profileUser?.followingCnt)!)"
        userTweetsCntLabel.text = "\((profileUser?.tweetsCnt)!)"
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        //userImageView.setImageWithURL(NSURL(string: (User.currentUser?.profileImageUrlBigger)!))
        
        var params: [String:String] = [String:String]()
        
        params["screen_name"] = profileUser?.screenname
        TwitterClient.sharedInstance.userTimelineWithParams(params, completion: { (tweets, error) -> () in
            if error != nil {
                println(error)
            } else {
                if tweets?.count > 0 {
                    for (var i=0; i<tweets!.count; i++) {
                        self.userTimelineViewController.tweets.append(tweets![i])
                    }
                    //(self.viewControllers[1] as TweetsViewController).tweets = tweets!
                    self.userTimelineViewController.tweetsTableView.reloadData()
                    
                    var lastTweet = self.userTimelineViewController.tweets[(self.userTimelineViewController.tweets.count)-1]
                    var max_id_int = (((lastTweet.tweetIdString)!).toInt()! - 1)
                    self.userTimelineViewController.max_id = "\(max_id_int)"
                }
            }
        })
        
        
        //Adding a new viewController to the parent
        self.addChildViewController(self.userTimelineViewController) //viewWillAppear + rotate call
        self.userTimelineViewController.view.frame = self.userTimelineView.bounds
        self.userTimelineView.addSubview(self.userTimelineViewController.view)
        self.userTimelineViewController.didMoveToParentViewController(self) //viewDidAppear
        self.view.layoutIfNeeded()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
