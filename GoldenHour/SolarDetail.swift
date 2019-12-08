//
//  SolarTimes.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/2/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import Foundation
import SwiftySuncalc
import CoreLocation
import SwiftDate
import MapKit

class SolarDetail: NSObject, MKAnnotation {
    
    var name = "Test name"
    let minutesPerDay: Double = 24 * 60
    
    var morningGoldenHourStart: Date! // Morning Golden Hour Start = Dawn
    var morningGoldenHourEnd: Date!
    // Morning civil twilight start to end of golden hour
    var morningGoldenHourDuration: Int!
    
    // Evening Golden Hour start to civil twilight start
    var eveningGoldenHourStart: Date!
    var eveningGoldenHourEnd: Date! // Evening Golden Hour End = Sunset(civil twilight)
    var eveningGoldenHourDuration: Int!
    
    var sunset: Date!
    var sunrise: Date!
    var suncalc: SwiftySuncalc! = SwiftySuncalc()
    
    var coordinate = CLLocationCoordinate2D()
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var title: String? {
        return name
    }
    
    var location = CLLocation()
    
    
//    init(date: Date, location: CLLocation) {
//        var times = suncalc.getTimes(date: date, lat: location.coordinate.latitude, lng: location.coordinate.longitude);
//        self.morningGoldenHourStart = times["dawn"]
//        self.morningGoldenHourEnd = times["goldenHourEnd"]
//        self.eveningGoldenHourStart = times["goldenHour"]
//        self.eveningGoldenHourEnd = times["dusk"]
//        self.sunset = times["sunset"]
//        self.sunrise = times["sunrise"]
//
//        self.morningGoldenHourDuration = Int((morningGoldenHourEnd.timeIntervalSince(morningGoldenHourStart) / 60).rounded())
//        self.eveningGoldenHourDuration = Int((eveningGoldenHourEnd.timeIntervalSince(eveningGoldenHourStart) / 60).rounded())
//    }
    
    func getTimes(date: Date) {
        var times = suncalc.getTimes(date: date, lat: location.coordinate.latitude, lng: location.coordinate.longitude);
        self.morningGoldenHourStart = times["dawn"]
        self.morningGoldenHourEnd = times["goldenHourEnd"]
        self.eveningGoldenHourStart = times["goldenHour"]
        self.eveningGoldenHourEnd = times["dusk"]
        self.sunset = times["sunset"]
        self.sunrise = times["sunrise"]
        
        self.morningGoldenHourDuration = Int((morningGoldenHourEnd.timeIntervalSince(morningGoldenHourStart) / 60).rounded())
        self.eveningGoldenHourDuration = Int((eveningGoldenHourEnd.timeIntervalSince(eveningGoldenHourStart) / 60).rounded())
    }
    
    func calculateSections() -> [Double] {
        var midnight = Date()
        midnight = midnight.dateAtStartOf(.day)
        //print(midnight)
        
        let normalSection1 = abs((midnight.timeIntervalSince(morningGoldenHourStart) / 60) / minutesPerDay)
        //print(normalSection1)
        
        let morningGHSection1 = abs((morningGoldenHourStart.timeIntervalSince(sunrise) / 60) / minutesPerDay)
        //print(morningGHSection1)
        
        let sunriseSection = 0.01
        
        let morningGHSection2 = abs((sunrise.timeIntervalSince(morningGoldenHourEnd) / 60) / minutesPerDay)
        //print(morningGHSection2)
        
        let normalSection = abs((morningGoldenHourEnd.timeIntervalSince(eveningGoldenHourStart) / 60) / minutesPerDay)
        //print(normalSection)
        
        let eveningGHSection1 = abs((eveningGoldenHourStart.timeIntervalSince(sunset) / 60) / minutesPerDay)
        //print("evening section 1 \(eveningGHSection1)")
        
        let sunsetSection = 0.01
        
        let eveningGHSection2 = abs((sunset.timeIntervalSince(eveningGoldenHourEnd) / 60) / minutesPerDay)
        //print(" evening section 2 \(eveningGHSection2)")
        
        let normalSection2 = abs(1 - normalSection1 - morningGHSection1 - sunriseSection - morningGHSection2 - normalSection1 - eveningGHSection1 - sunsetSection - eveningGHSection2)
        //print(" normal section 2 \(normalSection2)")
        
        var sectionArray = [normalSection1, morningGHSection1, sunriseSection, morningGHSection2, normalSection1, eveningGHSection1, sunsetSection, eveningGHSection2, normalSection2]
        
        var sum = 0.0
        for element in sectionArray {
            sum += element
        }
        print(sum)
        sectionArray[0] -= (sum - 1) * 0.75
        sectionArray[4] -= (sum - 1) * 0.25
        
        
        
        return sectionArray
        
    }
    
    func getCurrentAbsoluteDuration() -> TimeInterval {
        var absoluteDuration: TimeInterval = 0
        if (Date() < morningGoldenHourEnd && Date() > morningGoldenHourStart) { // We are in morning GH
            absoluteDuration = morningGoldenHourStart.timeIntervalSince(morningGoldenHourEnd)
            
        } else if (Date() < eveningGoldenHourEnd && Date() > eveningGoldenHourStart) { // We are in evening GH
            absoluteDuration = eveningGoldenHourStart.timeIntervalSince(eveningGoldenHourEnd)
        } else if Date() > morningGoldenHourEnd { // Leadup to evening GH
            absoluteDuration = morningGoldenHourEnd.timeIntervalSince(eveningGoldenHourStart)
        } else { // Leadup to morning GH
            absoluteDuration = morningGoldenHourStart.timeIntervalSince(eveningGoldenHourEnd)
        }
        
        return abs(absoluteDuration)
    }

}



