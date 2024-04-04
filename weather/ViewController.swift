//
//  ViewController.swift
//  weather
//
//  Created by 空野耕介 on 2024/02/28.
//

import UIKit
import CoreLocation
import MapKit
import Foundation

class ViewController: UIViewController,CLLocationManagerDelegate ,UIGestureRecognizerDelegate{
    @IBOutlet var mapView: MKMapView!
    let image =  UIImageView()
    @IBOutlet var pressGesrec: UITapGestureRecognizer!
    var locationManager: CLLocationManager!
    var lon : Double = 0
    var lat : Double = 0
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func mapViewDidPress(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: view)
        let center = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        
        lon  = center.longitude
        lat  = center.latitude
    }
    
    func getLocationInfo(latitude: Double, longitude: Double, completion: @escaping ([[String]]) -> Void) {
        let timezone = "Asia/Tokyo"
        let daily = "weather_code"
        let max = "temperature_2m_max"
        let min = "temperature_2m_min"
        let urlstr = "https://api.open-meteo.com/v1/forecast?"+"latitude=\(latitude)&longitude=\(longitude)&daily=\(daily),\(max),\(min)&timezone=\(timezone)"
        var tempArray = [[String]]()
        var weatherDescriptions: [String] = []
        
        //print(urlstr)
        if let weatherurl = URL(string: urlstr) {
            URLSession.shared.dataTask(with: weatherurl) { data, response, error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    //print(json)
                    if let dailyData = json?["daily"] as? [String: Any],
                       let maxData = dailyData["temperature_2m_max"] as? [Double] ,let minData = dailyData["temperature_2m_min"] as? [Double],let timeData = dailyData["time"] as? [String] ,let wetherData = dailyData["weather_code"]as? [Double] {
                        print("max data: \(maxData)")
                        print("min data: \(minData)")
                        print("wether data: \(wetherData)")
                        print("timedata: \(timeData)")
                        
                        for i in 0..<5{
                            switch wetherData[i] {
                            case 0:
                                weatherDescriptions.append("晴天")
                            case 1, 2, 3:
                                weatherDescriptions.append("晴れ時々曇り、曇り")
                            case 45, 48:
                                weatherDescriptions.append("霧と降る霧氷")
                            case 51, 53, 55:
                                weatherDescriptions.append("霧雨: 軽い、中程度、そして濃い強度")
                            case 56, 57:
                                weatherDescriptions.append("氷結霧雨: 軽くて濃い強度")
                            case 61, 63, 65:
                                weatherDescriptions.append("雨：小雨、中程度、激しい雨")
                            case 66, 67:
                                weatherDescriptions.append("凍てつく雨：軽くて激しい雨")
                            case 71, 73, 75:
                                weatherDescriptions.append("降雪量: わずか、中程度、激しい")
                            case 77:
                                weatherDescriptions.append("雪の粒")
                            case 80, 81, 82:
                                weatherDescriptions.append("にわか雨：小雨、中程度、激しい雨")
                            case 85, 86:
                                weatherDescriptions.append("雪が少し降ったり、激しく降ったりします")
                            case 95, 96, 99:
                                weatherDescriptions.append("雷雨: わずかまたは中程度、わずかまたは激しいひょうを伴う雷雨")
                            default:
                                weatherDescriptions.append("その他の天候")
                            }
                            tempArray.append(["\(timeData[i]) ","最高気温\(maxData[i])°C","最低気温\(minData[i])°C","\(weatherDescriptions[i])"])
                        }
                        
                        completion(tempArray)
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for view in self.view.subviews {
            if let label = view as? UILabel {
                label.isHidden = true
            }
        }

        let label = UILabel()
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            label.frame = CGRect(x: location.x, y:location.y, width: 100,height: 220)
        }
    
        getLocationInfo(latitude:lat,longitude:lon){ testArray in
            let array = testArray.map{$0.joined(separator: "\n") }.joined(separator: "\n")
            print("test\(array)")
            DispatchQueue.main.async {
                label.text = array
                label.numberOfLines = 0
                label.backgroundColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 8)
            }
        }
        view.addSubview(label)
    }
}
    

    
    



