//
//  ContainerViewController.swift
//  tweeple
//
//  Created by Sahil Arora on 10/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetsViewDelegate {

    
    @IBOutlet weak var contentViewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    var tweets: [Tweet] = [Tweet]()

    var sidebarWidth: CGFloat?
    var initPanPositionX: CGFloat?
    var initContentViewConstraintX: CGFloat?
    var panDirection: Bool?
    
    var menuItemNames = ["Profile",
                         "Home Timeline",
                         "Mentions"]
    
    var menuIconFileNames = ["profile",
                             "home",
                             "mentions"]
    
    
    var profileViewController: UINavigationController!
    var homeTimelineViewController: UINavigationController!
    var mentionsTimelineViewController: UINavigationController!
    
    var viewControllers: [UIViewController]!
    
    override func viewDidAppear(animated: Bool) {
        //Adding a new viewController to the parent
        self.addChildViewController(self.homeTimelineViewController) //viewWillAppear + rotate call
        self.homeTimelineViewController.view.frame = self.contentView.bounds
        self.contentView.addSubview(self.homeTimelineViewController.view)
        self.homeTimelineViewController.didMoveToParentViewController(self) //viewDidAppear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //containerView.
        contentViewXConstraint.constant = 0//-100
        self.sidebarWidth = -250.0
        
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.rowHeight = UITableViewAutomaticDimension
        
        
        userImageView.setImageWithURL(NSURL(string: (User.currentUser?.profileImageUrlBigger)!))
        userNameLabel.text = User.currentUser?.name
        
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        profileViewController = storyboard.instantiateViewControllerWithIdentifier("profileViewNavigationController") as UINavigationController
        
        homeTimelineViewController = storyboard.instantiateViewControllerWithIdentifier("tweetsViewNavigationController") as UINavigationController
        
        mentionsTimelineViewController = storyboard.instantiateViewControllerWithIdentifier("tweetsViewNavigationController") as UINavigationController
        
        viewControllers = [profileViewController.viewControllers[0] as ProfileViewController,
                           homeTimelineViewController.viewControllers[0] as TweetsViewController,
                           mentionsTimelineViewController.viewControllers[0] as TweetsViewController]
        
        (viewControllers[1] as TweetsViewController).delegate = self
        (viewControllers[2] as TweetsViewController).delegate = self


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchTweetsForViewController(viewController: TweetsViewController, params: NSDictionary?) -> Void {
        
        if viewController == viewControllers[0] {
            println("called from profile")
        } else if viewController == viewControllers[1] {
            TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: { (tweets, error) -> () in
                if error != nil {
                    println(error)
                } else {
                    if tweets?.count > 0 {
                        for (var i=0; i<tweets?.count; i++) {
                            (self.viewControllers[1] as TweetsViewController).tweets.append(tweets![i])
                        }
                        //(self.viewControllers[1] as TweetsViewController).tweets = tweets!
                        (self.viewControllers[1] as TweetsViewController).tweetsTableView.reloadData()
                        
                        var lastTweet = (self.viewControllers[1] as TweetsViewController).tweets[((self.viewControllers[1] as TweetsViewController).tweets.count)-1]
                        var max_id_int = (((lastTweet.tweetIdString)!).toInt()! - 1)
                        (self.viewControllers[1] as TweetsViewController).max_id = "\(max_id_int)"
                    }
                }
            })
        } else if viewController == viewControllers[2] {
            TwitterClient.sharedInstance.mentionsTimelineWithParams(params, completion: { (tweets, error) -> () in
                if error != nil {
                    println(error)
                } else {
                    if tweets?.count > 0 {
                        for (var i=0; i<tweets?.count; i++) {
                            (self.viewControllers[2] as TweetsViewController).tweets.append(tweets![i])
                        }
                        //(self.viewControllers[1] as TweetsViewController).tweets = tweets!
                        (self.viewControllers[2] as TweetsViewController).tweetsTableView.reloadData()
                        
                        var lastTweet = (self.viewControllers[2] as TweetsViewController).tweets[((self.viewControllers[2] as TweetsViewController).tweets.count)-1]
                        var max_id_int = (((lastTweet.tweetIdString)!).toInt()! - 1)
                        (self.viewControllers[2] as TweetsViewController).max_id = "\(max_id_int)"
                    }
                }
            })
        } else {
            println("called from else")
        }
        println("delegate called")
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var menuCell = tableView.dequeueReusableCellWithIdentifier("sideMenuCell") as SideMenuTableViewCell
        switch indexPath.row {
        case 0:
            menuCell.menuItemLabel.text = menuItemNames[indexPath.row]
            //let iconImage = UIImage(named: menuIconFileNames[indexPath.row]) as UIImage
            let iconImage = UIImage(named: "profile") as UIImage
            menuCell.menuIconImageView.image = iconImage
        case 1:
            menuCell.menuItemLabel.text = menuItemNames[indexPath.row]
            //let iconImage = UIImage(named: menuIconFileNames[indexPath.row]) as UIImage
            let iconImage = UIImage(named: "retweet") as UIImage
            menuCell.menuIconImageView.image = iconImage
        case 2:
            menuCell.menuItemLabel.text = menuItemNames[indexPath.row]
            //let iconImage = UIImage(named: menuIconFileNames[indexPath.row]) as UIImage
            let iconImage = UIImage(named: "mentions") as UIImage
            menuCell.menuIconImageView.image = iconImage
        default:
            println("no icon")
        }

        
        return menuCell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        println("selected menu item \(indexPath.row)")
        
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.contentViewXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        
        switch indexPath.row {
        case 0:
            //Removing an existing viewController from the parent
            self.profileViewController.willMoveToParentViewController(nil) // viewWillDisappear
            self.profileViewController.view.removeFromSuperview()
            self.profileViewController.didMoveToParentViewController(nil) //viewDidDisappear
            
            (self.viewControllers[0] as ProfileViewController).profileUser = User.currentUser
            
            //Adding a new viewController to the parent
            self.addChildViewController(self.profileViewController) //viewWillAppear + rotate call
            self.profileViewController.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.profileViewController.view)
            self.profileViewController.didMoveToParentViewController(self) //viewDidAppear
        case 1:
            //Removing an existing viewController from the parent
            self.homeTimelineViewController.willMoveToParentViewController(nil) // viewWillDisappear
            self.homeTimelineViewController.view.removeFromSuperview()
            self.homeTimelineViewController.didMoveToParentViewController(nil) //viewDidDisappear
            
            
            //Adding a new viewController to the parent
            self.addChildViewController(self.homeTimelineViewController) //viewWillAppear + rotate call
            self.homeTimelineViewController.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.homeTimelineViewController.view)
            self.homeTimelineViewController.didMoveToParentViewController(self) //viewDidAppear
        case 2:
            //Removing an existing viewController from the parent
            self.mentionsTimelineViewController.willMoveToParentViewController(nil) // viewWillDisappear
            self.mentionsTimelineViewController.view.removeFromSuperview()
            self.mentionsTimelineViewController.didMoveToParentViewController(nil) //viewDidDisappear
            
            
            //Adding a new viewController to the parent
            self.addChildViewController(self.mentionsTimelineViewController) //viewWillAppear + rotate call
            self.mentionsTimelineViewController.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.mentionsTimelineViewController.view)
            self.mentionsTimelineViewController.didMoveToParentViewController(self) //viewDidAppear
        default:
            println("Not a valid selection")
        }
        

    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            initContentViewConstraintX = contentViewXConstraint.constant
            initPanPositionX = sender.locationInView(view.superview).x
            println("Pan started")
        } else if sender.state == UIGestureRecognizerState.Changed {
            println("Pan changed")
            var currPanPositionX = sender.locationInView(view.superview).x
            var deltaPanPosition = currPanPositionX - initPanPositionX!
            var newPanPositionX = initContentViewConstraintX! - deltaPanPosition
            
            if newPanPositionX <= 0 && newPanPositionX >= self.sidebarWidth {
                self.contentViewXConstraint.constant = newPanPositionX
            } else if newPanPositionX > 0 {
                self.contentViewXConstraint.constant = 0
            } else if newPanPositionX < self.sidebarWidth {
                self.contentViewXConstraint.constant = self.sidebarWidth!
            }
            
            
            if deltaPanPosition > 0 {
                self.panDirection = true
            } else {
                self.panDirection = false
            }
            
            //println("curr: \(self.contentViewXConstraint.constant)")
            //println("new: \(newPanPositionX)")
            //println("delta: \(deltaPanPosition)")
        } else if sender.state == UIGestureRecognizerState.Ended {
            println("Pan ended")
            //initPanPosition = nil
            
            if initContentViewConstraintX == self.sidebarWidth && !panDirection! {
                UIView.animateWithDuration(0.35, animations: { () -> Void in
                    self.contentViewXConstraint.constant = 0
                    self.view.layoutIfNeeded()
                })
            } else if initContentViewConstraintX == 0 && panDirection! {
                UIView.animateWithDuration(0.35, animations: { () -> Void in
                    self.contentViewXConstraint.constant = self.sidebarWidth!
                    self.view.layoutIfNeeded()
                })
            }
            
        }
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
