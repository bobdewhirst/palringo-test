//
//  GradientView.swift
//  PalringoPhotos
//
//  Created by Benjamin Briggs on 14/10/2016.
//  Copyright © 2016 Palringo. All rights reserved.
//

import Foundation

import UIKit
@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white {
        didSet {layoutSubviews()}
    }
    @IBInspectable var bottomColor: UIColor = UIColor.black {
        didSet {layoutSubviews()}
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
