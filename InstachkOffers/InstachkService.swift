//
//  InstachkService.swift
//  AdViewApp
//
//  Created by Ravi on 6/7/17.
//  Copyright © 2017 Instachk. All rights reserved.
//

import UIKit
import Starscream
import CoreLocation


class InstachkService : NSObject, WebSocketDelegate, CLLocationManagerDelegate {
    
    // Google Cloud endpoints
    let WS_SERVER_ENDPOINT = "ws://35.185.19.20:3000"
    let HTTP_SERVER_ENDPOINT = "http://35.185.19.20:3000/api/v1/users/"
    
    var socket : WebSocket
    var apiKey : String!
    var partnerKey : String
    var lastLocation : CLLocation?
    var lastUpdatedLocation : CLLocation?
    var connected : Bool
    var delegate : MessageListener?
    var locationManager: CLLocationManager?
    
    init(partnerKey : String) {
        self.connected = false
        self.partnerKey = partnerKey
        self.socket = WebSocket(url: URL(string: self.WS_SERVER_ENDPOINT + "/cable")!)
        super.init()
        self.socket.delegate = self
    }
    
    func initialize() {
        let settings = UserDefaults.standard
        let storedAPIKey = settings.string(forKey: "apiKey")
        if (storedAPIKey == nil) {
            self.registerAndInitializeAPIKey(settings: settings);
        } else {
            self.apiKey = storedAPIKey!
            self.connectWebSocket()
        }
    }
    
    private func initializeLocationManager() {
        self.locationManager = CLLocationManager()
        
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        let distanceThreshold : CLLocationDistance = 10
        
        if (self.lastUpdatedLocation == nil || self.lastUpdatedLocation!.distance(from: latestLocation) > distanceThreshold) {
            self.lastLocation = latestLocation
            self.lastUpdatedLocation = self.lastLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Error from location manager")
    }
    
    private func registerAndInitializeAPIKey(settings : UserDefaults) {
        let iosId = UIDevice.current.identifierForVendor!.uuidString
        
        print("InstachkService", "API key NOT found locally, initializing from server...");
        
        let deviceId = "AF4B2INST" + iosId;
        
        do {
            //prepare the request
            let jsonMap: [String: Any] = [
                "device_id": deviceId,
                "email": deviceId + "@instachk.today"
            ]
            
            let requestURL = URL(string: self.HTTP_SERVER_ENDPOINT + "register")!
            
            print("Endpoint: \(requestURL)")
            
            var urlRequest = URLRequest(url: requestURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            // adding package name
            urlRequest.setValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "Package-Name")
            
            // adding api key
            urlRequest.setValue("Token token=\(self.apiKey ?? "null")::\(self.partnerKey)", forHTTPHeaderField: "Authorization")
            
            // TODO - remove print
            print("Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonMap, options: [])
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) { data, response, error in
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: [])
                            as? [String: Any]
                            else {
                                print("Could not get JSON from responseData as dictionary")
                                return
                        }
                        
                        print("json received: \(json)")
                        
                        let fetchedAPIKey = json["api_key"]
                        
                        print("API Key received: \(fetchedAPIKey ?? "not received")")
                        
                        settings.setValue(fetchedAPIKey, forKey: "apiKey")
                        
                        settings.synchronize()
                        
                        self.apiKey = fetchedAPIKey as! String
                        
                        self.connectWebSocket()
                    } catch {
                        print("Could not get JSON from responseData as dictionary")
                    }
                } else  {
                    print("Failed registering user")
                }
            }
            
