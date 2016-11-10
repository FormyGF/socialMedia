//
//  DataService.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference() // in the info.plist
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    private init() {} // make it a singleton
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POST = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    // Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    
    var REF_BASE: FIRDatabaseReference {
        
        return _REF_BASE
        
    }
    
    var REF_POST: FIRDatabaseReference {
        
        return _REF_POST
        
    }
    
    var REF_USERS: FIRDatabaseReference {
        
        return _REF_USERS
        
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
        
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        
        return _REF_POST_IMAGES
        
    }
    
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        
        REF_USERS.child(uid).updateChildValues(userData)
        
    }
    
    
}























