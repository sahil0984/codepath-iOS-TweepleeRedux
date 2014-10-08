//
//  TweetsTableViewCell.swift
//  tweeple
//
//  Created by Sahil Arora on 9/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

//protocol TweetsTableViewCellDelegate {
//    func tweetSelected(tweetSelected: Tweet) -> Void
//}

protocol TweetCellButtonDelegate {
    func tweetCellButtonSelected(tweetCellButtonSelected: TweetsTableViewCell, action: String) -> Void
    func tweetProfileImageSelected(user: User) -> Void
}

class TweetsTableViewCell: UITableViewCell, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var retweetedImageView: UIImageView!
    @IBOutlet weak var retweetedLabel: UILabel!
    @IBOutlet weak var retweetedImageHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetedMarginTop: NSLayoutConstraint!
    
    @IBOutlet weak var userThumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: TTTAttributedLabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaImageHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaImageMarginBot: NSLayoutConstraint!
    
    
    var delegate: TweetCellButtonDelegate?
    
    var tweet: Tweet? {
        willSet {

        }
        didSet {
            tweetLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.toRaw()
            tweetLabel.delegate = self
            
            
            nameLabel.text = tweet?.user?.name
            usernameLabel.text = "@\((tweet?.user?.screenname)!)"
            tweetLabel.text = tweet?.text
            
            userThumbImageView.setImageWithURL(NSURL(string: (tweet?.user?.profileImageUrlBigger)!))
            userThumbImageView.layer.cornerRadius = 8.0
            userThumbImageView.clipsToBounds = true
            
            var relativeTimeString = NSDate.prettyTimestampSinceDate(tweet?.createdAt?)
            relativeTimeString = formatTimeString(relativeTimeString)
            timeLabel.text = relativeTimeString
            
            verifiedImageView.hidden = !((tweet?.user?.isVerified)!)
            
            if (tweet?.retweetedStatus) != nil {
                retweetedMarginTop.constant = 10.0
                retweetedImageHeight.constant = 16.0
                
                retweetedImageView.hidden = false
                retweetedLabel.hidden = false
                retweetedLabel.text = "\((tweet?.retweetByUser?.name)!) retweeted"
            } else {
                retweetedMarginTop.constant = 0
                retweetedImageHeight.constant = 0
                
                retweetedImageView.hidden = true
                retweetedLabel.hidden = true
            }
            
            if tweet?.isFavorited == true {
                let favoriteOnImage = UIImage(named: "favorite_on") as UIImage
                favoriteButton.setImage(favoriteOnImage, forState: UIControlState.Normal)
            } else {
                let favoriteOffImage = UIImage(named: "favorite") as UIImage
                favoriteButton.setImage(favoriteOffImage, forState: UIControlState.Normal)
            }
            
            if tweet?.isRetweeted == true {
                let retweetOnImage = UIImage(named: "retweet_on") as UIImage
                retweetButton.setImage(retweetOnImage, forState: UIControlState.Normal)
            } else {
                let retweetOffImage = UIImage(named: "retweet") as UIImage
                retweetButton.setImage(retweetOffImage, forState: UIControlState.Normal)
            }
            
            retweetCountLabel.text = "\((tweet?.retweetedCount)!)"
            favoriteCountLabel.text = "\((tweet?.favoritedCount)!)"

            if tweet?.mediaUrl == nil {
                mediaImageHeight.constant = 0
                mediaImageMarginBot.constant = 0
            } else {
                mediaImageHeight.constant = 30
                mediaImageMarginBot.constant = 10
                mediaImageView.setImageWithURL(NSURL(string: (tweet?.mediaUrl)!))
            }
            

            var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onCustomTap:")
            tapGestureRecognizer.numberOfTapsRequired = 1;
            tapGestureRecognizer.delegate = self
            userThumbImageView.addGestureRecognizer(tapGestureRecognizer)

        }
    }
    
    func onCustomTap(tapGestureRecognizer: UITapGestureRecognizer) {
        //var point = tapGestureRecognizer.locationInView(view)
        println("tap recognized")
        // User tapped at the point above. Do something with that if you want.
        delegate?.tweetProfileImageSelected((tweet?.user)!)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onReply(sender: AnyObject) {
        println("reply pressed")
        delegate?.tweetCellButtonSelected(self, action: "reply")
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        println("retweet pressed")
        delegate?.tweetCellButtonSelected(self, action: "retweet")
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        println("favorite pressed")
        delegate?.tweetCellButtonSelected(self, action: "favorite")
    }
    
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        println("link clicked")
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    func formatTimeString (unformattedString: String) -> (String) {
        var relativeTimeString = unformattedString
        
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" second ago", withString: "s")
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" seconds ago", withString: "s")
        
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" minute ago", withString: "m")
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" minutes ago", withString: "m")
        
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" hour ago", withString: "h")
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" hours ago", withString: "h")
        
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" month ago", withString: "mo")
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" months ago", withString: "mo")
        
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" year ago", withString: "y")
        relativeTimeString = relativeTimeString.stringByReplacingOccurrencesOfString(" years ago", withString: "y")
        
        return relativeTimeString
    }

}
