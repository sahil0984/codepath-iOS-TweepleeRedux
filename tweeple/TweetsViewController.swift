//
//  ViewController.swift
//  tweeple
//
//  Created by Sahil Arora on 9/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol TweetsViewDelegate {
    func fetchTweetsForViewController(viewController: TweetsViewController, params: NSDictionary?) -> Void
}
protocol TweetsTableViewScrollDelegate {
    func tweetTableViewScrolled(CGFloat) -> Void
}

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetCellButtonDelegate, TweetDetailsViewControllerDelegate {
    
    var tweets: [Tweet] = []
    var refreshControl:UIRefreshControl!
    
    var max_id: String = "0"
    
    var templateTweet = Tweet()
    
    var delegate: TweetsViewDelegate?
    var scrollDelegate: TweetsTableViewScrollDelegate?
    
    var headerHeight: CGFloat = 300.0
    var scrollTableOffset: CGFloat = -64.0



    @IBOutlet weak var newTweetButton: UIBarButtonItem!
    @IBOutlet weak var tweetsTableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        self.tweetsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tweetsTableView.dataSource = self
        self.tweetsTableView.delegate = self
        self.tweetsTableView.rowHeight = UITableViewAutomaticDimension
        

        //Set the correct color for Navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 85.0/256.0, green: 172.0/256.0, blue: 238.0/256.0, alpha: 0.55)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        delegate?.fetchTweetsForViewController(self, params: nil)
        
        //Logic to implement pull to refresh on table view
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching new Tweets")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        //self.tweetsTableView.addSubview(refreshControl)
        self.tweetsTableView.insertSubview(refreshControl, atIndex: 0)
        
        
//        var storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        var profileViewController = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as ProfileViewController
//        
//        var myHeaderView = profileViewController.headerView as UIView
//        self.tweetsTableView.tableHeaderView = myHeaderView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as TweetsTableViewCell
        
        cell.tweet = self.tweets[indexPath.row]
        cell.delegate = self
        
        println("At row: \(indexPath.row)")
        if indexPath.row == (self.tweets.count - 1) {
            
            var params: [String:String] = [String:String]()
            
            params["max_id"] = max_id
            
            
            delegate?.fetchTweetsForViewController(self, params: params)

//            TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: { (tweets: [Tweet]?, error: NSError?) -> () in
//                if error != nil {
//                    println(error)
//                } else {
//                    for (var i=0; i<tweets!.count; i++) {
//                        self.tweets.append(tweets![i])
//                    }
//                    //self.tweets = tweets!
//                    self.tweetsTableView.reloadData()
//                    
//                    var lastTweet = self.tweets[self.tweets.count-1]
//                    var max_id_int = ((lastTweet.tweetIdString!).toInt()! - 1)
//                    self.max_id = "\(max_id_int)"
//                }
//            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as ProfileHeaderTableViewCell
//        
//        headerCell.profileUser = User.currentUser
//        
//        return headerCell
//    }
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return headerHeight
//    }
//    
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        println("didScroll")
//        println("\(scrollView.contentOffset.y)")
//        
//        if scrollView.contentOffset.y == -64.0 {
//            headerHeight = 300.0
//        }
//        
//        headerHeight = 300.0 + scrollTableOffset - scrollView.contentOffset.y
//        //tweetsTableView.cellForRowAtIndexPath(<#indexPath: NSIndexPath#>)
//    
//        
//        tweetsTableView.reloadData()
//    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollDelegate?.tweetTableViewScrolled((scrollView.contentOffset.y))
    }
    
    
    @IBAction func onSignOut(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
//        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
//            if error != nil {
//                println("error: \(error)")
//            } else {
//                self.tweets = tweets!
//                self.tweetsTableView.reloadData()
//                
//                var lastTweet = self.tweets[self.tweets.count-1]
//                var max_id_int = ((lastTweet.tweetIdString!).toInt()! - 1)
//                self.max_id = "\(max_id_int)"
//            }
//        })

        delegate?.fetchTweetsForViewController(self, params: nil)

        self.refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //if sender as UIBarButtonItem == newTweetButton {
        if segue.identifier == "newTweet" {
            println("newTweet")
            
            var composeNavigationController = segue.destinationViewController as UINavigationController
            var composeViewController = composeNavigationController.viewControllers[0] as ComposeViewController
            
            composeViewController.delegate = self
            
        } else if segue.identifier == "replyTweet" || segue.identifier == "retweetTweet" {
            println("replyTweet")
            
            var composeNavigationController = segue.destinationViewController as UINavigationController
            var composeViewController = composeNavigationController.viewControllers[0] as ComposeViewController
            
            composeViewController.templateTweet = templateTweet
            if segue.identifier == "replyTweet" {
                composeViewController.newTweetType = 1
            } else if segue.identifier == "retweetTweet" {
                composeViewController.newTweetType = 2
            }
            
            composeViewController.delegate = self
        } else if segue.identifier == "tweetDetails" {
            println("detailTweet")
            
            var tweetDetailsController = segue.destinationViewController as TweetDetailsViewController

            var i = self.tweetsTableView.indexPathForSelectedRow()?.row
            tweetDetailsController.currTweet = tweets[i!]
            
            tweetDetailsController.delegate = self
        } else if segue.identifier == "profileSegue" {
            println("profile")
            
            var profileViewController = segue.destinationViewController as ProfileViewController
            //var profileViewController = profileNavigationController.viewControllers[0] as ProfileViewController
            
            //profileViewController.navigationController?.navigationBar.hidden = true
            profileViewController.profileUser = sender as? User
            profileViewController.isBack = true
    
        }
 
    }
    
    func newTweetPosted(newTweetObj: Tweet, showOnTimeline: Bool) {
        if showOnTimeline == true {
            tweets.insert(newTweetObj, atIndex: 0)
        } else {
            assignModifiedTweetToTweets(newTweetObj)
        }
        println("\(newTweetObj.isRetweeted)")
        tweetsTableView.reloadData()
    }
    
    func tweetCellButtonSelected(tweetCellButtonSelected: TweetsTableViewCell, action: String) {
        var indexPath = self.tweetsTableView.indexPathForCell(tweetCellButtonSelected) as NSIndexPath!
        
        println("Action pressed for cell: \(indexPath.row)")
        templateTweet = tweets[indexPath.row]
        
        if action == "favorite" {
            var params: [String:String] = [String:String]()
            
            params["id"] = templateTweet.tweetIdString
            
            TwitterClient.sharedInstance.postToggleFavorite(params, isFav: templateTweet.isFavorited!, completion: { (tweet, error) -> () in
                //Do something
            })
            tweets[indexPath.row].isFavorited = !(templateTweet.isFavorited!)
            if tweets[indexPath.row].isFavorited == false {
                tweets[indexPath.row].favoritedCount = tweets[indexPath.row].favoritedCount! - 1
            } else {
                tweets[indexPath.row].favoritedCount = tweets[indexPath.row].favoritedCount! + 1
            }
            tweetsTableView.reloadData()
        }
        
    }
    
    func tweetProfileImageSelected(user: User) {
        //var profileViewController =
        println("profile called for \((user.name)!)")
        
        self.performSegueWithIdentifier("profileSegue", sender: user)
    }
    
    func tweetFavoriteToggled(favoriteToggledTweet: Tweet) {
        
        assignModifiedTweetToTweets(favoriteToggledTweet)

        tweetsTableView.reloadData()
    }
    
    func assignModifiedTweetToTweets (modifiedTweet: Tweet) {
        var tweetId = modifiedTweet.tweetIdString
        
        for (var i=0; i<tweets.count; i++) {
            if tweets[i].tweetIdString == tweetId {
                tweets[i] = modifiedTweet
                break
            }
        }
    }
    
}

