//
//  Post.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation

class Post {
    
    private var _caption: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _postKey: String!
    private var _userEmail: String!
    private var _order: Int!
    
    var caption: String {
        
        return _caption
        
    }
    
    var imageURL: String {
        
        if let url = _imageURL {
            
            return url
            
        }
        return ""
        
    }
    
    var likes: Int {
        
        return _likes
        
    }
    
    var postKey: String {
        
        return _postKey
        
    }
    
    var userEmail: String {
        
        return _userEmail
        
    }
    
    var order: Int {
        
        return _order
        
    }
    
    init(caption: String, imageURL: String, likes: Int, userEmail: String, order: Int) {
        
        _caption = caption
        _imageURL = imageURL
        _likes = likes
        _userEmail = userEmail
        _order = order
        
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        
        _postKey = postKey
        
        if let caption = postData["caption"] as? String{
            
            _caption = caption
            
        }
        
        if let imageURL = postData["imageURL"] as? String {
            
            _imageURL = imageURL
            
        }
        
        if let likes = postData["likes"] as? Int {
            
            _likes = likes
            
        }
        
        if let userEmail = postData["userName"] as? String {
            
            _userEmail = userEmail
            
        }
        
        if let order = postData["order"] as? Int {
            
            _order = order
            
        }
    }    
}


















