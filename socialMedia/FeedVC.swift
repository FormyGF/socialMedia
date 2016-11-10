//
//  FeedVC.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionField: FancyFeild!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false // make sure at least one image has been selected
    static var imageCache: NSCache<NSString, UIImage> = NSCache() // temporarily store image for resue
    static var userName: String!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        captionField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POST.observe(.value, with: {(snapshot) -> Void in // observe the update in firebase
        
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                self.posts.removeAll() // clean up the feed view
                
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post) // add new feed retrived from firebase
                        
                    }
                }
                
            } else {
                
                print("$debug Database is emtpy")
                
            }
            self.posts.sort(by: { (l, r) -> Bool in
                l.order > r.order
            })
            self.tableView.reloadData()
        })
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func addImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil) // presnt the image picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // when user finished picking up image, get the image that picked by user
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            print("$debug image picked up")
            self.imageSelected = true
            addImage.setImage(image, for: UIControlState.normal)
            
        } else {
            self.imageSelected = false
            print("$debug No image selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)  // close the image picker
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = self.posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString) {
            
            cell.configureCell(post: post, img: img)
            
        } else {
        
            cell.configureCell(post: post, img: nil)
        }
        
        return cell
    }
    
/*------------------------------------- POST BUTTON ----------------------------------------------*/

    @IBAction func postBtnPressed(_ sender: Any) {
        
         // make sure the caption field is not empty
        guard let caption = captionField.text, caption != "" else {
            print("$debug Caption Must Not Be empty")
            return
        }
        
        // make sure user has choosen the image to post
        guard let image = addImage.imageView?.image, imageSelected == true else {
            print("$debug An image must be choosen")
            return
        }
        
        // upload the image to firestorage
        if let imageData = UIImageJPEGRepresentation(image, 0.9) {
            
            // create a unique id for this image
            let imageUID = NSUUID().uuidString
            
            // description for the image
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let ref = DataService.ds.REF_POST_IMAGES.child(imageUID)
            
            ref.put(imageData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("$debug unable to upload file to firestorage: \(error)")
                } else {
                    print("$debug successfully uploaded file to firestorage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    // post the current POST to firebase
                    self.postToFirebase(imageURL: downloadURL!)
                    
                }
            }
        }
    }
    
    func postToFirebase(imageURL: String) {
        
        let post: Dictionary<String, Any> = [
            "caption": captionField.text!,
            "imageURL": imageURL,
            "likes" : 0,
            "userName": FeedVC.userName,
            "order": posts.count + 1
        ]
        
        // create a unique child and set value to it
        let ref = DataService.ds.REF_POST.childByAutoId()
        ref.setValue(post)
        
        // recover the status
        captionField.text = ""
        imageSelected = false
        addImage.setImage(UIImage(named: "add-image"), for: UIControlState.normal)
    }
    
/*------------------------------------- SIGN OUT BUTTON ------------------------------------------*/
    
    @IBAction func signOutPressed(_ sender: Any) {
        
        let result = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("$debug: id remove from keychain \(result)")
        try! FIRAuth.auth()?.signOut()
        
        performSegue(withIdentifier: "SignInVC", sender: nil)
        
    }

/*------------------------------------- text feild ------------------------------------------*/
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}






















