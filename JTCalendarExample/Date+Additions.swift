//
//  Date+Additions.swift
//  JTCalendarExample
//
//  Created by Jim Hildensperger on 22/09/2018.
//  Copyright © 2018 Jim Hildensperger. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let calendarDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let weekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let calendarMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale.current
        return formatter
    }()
}

extension Date {
    var isTodayOrLater: Bool {
        return self > Date() || Calendar.current.isDateInToday(self)
    }
}
