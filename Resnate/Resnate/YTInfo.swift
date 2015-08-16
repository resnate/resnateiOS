//
//  YTInfo.swift
//  Resnate
//
//  Created by Amir Moosavi on 05/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

func getYTPic(id: String) -> UIImageView {
    let YTUrl = NSURL(string: id)
    let data = NSData(contentsOfURL: YTUrl!)
    let YTPic = UIImage(data: data!)
    let YTView = UIImageView(image: YTPic!)
    return YTView
}