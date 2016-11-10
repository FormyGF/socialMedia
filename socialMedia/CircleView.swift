//
//  CircleView.swift
//  socialMedia
//
//  Created by Tianxiao Yang on 11/8/16.
//  Copyright © 2016 Tianxiao Yang. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
}
