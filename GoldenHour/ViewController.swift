//
//  ViewController.swift
//  GoldenHour
//
//  Created by Carter Borchetta on 12/2/19.
//  Copyright © 2019 Carter Borchetta. All rights reserved.
//

import UIKit
import CoreLocation
import MultiProgressView
import SwiftDate

class ViewController: UIViewController {


    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var eveningGoldenHourDurationLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var eveningGoldenHourLabel: UILabel!
    @IBOutlet weak var morningGoldenHourDurationLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var morningGoldenHourLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var progressView: MultiProgressView!

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var ghKeyBox1: UIView!
    @IBOutlet weak var ghKeyBox2: UIView!
    @IBOutlet weak var sunriseKeyBox: UIView!
    @IBOutlet weak var sunsetKeyBox: UIView!
    

    
    
    var currentLocation: CLLocation!
    let formatter = DateFormatter()
    var solarDetails: SolarDetails!
    var countDownTimer = Timer()
    //var executionTimer = Timer()
    var secondsToGH: Double = 60*60
    var isGoldenHour: Bool = true {
        didSet {
            print("now i have \(isGoldenHour) before I had \(oldValue)")
            if oldValue != isGoldenHour {
                print("Listener Triggered")
                triggerTimer()
                //executionTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.triggerTimer)), userInfo: nil, repeats: true)
            }
        }
    }
    
    

    
    //var date = Date()
    //let calendar = Calendar.current
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFormatter()
        configureBar()
        configureBackgroundViews()
        solarDetails = SolarDetails()

        
        

        
        //currentLocation = CLLocation(latitude: 42.339, longitude: -71.1586)
        currentLocation = CLLocation(latitude: 40.38, longitude: -118.83)
        let solarDetail = SolarDetail(date: Date(), location: currentLocation)
        print(solarDetail.morningGoldenHourStart)
        solarDetails.solarDetailsArray.append(solarDetail)
        
        updateUserInterface()
        var sectionArray = solarDetails.solarDetailsArray[0].calculateSections()
        
        for i in 0..<sectionArray.count {
            progressView.setProgress(section: i, to: 0.0)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            for i in 0..<sectionArray.count {
                self.progressView.setProgress(section: i, to: Float(sectionArray[i]))
                //count += Float(sectionArray[i])
            }
            //print(count)
        }, completion: nil)
        
        //var count: Float = 0
        
        
        print(formatter.string(from: solarDetails.solarDetailsArray[0].eveningGoldenHourStart))
        print(formatter.string(from: solarDetails.solarDetailsArray[0].eveningGoldenHourEnd))
        
        fetchNextSevenDays()
        triggerTimer()
        //runTimer()
    }
    
    func setupTimerDuration(with duration: Double) {
        secondsToGH = duration
    }
    
    @objc func triggerTimer() {
        print("I think its this date \(formatter.string(from: Date())) and this time zone \(formatter.timeZone)")
        // Every second check if it is GH
        // If it is GH(its in the interval)
        // - Start the timer with the duration
        // - Set GH to true
        // - Stop checking if its GH for the duration
        let solarDetailElement = solarDetails.solarDetailsArray[0]
        var duration: TimeInterval = 0
        if (Date() < solarDetailElement.morningGoldenHourEnd && Date() > solarDetailElement.morningGoldenHourStart) { // We are in morning GH
            //duration = Date().timeIntervalSince(solarDetailElement.morningGoldenHourEnd)
            duration = TimeInterval(exactly: 10)!
            isGoldenHour = true
            statusLabel.text = "Left In Golden Hour"
        } else if (Date() < solarDetailElement.eveningGoldenHourEnd && Date() > solarDetailElement.eveningGoldenHourStart) { // We are in evening GH
            duration = Date().timeIntervalSince(solarDetailElement.eveningGoldenHourEnd)
            isGoldenHour = true
            statusLabel.text = "Left In Golden Hour"
        } else if Date() > solarDetailElement.morningGoldenHourEnd { // Leadup to evening GH
            duration = Date().timeIntervalSince(solarDetailElement.eveningGoldenHourStart)
            print("This is working??!!!")
            isGoldenHour = false
            statusLabel.text = "Until Golden Hour"
        } else { // Leadup to morning GH
            duration = Date().timeIntervalSince(solarDetailElement.morningGoldenHourStart)
            isGoldenHour = false
            statusLabel.text = "Until Golden Hour"
        }
        
        setupTimerDuration(with: abs(duration))
        runTimer()
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
    }
    
    func runTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        //if !isGoldenHour {
        //    print("I ran")
        //    executionTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.triggerTimer)), userInfo: nil, repeats: true)
            //isGoldenHour = false
        }
        
    
    
    @objc func updateTimer() {
        if secondsToGH < 1 {
            countDownTimer.invalidate()
            triggerTimer()
        } else {
            secondsToGH -= 1
            countDownLabel.text = timeString(time: TimeInterval(secondsToGH))
        }
    }
    
    func configureFormatter() {
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
    }
    
    func configureBar() {
        progressView.lineCap = .round
        progressView.cornerRadius = 10
    }
    
    func configureBackgroundViews() {
        bottomBackgroundView.layer.cornerRadius = 10
        topBackgroundView.layer.cornerRadius = 10
        ghKeyBox1.layer.cornerRadius = 6
        ghKeyBox1.backgroundColor = UIColor.StorageExample.progressYellow
        ghKeyBox2.layer.cornerRadius = 6
        ghKeyBox2.backgroundColor = UIColor.StorageExample.progressYellow
        sunriseKeyBox.layer.cornerRadius = 6
        
        sunriseKeyBox.backgroundColor = UIColor.StorageExample.progressOrange
        sunsetKeyBox.layer.cornerRadius = 6
        sunsetKeyBox.backgroundColor = UIColor.StorageExample.progressOrange
        
    }
    
    func updateUserInterface() {
        morningGoldenHourLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[0].morningGoldenHourStart)) - \(formatter.string(from: solarDetails.solarDetailsArray[0].morningGoldenHourEnd))"
        sunriseLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[0].sunrise))"
        
        eveningGoldenHourLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[0].eveningGoldenHourStart)) - \(formatter.string(from: solarDetails.solarDetailsArray[0].eveningGoldenHourEnd))"
        sunsetLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[0].sunset))"
        
        morningGoldenHourDurationLabel.text = "\(solarDetails.solarDetailsArray[0].morningGoldenHourDuration!) minutes"
        eveningGoldenHourDurationLabel.text = "\(solarDetails.solarDetailsArray[0].eveningGoldenHourDuration!) minutes"
    }
    

    
    func fetchNextSevenDays() {
        var tempDate = Date()
        for _ in 0..<7 {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)
            solarDetails.solarDetailsArray.append(SolarDetail(date: tomorrow!, location: currentLocation))
            tempDate = tomorrow!
        }
        print(solarDetails.solarDetailsArray)
    }
    
    
    @IBAction func progressViewTapped(_ sender: Any) {
        print("Tapped!")
    }
    
}


extension ViewController: MultiProgressViewDataSource {
    func numberOfSections(in progressView: MultiProgressView) -> Int {
        return 9
    }
    
    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let bar = DayProgressSection()
        var colorSection = 0
        
        switch section {
        case 0, 8, 4:
            colorSection = 0
        case 1, 3, 5, 7:
            colorSection = 1
        case 2, 6:
            colorSection = 2
        default:
            colorSection = 7
        }
        
        bar.configure(withDayType: DayType(rawValue: colorSection) ?? .normal)
        return bar
    }
}