            task.resume()
        } catch {
            print("Failed registering user")
        }
    }
    
    
    // TODO - move headers to a single function
    public func activateCoupon(advertisement_id: Int) {
        print("Advertisement id: \(advertisement_id)")
        do {
            //prepare the request
            let jsonMap: [String: Any] = [
                "advertisement_id": advertisement_id
            ]
            
            let requestURL = URL(string: self.HTTP_SERVER_ENDPOINT + "activate-coupon")!
            
            print("Endpoint: \(requestURL)")
            
            var urlRequest = URLRequest(url: requestURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            // adding package name
            urlRequest.setValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "Package-Name")
            
            // adding api key
            urlRequest.setValue("Token token=\(self.apiKey ?? "null")::\(self.partnerKey)", forHTTPHeaderField: "Authorization")
            
            // TODO - remove print
            print("Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonMap, options: [])
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) { data, response, error in
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                print("status code \(statusCode)")
                
                if (statusCode == 200) {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!, options: [])
                            as? [String: Any]
                            else {
                                print("Could not get JSON from responseData as dictionary")
                                return
                        }
                        
                        print("json received: \(json)")
                        
                        if (json["error"] as? String) != nil {
                            print("Error in coupon activation!")
                        }else{
                            print("Coupon activated successfully!")
                            self.delegate!.onCouponActivated(advertisement_id: advertisement_id)
                        }
                        
                        
                    } catch {
                        print("Could not get JSON from responseData as dictionary")
                    }
                } else  {
                    print("Failed activate coupon")
                }
            }
            
            task.resume()
        } catch {
            print("Failed registering user")
        }
    }
    
    func convertToDictionary(text: String) -> [String: AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func connectWebSocket() {
        self.socket.headers["Content-Type"] = "application/json; charset=utf-8"
        self.socket.headers["Package-Name"] = Bundle.main.bundleIdentifier!
        
        // TODO - 'api_key' should be 'token' in every request. Change this on server
        socket.headers["Authorization"] = "Token api_key=\(self.apiKey ?? "null")::\(self.partnerKey)"
        self.socket.connect()
    }
    
    func sendMessage(message : String) {
        print("InstachkService", "WS: Sending message to server");
        
        let jsonMap: [String: Any] = [
            "command": "message",
            "identifier": "{\"channel\":\"WebNotificationsChannel\"}",
            "data": "{\"message\":\"" + message + "\"}"
        ]
        
        let json: Data
        do {
            json = try JSONSerialization.data(withJSONObject: jsonMap, options: [])
            self.sendData(d: json)
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
    }
    
    func subscribe(channel : String) {
        print("InstachkService", "WS: Subscribing to channel");
        
        let jsonMap: [String: Any] = [
            "command": "subscribe",
            "identifier": "{\"channel\":\"" + channel + "\"}"
        ]
        
        let json: Data
        do {
            json = try JSONSerialization.data(withJSONObject: jsonMap, options: [])
            self.sendData(d: json)
        } catch {
            print("Error: cannot create JSON for subscribe")
            return
        }
    }
    
    private func basicConnect() {
        print("InstachkService", "WS: Basic connection")
        self.sendMessage(message: "insta-connection;" + self.apiKey!)
        self.initializeLocationManager()
    }
    
    func updateLocation(location : CLLocation) {
        if (connected) {
            print("InstachkService", "WS: Updating location")
            self.sendMessage(message: "update-location;" + self.apiKey! + ";\(location.coordinate.latitude);\(location.coordinate.longitude)")
        } else {
            self.lastLocation = location
        }
    }
    
    private func flushLastLocation() {
        if (self.lastLocation != nil) {
            print("InstachkService", "WS: Flushing last location")
            self.updateLocation(location: self.lastLocation!)
            self.lastLocation = nil
        }
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("Connected!")
        self.subscribe(channel: "WebNotificationsChannel");
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Disconnected!")
        self.connected = false
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Receive data")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        // print("websocketDidReceiveMessage: \(text)")
        do {
            let data = text.data(using: String.Encoding.utf8)!
            guard let json = try JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any]
                else {
                    print("Could not get JSON from responseData as dictionary")
                    return
            }
            
            
            let type = json["type"]
            
            if (type != nil) {
                let typeAsString : String = type as! String
                if ("welcome" == typeAsString) {
                    print("InstachkService", "WS: Welcome received");
                    self.connected = true
                    self.basicConnect()
                    self.flushLastLocation()
                }
                if ("ping" != typeAsString) {
                    print("InstachkService", "WS: Message with type received");
                    self.onMessageReceived(message: text);
                } else {
                    // print("InstachkService", "WS: Ping received");
                    self.flushLastLocation()
                }
            } else {
                print("InstachkService", "WS: Message without type received");
                let message = json["message"]
                if (message != nil) {
                    self.onMessageReceived(message: message as! String);
                }
            }
        } catch  {
            print("Error parsing message response")
            return
        }
    }
    
    private func onMessageReceived(message : String) {
        if (self.delegate != nil) {
            self.delegate!.instachkOnMessageReceived(message: message)
        }
    }
    
    func setDelegate(delegate : MessageListener) {
        self.delegate = delegate
    }
    
    private func sendData(d : Data) {
        let string = String(data: d, encoding: String.Encoding.utf8)
        self.sendString(s: string!)
    }
    
    private func sendString(s : String) {
        print("Sending data: \(s)")
        
        print("headers: \(self.socket.headers)")
        self.socket.write(string: s)
    }
}
