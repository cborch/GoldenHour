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
import MapKit
import TimeZoneLocate

class ViewController: UIViewController {
    
    var demoVar = 1
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    var currentPage = 0
    var duration: TimeInterval!
    let regionDistance: CLLocationDistance = 100000

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
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

    @IBOutlet weak var statusBackgroundView: MultiProgressView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var ghKeyBox1: UIView!
    @IBOutlet weak var ghKeyBox2: UIView!
    @IBOutlet weak var sunriseKeyBox: UIView!
    @IBOutlet weak var sunsetKeyBox: UIView!
    

    
    var locationManager: CLLocationManager!
    var currentLocation = CLLocation()
    
    let formatter = DateFormatter()
    var solarDetails = SolarDetails()
    var countDownTimer = Timer()
    var secondsToGH: Double = 0
    var isGoldenHour: Bool! {
        didSet {
            //print("now i have \(isGoldenHour) before I had \(oldValue)")
            if oldValue != isGoldenHour {
                //print("Listener Triggered")
                triggerTimer(with: currentPage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFormatter()
        countDownLabel.textColor = .orange
        configureBar()
        configureBackgroundViews()
        animateBackgroundViews(count: 2, views: [topBackgroundView, bottomBackgroundView])
        
        
        if currentPage != 0 {
            solarDetails.solarDetailsArray[currentPage].getTimes(date: Date())
            solarDetails.solarDetailsArray[currentPage].getWeather {
                self.updateUserInterface(for: self.currentPage)
            }
            
        }
        
        if currentPage == 0 {
            loadCurrentLocation {
                self.solarDetails.solarDetailsArray[0].getTimes(date: Date())
                self.solarDetails.solarDetailsArray[0].getWeather {
                    self.updateUserInterface(for: self.currentPage)
                }
            }
        }
    
        
        
        var sectionArray = solarDetails.solarDetailsArray[currentPage].calculateSections()
        for i in 0..<sectionArray.count {
            progressView.setProgress(section: i, to: 0.0)
        }
        
        UIView.animate(withDuration: 0.4, delay: 1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            for i in 0..<sectionArray.count {
                self.progressView.setProgress(section: i, to: Float(sectionArray[i]))
            }
        }, completion: nil)
        
        let region = MKCoordinateRegion(center: solarDetails.solarDetailsArray[currentPage].location.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        
        checkGH()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentPage == 0 {
            updateUserInterface(for: 0)
        }
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(solarDetails.solarDetailsArray[currentPage])
        mapView.setCenter(solarDetails.solarDetailsArray[currentPage].location.coordinate, animated: true)
    }
    
    func loadCurrentLocation(completed: @escaping () -> ()) {
        getLocation()
        completed()
    }
    
    
    func animateProgressBar() {
        let timeRemaining = secondsToGH
        let percentageCompleted = abs(timeRemaining / solarDetails.solarDetailsArray[currentPage].getCurrentAbsoluteDuration())
        statusBackgroundView.setProgress(section: 2, to: Float(percentageCompleted))
        UIView.animate(withDuration: 1.0, delay:1, options: [.repeat, .autoreverse], animations: {
            self.statusBackgroundView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: nil)

    }
    
//    func animateProgressBar() {
//        let timeRemaining = secondsToGH
//        let percentageCompleted = abs(timeRemaining / TimeInterval(exactly: 30.0)!)
//
//        UIView.animate(withDuration: 1.0, delay:0.5, options: [.curveLinear], animations: {
//            self.statusBackgroundView.setProgress(section: 2, to: Float(percentageCompleted))
//        }, completion: nil)
//        UIView.animate(withDuration: 1.0, delay:1, options: [.repeat, .autoreverse], animations: {
//            self.statusBackgroundView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//        }, completion: nil)
//
//    }
    
    
    func animateBackgroundViews(count: Float, views: [UIView]) {
        UIView.animate(withDuration:0.75, delay:0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            UIView.setAnimationRepeatCount(count)
            for element in views {
                element.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }
            
        }, completion: {completion in
            for element in views {
                element.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
    }
    
    
    func setupTimerDuration(with duration: Double) {
        secondsToGH = duration
    }
    
    
    @objc func triggerTimer(with currentElement: Int) {
        print("*** Timer Triggered   I think its this date \(formatter.string(from: Date())) and this time zone \(formatter.timeZone)")
        let solarDetailElement = solarDetails.solarDetailsArray[currentElement]
        if (Date() < solarDetailElement.morningGoldenHourEnd && Date() > solarDetailElement.morningGoldenHourStart) { // We are in morning GH
            duration = Date().timeIntervalSince(solarDetailElement.morningGoldenHourEnd)
            topBackgroundView.backgroundColor = UIColor.StorageExample.progressOrange
            animateBackgroundViews(count: 3, views: [topBackgroundView])
            statusLabel.text = "Left In Golden Hour"
        } else if (Date() < solarDetailElement.eveningGoldenHourEnd && Date() > solarDetailElement.eveningGoldenHourStart) { // We are in evening GH
            duration = Date().timeIntervalSince(solarDetailElement.eveningGoldenHourEnd)
            bottomBackgroundView.backgroundColor = UIColor.StorageExample.progressOrange
            animateBackgroundViews(count: 3, views: [bottomBackgroundView])
            statusLabel.text = "Left In Golden Hour"
        } else if Date() > solarDetailElement.morningGoldenHourEnd { // Leadup to evening GH
            duration = Date().timeIntervalSince(solarDetailElement.eveningGoldenHourStart)
            //duration = TimeInterval(exactly: 10)!
            topBackgroundView.backgroundColor = UIColor.darkGray
            print("This is working??!!!")
            statusLabel.text = "Until Golden Hour"
        } else { // Leadup to morning GH
            duration = Date().timeIntervalSince(solarDetailElement.morningGoldenHourStart)
            print("&& formatter \(formatter.string(from: solarDetailElement.nextMorningGoldenHourStart))")
            print("Leadup to morning")
            bottomBackgroundView.backgroundColor = UIColor.darkGray
            statusLabel.text = "Until Golden Hour"
        }

        setupTimerDuration(with: abs(duration))
        runTimer()
    }
    
//    @objc func triggerTimer(with currentElement: Int) {
//        print("*** Timer Triggered   I think its this date \(formatter.string(from: Date())) and this time zone \(formatter.timeZone)")
//        let solarDetailElement = solarDetails.solarDetailsArray[currentElement]
//        if (demoVar == 1) { // We are in morning GH
//            duration = TimeInterval(exactly: 30.0)
//            topBackgroundView.backgroundColor = UIColor.StorageExample.progressOrange
//            animateBackgroundViews(count: 3, views: [topBackgroundView])
//            demoVar = 2
//            statusLabel.text = "Left In Golden Hour"
//        } else if (demoVar == 3) { // We are in evening GH
//            duration = TimeInterval(exactly: 30.0)
//            bottomBackgroundView.backgroundColor = UIColor.StorageExample.progressOrange
//            animateBackgroundViews(count: 3, views: [bottomBackgroundView])
//            demoVar = 4
//            statusLabel.text = "Left In Golden Hour"
//        } else if demoVar == 2 { // Leadup to evening GH
//            duration = TimeInterval(exactly: 30.0)
//            //duration = TimeInterval(exactly: 10)!
//            topBackgroundView.backgroundColor = UIColor.darkGray
//            demoVar = 3
//            print("This is working??!!!")
//            statusLabel.text = "Until Golden Hour"
//        } else { // Leadup to morning GH
//            duration = TimeInterval(exactly: 30.0)
//            print("&& formatter \(formatter.string(from: solarDetailElement.nextMorningGoldenHourStart))")
//            print("Leadup to morning")
//            bottomBackgroundView.backgroundColor = UIColor.darkGray
//            demoVar = 1
//            statusLabel.text = "Until Golden Hour"
//        }
//
//        setupTimerDuration(with: abs(duration))
//        runTimer()
//    }
    
    
    func checkGH() {
        let solarDetailElement = solarDetails.solarDetailsArray[currentPage]
        if (Date() < solarDetailElement.morningGoldenHourEnd && Date() > solarDetailElement.morningGoldenHourStart) { // We are in morning GH
            isGoldenHour = true
        } else if (Date() < solarDetailElement.eveningGoldenHourEnd && Date() > solarDetailElement.eveningGoldenHourStart) { // We are in evening GH
            isGoldenHour = true
        } else if Date() > solarDetailElement.morningGoldenHourEnd { // Leadup to evening GH
            isGoldenHour = false
        } else { // Leadup to morning GH
            isGoldenHour = false
        }
    }
    
//    func checkGH() {
//        let solarDetailElement = solarDetails.solarDetailsArray[currentPage]
//        if (demoVar == 1) { // We are in morning GH
//            isGoldenHour = true
//        } else if demoVar == 3 { // We are in evening GH
//            isGoldenHour = true
//        } else if demoVar == 2 { // Leadup to evening GH
//            isGoldenHour = false
//        } else { // Leadup to morning GH
//            isGoldenHour = false
//        }
//    }
    
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
    }
    
    
    func runTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        }
    
    
    @objc func updateTimer() {
        if secondsToGH < 1 {
            countDownTimer.invalidate()
            checkGH()
        } else {
            secondsToGH -= 1
            animateProgressBar()
            countDownLabel.text = timeString(time: TimeInterval(secondsToGH))
            
        }
    }
    
    
    func configureFormatter() {
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm"
        formatter.timeStyle = .short
        formatter.amSymbol = ""
        formatter.pmSymbol = ""
    }
    
    
    func configureBar() {
        progressView.lineCap = .round
        progressView.cornerRadius = 10
    }
    
    
    func configureBackgroundViews() {
        bottomBackgroundView.layer.cornerRadius = 10
        topBackgroundView.layer.cornerRadius = 10
        statusBackgroundView.lineCap = .round
        statusBackgroundView.cornerRadius = 10
        statusBackgroundView.bringSubviewToFront(statusLabel)
        ghKeyBox1.layer.cornerRadius = 6
        ghKeyBox1.backgroundColor = UIColor.StorageExample.progressYellow
        ghKeyBox1.layer.borderWidth = 1
        sunriseKeyBox.layer.borderWidth = 1
        sunriseKeyBox.layer.borderColor = UIColor.darkGray.cgColor
        ghKeyBox1.layer.borderColor = UIColor.darkGray.cgColor
        ghKeyBox2.layer.cornerRadius = 6
        ghKeyBox2.backgroundColor = UIColor.StorageExample.progressYellow
        ghKeyBox2.layer.borderWidth = 1
        ghKeyBox2.layer.borderColor = UIColor.darkGray.cgColor
        sunsetKeyBox.layer.borderWidth = 1
        sunsetKeyBox.layer.borderColor = UIColor.darkGray.cgColor
        sunriseKeyBox.layer.cornerRadius = 6
        
        sunriseKeyBox.backgroundColor = UIColor.StorageExample.progressOrange
        sunsetKeyBox.layer.cornerRadius = 6
        sunsetKeyBox.backgroundColor = UIColor.StorageExample.progressOrange
        
        mapView.layer.cornerRadius = 10
    }
    
    
    func updateUserInterface(for currentPage: Int) {
        morningGoldenHourLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[currentPage].morningGoldenHourStart)) - \(formatter.string(from: solarDetails.solarDetailsArray[currentPage].morningGoldenHourEnd))AM"
        sunriseLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[currentPage].sunrise))AM"
        
        eveningGoldenHourLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[currentPage].eveningGoldenHourStart)) - \(formatter.string(from: solarDetails.solarDetailsArray[currentPage].eveningGoldenHourEnd))PM"
        sunsetLabel.text = "\(formatter.string(from: solarDetails.solarDetailsArray[currentPage].sunset))PM"
        
        locationLabel.text = "Light Report for \(solarDetails.solarDetailsArray[currentPage].name)"
        
        morningGoldenHourDurationLabel.text = "\(solarDetails.solarDetailsArray[currentPage].morningGoldenHourDuration!) minutes"
        eveningGoldenHourDurationLabel.text = "\(solarDetails.solarDetailsArray[currentPage].eveningGoldenHourDuration!) minutes"
        
        summaryLabel.text = solarDetails.solarDetailsArray[currentPage].currentSummary
        temperatureLabel.text = solarDetails.solarDetailsArray[currentPage].currentTemp
        iconImageView.image = UIImage(named: solarDetails.solarDetailsArray[currentPage].currentIcon)
        print("^^^^ UI Updated with location \(solarDetails.solarDetailsArray[currentPage].location) sunrise should be \(formatter.string(from: solarDetails.solarDetailsArray[currentPage].sunrise))")
        updateMap()
    }
    

    func fetchNextSevenDays() {
        var tempDate = Date()
        for _ in 0..<7 {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)
            solarDetails.solarDetailsArray.append(SolarDetail())
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

extension ViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("I'm sorry - can't show location. User has not authorized it")
        case .restricted:
            print("Access denied. Liekly parental controls are restricting location services")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geoCoder = CLGeocoder()
        var place = ""
        currentLocation = locations.last!
        print("%%%%% \(currentLocation)")
        solarDetails.solarDetailsArray[currentPage].location = currentLocation
        solarDetails.solarDetailsArray[currentPage].coordinate = currentLocation.coordinate
        print("^^ I am trying to update the current page's location with \(currentLocation)")
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler:
            {placemarks, error in
                if placemarks != nil {
                    let placemark = placemarks?.last
                    place = (placemark?.name)!
                } else {
                    print("Erro retrieving place. Error code: \(error!)")
                    place = "Unknown Weather Location"
                }
                print("^^ Do I ever get here??")
                self.solarDetails.solarDetailsArray[self.currentPage].name = place
                self.solarDetails.solarDetailsArray[self.currentPage].coordinate = self.currentLocation.coordinate
                print("^^^ \(self.currentLocation.coordinate)")
                print("Place \(place)")
                self.updateUserInterface(for: self.currentPage)
                
                
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location")
    }
}







