//
//  HomeViewController.swift
//  PokemonChat
//
//  Created by Praveen Gowda I V on 7/25/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import CoreLocation
import GeoFire

class HomeViewController: UIViewController {
    
    @IBOutlet weak var postsTable: UITableView!
    
    var newPostView: UIView!
    var postTextView: UITextView!
    var circleQuery: GFCircleQuery!
    
    var posts = [String: [String: String]]() {
        didSet {
            postsTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        setupNewPostView()
        
        postsTable.rowHeight = UITableViewAutomaticDimension
        postsTable.dataSource = self
        postsTable.delegate = self
        
        // Setup Geo Query
        let center = LocationHelper.sharedHelper.currentLocation
        // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
        circleQuery = Utils.geoFireRef.queryAtLocation(center, withRadius: 5)
        
        circleQuery.observeEventType(.KeyEntered) { (key, location) in
            let geoCoder = CLGeocoder()
            
            if self.posts.keys.contains(key) == false {
                Utils.databaseRef.child("posts/\(key)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if snapshot.exists() {
                        if var post = snapshot.value as? [String: String] {
                            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                                var placeMark: CLPlacemark!
                                placeMark = placemarks?[0]
                                if let addressDictionary = placeMark.addressDictionary {
                                    if let city = addressDictionary["City"] as? NSString, let state = addressDictionary["State"] as? NSString {
                                        post["location"] = "\(String(format: "%.2f", LocationHelper.sharedHelper.currentLocation.distanceFromLocation(location)/1609.344))m - \(city), \(state)"
                                        self.posts[key] = post
                                    }
                                }
                            })
                        }
                    }
                })
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationChanged), name: "locationChanged", object: nil)
        
        circleQuery.observeEventType(.KeyExited) { (key, location) in
            if self.posts.keys.contains(key) {
                self.posts[key] = nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Current location is \(LocationHelper.sharedHelper.currentLocation)")
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupNewPostView() {
        newPostView = NSBundle.mainBundle().loadNibNamed("NewPostView", owner: self, options: nil).first as! UIView
        if let usernameLabel = newPostView.viewWithTag(2) as? UILabel {
            usernameLabel.text = FIRAuth.auth()?.currentUser?.displayName
        }
        
        if let closeButton = newPostView.viewWithTag(1) as? UIButton {
            closeButton.addTarget(self, action: #selector(closeNewPostView), forControlEvents: .TouchUpInside)
        }
        
        if let postTextView = newPostView.viewWithTag(3) as? UITextView {
            postTextView.delegate = self
            postTextView.text = "Click to enter text"
            postTextView.textColor = UIColor.lightGrayColor()
            self.postTextView = postTextView
        }
        
        if let submitButton = newPostView.viewWithTag(4) as? UIButton {
            submitButton.addTarget(self, action: #selector(submitPost), forControlEvents: .TouchUpInside)
        }
        newPostView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeNewPostView)))
        
        newPostView.frame = UIScreen.mainScreen().bounds
        
        newPostView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func closeNewPostView() {
        postTextView.text = "Click to enter text"
        postTextView.textColor = UIColor.lightGrayColor()
        UIView.transitionWithView(newPostView, duration: 0.5, options: .ShowHideTransitionViews, animations: {
            self.newPostView.removeFromSuperview()
            }, completion: nil)
    }
    
    @IBAction func toggleLeftDrawer() {
        if let drawerController = Utils.getDrawerController(self.parentViewController!) {
            drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
        }
    }
    
    @IBAction func addNewPost() {
        UIView.transitionWithView(newPostView, duration: 0.5, options: .TransitionNone, animations: {
            self.navigationController?.view.addSubview(self.newPostView)
            let horizontalConstraint = NSLayoutConstraint(item: self.newPostView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.navigationController?.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            self.navigationController?.view.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: self.newPostView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.navigationController?.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            self.navigationController?.view.addConstraint(verticalConstraint)
            
            let widthConstraint = NSLayoutConstraint(item: self.newPostView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.navigationController?.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            self.navigationController?.view.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: self.newPostView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.navigationController?.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            self.navigationController?.view.addConstraint(heightConstraint)
            }, completion: nil)
    }
    
    @IBAction func submitPost() {
        if postTextView.text.isEmpty || postTextView.text == "Click to enter text" {
            return
        }
        if let username = FIRAuth.auth()?.currentUser?.displayName {
            let loadingIndicator = MBProgressHUD.showHUDAddedTo(postTextView, animated: true)
            loadingIndicator.label.text = "Posting"
            Utils.addNewPost(postTextView.text, username: username, completion: {
                loadingIndicator.hideAnimated(true)
                self.closeNewPostView()
                }, failure: {
                    loadingIndicator.hideAnimated(true)
                    let alertController = UIAlertController(title: "Posting Failed", message: "Failed to save your post, try again", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
    
    func locationChanged(notification: NSNotification) {
        if let location = notification.object as? CLLocation {
            circleQuery.center = location
        }
    }
}

extension HomeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Click to enter text"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            submitPost()
            return false
        }
        return true
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postsCell", forIndexPath: indexPath) as! PostsTableViewCell
        
        let postKey = Array(posts.keys)[indexPath.row]
        if let post = posts[postKey] {
            cell.usernameLabel.text = post["username"] ?? ""
            cell.postTitleLabel.text = post["text"] ?? ""
            cell.locationLabel.text = post["location"] ?? ""
        }
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 124
    }

}