//
//  Weather.swift
//  weather-app
//
//  Created by Ilya Shaisultanov on 1/23/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

class Weather {
    private var _location: String!
    private var _temp: String!
    private var _wind: String!
    private var _desc: String!
    private var _cloudiness: Int!
    private var _hour: Int!
    private var _code: Int!
    private var _lastUpdated: NSDate!
    private let OWM_API_KEY = "d9d3a856c5debdd876891538ce793d9c"
    private let URL = "http://api.openweathermap.org/data/2.5/weather"
    
    var temp: String {
        return _temp
    }
    
    var wind: String {
        return _wind
    }
    
    var location: String {
        return _location
    }
    
    var desc: String {
        return _desc
    }
    
    var cloudiness: Int {
        return _cloudiness
    }
    
    var hour: Int {
        return _hour
    }

    var code: Int {
        return _code
    }
    
    func _getWeather (forLocation loc: CLLocation, cb: () -> ()) {
        let params = [
            "lat": loc.coordinate.latitude,
            "lon": loc.coordinate.longitude,
            "appid": OWM_API_KEY,
            "units": "imperial"
        ]
        
        Alamofire.request(.GET, URL, parameters: params as? [String : AnyObject], encoding: .URLEncodedInURL) .responseJSON { res in
            if let JSON = res.result.value {
                print("JSON: \(JSON)")
                
                if let main = JSON["main"] as? [String: AnyObject] {
                    if let t = main["temp"] as? Double {
                        self._temp = String(Int(t))
                    }
                }
                
                if let wind = JSON["wind"] as? [String: AnyObject] {
                    if let s = wind["speed"] as? Double {
                        self._wind = String(Int(s))
                    }
                }

                if let w = JSON["weather"] as? [[String: AnyObject]] where w.count > 0 {
                    if let d = w[0]["description"] as? String {
                        self._desc = d
                    }
                    
                    if let c = w[0]["id"] as? Int {
                        self._code = c
                    }
                }
                
                if let clouds = JSON["clouds"] as? [String: AnyObject] {
                    if let c = clouds["all"] as? Int {
                        self._cloudiness = c
                    }
                }
                
                self._location = JSON["name"] as! String
                
                self._hour = self._getHour(NSDate())
                self._lastUpdated = NSDate()
            } else {
                print("ugh", res.result, res.data)
            }
            
            cb()
        }
    }
    
    private func _getHour (date: NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        return cal.component(.Hour, fromDate: date)
    }
}
