//
//  DateExtention.swift
//  OneSwfitMacApp
//
//  Created by hanxiaoqing on 2017/10/31.
//  Copyright © 2017年 hanxiaoqing. All rights reserved.
//

import Foundation

extension Date {
    
    static func dateFromString(string: String,format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
    
    func isYesterday() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let nowDateString = formatter.string(from: Date())
        let compairDateString = formatter.string(from: self)
        
        let nowDate = formatter.date(from: nowDateString)!
        let compairDate = formatter.date(from: compairDateString)!
        
        let calendar = Calendar.current
        
        let cmsSet: Set<Calendar.Component> = [.year, .month, .day]
        let component = calendar.dateComponents(cmsSet, from: compairDate, to: nowDate)
        
        return component.year == 0 && component.month == 0 && component.day == 1
    }
    
    func isThisYear() -> Bool {
        let calendar = Calendar.current
        
        let compairDateCmps = calendar.dateComponents([.year], from: self)
        let nowDateCmps = calendar.dateComponents([.year], from: Date())
        
        return compairDateCmps.year == nowDateCmps.year
    }
    
    func isToday() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let nowDateString = formatter.string(from: Date())
        let compairDateString = formatter.string(from: self)
        
        return nowDateString == compairDateString
    }
    
}
