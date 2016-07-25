//
//  HomeViewController.swift
//  PokemonChat
//
//  Created by Praveen Gowda I V on 7/25/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func toggleLeftDrawer() {
        if let drawerController = Utils.getDrawerController(self.parentViewController!) {
            drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
        }
    }
}
