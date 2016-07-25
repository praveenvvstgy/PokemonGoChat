//
//  Utils.swift
//  PokemonChat
//
//  Created by Praveen Gowda I V on 7/24/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import FirebaseAuth
import MMDrawerController

class Utils {
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static func logoutUser() {
        try! FIRAuth.auth()?.signOut()
    }
    
    static func getDrawerController(viewController: UIViewController) -> MMDrawerController? {
        if viewController.parentViewController?.isKindOfClass(MMDrawerController) == true {
            return viewController.parentViewController as? MMDrawerController
        }
        return nil
    }
    
    static func ifLoggedInRedirectToHome(fromVC: UIViewController) {
        if FIRAuth.auth()?.currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("homeNavigationViewController") as! BaseNavigationController
            let sideViewController = storyboard.instantiateViewControllerWithIdentifier("sideViewController") as! SideViewController
            let drawerController = MMDrawerController(centerViewController: homeNavigationViewController, leftDrawerViewController: sideViewController)
            drawerController.openDrawerGestureModeMask = .All
            drawerController.closeDrawerGestureModeMask = .All
            fromVC.presentViewController(drawerController, animated: true, completion: nil)
        }
    }
    
}