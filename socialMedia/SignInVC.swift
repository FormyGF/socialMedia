//
//  SignInVC.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/7/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailAddress: FancyFeild!
    @IBOutlet weak var passWord: FancyFeild!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss the keyboard after input
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
    }
    
    // need to wait until the view has been completely loaded
    override func viewDidAppear(_ animated: Bool) {
        
        // retrieve user unique id from keychain
        if let res = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            print("$debug: retriving user id from key chain \(res)")
            
            // use keychain to retrieve user infomation from firebase
            // http://stackoverflow.com/questions/37759614/firebase-retrieving-data-in-swift
            
            DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
                if let users = snapshot.value as? Dictionary<String, AnyObject> {
                    if let currentUser = users[res] as? Dictionary<String, String> {
                        
                        print("$debug current user name \(currentUser["userName"]!)")
                        FeedVC.userName = currentUser["userName"]
                        
                        self.performSegue(withIdentifier: "FeedVC", sender: nil)
                    }
                }
            })
        }
    }
    
/*--------------------------------- FACEBOOK SIGN IN BUTTON -------------------------------------*/
    
    @IBAction func FBBtnSignIn(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                
                print("$debug unable to authenticate facebook \(error)")
            } else if result?.isCancelled == true {
                
                print("$debug login has been cancelled")
                
            } else {
                
                // get user infomation using facebook graph api
                let connection = FBSDKGraphRequestConnection()
                
                connection.add(FBSDKGraphRequest(graphPath: "me",parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]), completionHandler: { (connection, result, error) in
                    print("$debug in the handler")
                    if error != nil {
                        print("$debug unable to make a graph request: \(error)")
                    } else {

                        if let dict = result as? Dictionary<String, AnyObject> {
                            
                            print("$debug user name is \(dict["name"]!)")
                            
                            FeedVC.userName = dict["name"] as? String
                        }
                        
                        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        
                        self.firebaseAuth(credential, userName: FeedVC.userName)
                    }
                })
                
                connection.start()
                
                print("$debug Successfully to authenticate with facebook")
            }
            
        }
    }
    
/*--------------------------------- FIRBASE SIGN IN BUTTON -------------------------------------*/

    @IBAction func signinBtn(_ sender: Any) {
        
        if let email = emailAddress.text, let psw = passWord.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: psw, completion: { (FIRUser, Error) in
                if Error == nil {
                    
                    print("$debug Successfully logged in with user: \(FIRUser)")
                    
                    if let user = FIRUser {
                        
                        let userData = ["Provider" : user.providerID,
                                            "userName": "\(email)"]
                        
                        FeedVC.userName = email
                        
                        self.completeSignIn(id: user.uid, userData: userData)
                        
                    }
                } else {
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: psw, completion: { (FIRUser, Error) in
                        if Error != nil {
                            
                            print("$debug Fail to create user with email in firebase \(Error)")
                        } else {
                            
                            print("$debug Successfully Created account \(FIRUser)")
                            
                            if let user = FIRUser {
                                
                                let userData = ["Provider" : user.providerID,
                                                "userName": "\(email)"];
                                
                                FeedVC.userName = email
                                
                                self.completeSignIn(id: user.uid, userData: userData)
                                
                            }
                        }
                    })
                }
            })
        } else {
            
            print("$debug input field cannot be empty")
            
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential, userName: String) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (FIRUser, Error) in
            if Error != nil {
                print("$debug \(Error)")
                print("$debug Unable to authenticate with firebase")
            } else {
                
                print("$debug Successfully to authenticate with firebase")
                
                if let user = FIRUser {
                    
                    let userData = ["Provider" : "\(credential.provider)",
                                    "userName" : userName
                    ]
                    
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("$debug Keychain Saved: \(KEY_UID) -> \(keychainResult)")
        
        performSegue(withIdentifier: "FeedVC", sender: nil)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}





















