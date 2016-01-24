//
//  ViewController.swift
//  weather-app
//
//  Created by Ilya Shaisultanov on 1/20/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var gradientLayer = CAGradientLayer()
    var weather = Weather()
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var currentLocation: UILabel!
    
    var clouds1: FloatingImageViews!
    var clouds2: FloatingImageViews!
    var clouds3: FloatingImageViews!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 1000
    }

    override func viewDidAppear(animated: Bool) {
        locationAuth()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("333333")
        let loc = locations.last!
        weather._getWeather(forLocation: loc) { () -> () in
            self.updateDisplay()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.debugDescription)
    }
    
    func updateDisplay () {
        temp.text = "\(weather.temp) ºF"
        wind.text = "\(weather.wind) MPH"
        currentLocation.text = "\(weather.location)"
        
        updateBackground()
    }
    
    func updateBackground() {
        let hour = arc4random_uniform(24) //  weather.hour
        let brightness: CGFloat!

        switch (hour) {
        case let x where x < 6:
            brightness = 0.3
        case let x where x >= 6 && x < 8:
            brightness = 0.5
        case let x where x >= 8 && x < 18:
            brightness = 1
        case let x where x >= 18 && x < 20:
            brightness = 0.7
        case let x where x >= 20 && x < 22:
            brightness = 0.5
        case let x where x >= 22:
            brightness = 0.3
        default: brightness = 1
        }
        
        print(hour, brightness)
        
        gradientLayer.frame = self.view.bounds
        
        let color1 = UIColor(hue:0.6, saturation:0.88, brightness:brightness, alpha:1).CGColor as CGColorRef
        let color2 = UIColor(hue:0.55, saturation:0.6, brightness:brightness, alpha:1).CGColor as CGColorRef
        
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        backgroundView.layer.addSublayer(gradientLayer)
        
        let type = brightness < 0.5 ? "dark" : "light"
        let amount = weather.cloudiness / 5
        
        makeClouds(type, amount: amount)
        updateImage(type)
    }
    
    func updateImage (type: String) {
        let name: String!
        
        switch weather.code {
        case let x where x >= 200 && x < 300:
            name = "thunderstorm"
            break
        case let x where x >= 300 && x < 400:
            name = "drizzle"
            break
        case let x where x >= 500 && x < 600:
            name = "rain"
            break
        case let x where x >= 600 && x < 700:
            name = "snow"
            break
        case let x where x >= 700 && x < 800:
            name = "fog"
            break
        case let x where x >= 800 && x < 900:
            name = "clear_\(type)"
            break
        default: name = "clear_\(type)"
        }
        
        weatherIcon.image = UIImage(named: name)
    }
    
    func locationAuth () {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func makeClouds (type: String, amount: Int) {
        
        clouds1 = FloatingImageViews(
            superview: self.backgroundView,
            imageName: "cloud1_\(type)",
            speedBase: 30,
            speedVariance: 3,
            alphaBase: 0.1,
            alphaVariance: 1.5,
            scaleBase: 1,
            scaleVariance: 2
        )
        clouds1.animate(amount/3)
        
        clouds2 = FloatingImageViews(
            superview: self.backgroundView,
            imageName: "cloud2_\(type)",
            speedBase: 30,
            speedVariance: 3,
            alphaBase: 0.1,
            alphaVariance: 1.5,
            scaleBase: 1,
            scaleVariance: 2
        )
        clouds2.animate(amount/3)
        
        clouds3 = FloatingImageViews(
            superview: self.backgroundView,
            imageName: "cloud3_\(type)",
            speedBase: 30,
            speedVariance: 3,
            alphaBase: 0.1,
            alphaVariance: 1.5,
            scaleBase: 1,
            scaleVariance: 2
        )
        clouds3.animate(amount/3)
    }
}

