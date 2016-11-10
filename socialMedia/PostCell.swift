//
//  PostCell.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var liked = false
//    let likeRef = DataService.ds.REF_POST.child(post.postKey)
    
    private var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        caption.isEditable = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(likePressed))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
    }
    
    func configureCell(post: Post, img: UIImage?) {
        
        self.post = post
        likes.text = "\(post.likes)"
        caption.text = post.caption
        userNameLbl.text = post.userEmail
        
        if img != nil {
            
            self.postImg.image = img
            
        } else {
            
            if post.imageURL != "" {
                
                let ref = FIRStorage.storage().reference(forURL: post.imageURL)
                
                ref.data(withMaxSize: 5 * 1024 * 1024, completion: { (Data, Error) in
                    
                    if Error != nil {
                        
                        print("$debug unable to download image from firestorage")
                        
                    } else {
                        
                        print("$debug image has been downloaded")
                        if let imageData = Data {
                            
                            if let img = UIImage(data: imageData) {
                                
                                self.postImg.image = img
                                FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString)
                                
                            }
                        }
                    }
                })
            } else {
                print("$debug no image")
            }
        }
    }
    
    func likePressed() {
        
        print("$debug like pressed with caption: \(caption.text)")
        let likeRef = DataService.ds.REF_POST.child(post.postKey)
        let numOfLikes = Int(likes.text!)
        
        if liked {
            
            liked = false
            likeImg.image = UIImage(named: "empty-heart")
            likeRef.updateChildValues(["likes":numOfLikes! - 1])
            likes.text = "\(numOfLikes! - 1)"
            
        } else {
            
            liked = true
            likeImg.image = UIImage(named: "filled-heart")
            likeRef.updateChildValues(["likes":numOfLikes! + 1])
            likes.text = "\(numOfLikes! + 1)"
            
        }
        
    }

}
