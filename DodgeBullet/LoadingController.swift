//
//  LoadingController.swift
//  DodgeBullet
//
//  Created by user on 15/11/13.
//  Copyright © 2015年 赵涛. All rights reserved.
//

import Foundation
import UIKit
class LoadingController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size: CGFloat = 30
        let padding = (view.frame.size.width-3*size)/2
        let spinView = UIActivityIndicatorView(frame: CGRectMake(padding, view.frame.size.height*3/4, size, size))
        spinView.color = UIColor.blackColor()
        spinView.startAnimating()
        let labelView = UILabel(frame: CGRectMake(padding+size, spinView.frame.origin.y, 3*size, size))
        labelView.text = "Loading..."
        labelView.textAlignment = .Left
        view.addSubview(spinView)
        view.addSubview(labelView)
        print("view did load")
    }
}