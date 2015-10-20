//
//  SongkickInfo.swift
//  Resnate
//
//  Created by Amir Moosavi on 05/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

func getArtistPic(id: Int) -> UIImageView {
    let artistUrl = NSURL(string: "https://ssl.sk-static.com/images/media/profile_images/artists/" + String(id) + "/huge_avatar")
    let data = NSData(contentsOfURL: artistUrl!)
    let artistPic = UIImage(data: data!)
    let artistView = UIImageView(image: artistPic!)
    return artistView
}

func getHugeArtistPic(id: Int) -> UIImageView {
    let artistUrl = NSURL(string: "https://ssl.sk-static.com/images/media/profile_images/artists/" + String(id) + "/huge_avatar")
    let data = NSData(contentsOfURL: artistUrl!)
    let artistPic = UIImage(data: data!)
    let artistView = UIImageView(image: artistPic!)
    return artistView
}

func setSKLabelText(label: UILabel) {
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Left
    label.font = UIFont(name: "HelveticaNeue-Light", size: 20)
    label.numberOfLines = 2
}

func setBoldText(label: UILabel) {
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Left
    label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
}

func returnDayAndMonth(date: String) -> (month: NSString, day: String) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dateFormatted = dateFormatter.dateFromString(date)
    
    
    let requestedDateComponents: NSCalendarUnit = [.Year, .Month, .Day]
    
    let userCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
    
    
    let dateComponents = userCalendar.components(requestedDateComponents,
        fromDate: dateFormatted!)
    
    let secondFormatter = NSDateFormatter()
    secondFormatter.dateFormat = "MM"
    
    let month = String(dateComponents.month)
    
    
    let nsMonth = secondFormatter.dateFromString(month)
    
    let thirdFormatter = NSDateFormatter()
    thirdFormatter.dateFormat = "MMM"
    
    let wordMonth = thirdFormatter.stringFromDate(nsMonth!)
    
    
    let day = String(dateComponents.day)
    
    
    
    
    
    return (month: wordMonth, day: day)
    
}