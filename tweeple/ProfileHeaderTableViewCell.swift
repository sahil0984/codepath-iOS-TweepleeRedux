//
//  ProfileHeaderTableViewCell.swift
//  tweeple
//
//  Created by Sahil Arora on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profileBannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileScreennameLabel: UILabel!
    
    var profileUser: User? {
        willSet {
        }
        didSet {
            
//            var params: [String: String] = [String:String]()
//            params["screen_name"] = profileUser?.screenname!
//            TwitterClient.sharedInstance.userBannerWithParams(params, completion: { (bannerUrl: String?, error: NSError?) -> () in
//                if error != nil {
//                    println(error)
//                } else {
//                    self.profileBannerImageView.setImageWithURL(NSURL(string: (bannerUrl)!))
//                }
//            })
            
            profileImageView.setImageWithURL(NSURL(string: (profileUser?.profileImageUrlBigger)!))
            profileNameLabel.text = profileUser?.name
            profileScreennameLabel.text = profileUser?.screenname
            
        }
    }
    
            

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
