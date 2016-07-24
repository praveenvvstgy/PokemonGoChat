//
//  Utils.swift
//  PokemonChat
//
//  Created by Praveen Gowda I V on 7/24/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation

class Utils {
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}