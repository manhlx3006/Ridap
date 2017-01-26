//
//  RCustomPointAnnotation.swift
//  Ridap
//
//  Created by Manh Le on 26/1/17.
//  Copyright © 2017 Xuan Manh Le. All rights reserved.
//

import UIKit
import MapKit

class RCustomPointAnnotation: MKPointAnnotation {
    
    var identifier : String = ""
    var image : UIImage?
    
    override init() {
        super.init()
    }
}
