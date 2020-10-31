//
//  Model.swift
//  Stock Screener
//
//  Created by Christian Vila on 1/9/18.
//  Copyright © 2018 NAPPSEntertaiment. All rights reserved.
//
//

import Foundation

let model = Model()

class Model {
    //MARK: - Properties
    var userTicker: [String] = ["AAPL", "BLK"]
    var todaysDate = ""
    var todaysDay: Int = 0
    var trueDay:Int = 0
    var changeInValue: Double = 0.0
    var priceRightNow: Float = 0.0
    var volumeToday: Int = 0
    
    //MARK: - Functions For the Date&Day
    func loadCurrentDate(day: Int) -> String {
        if day > 1 {
            print("bigger than one")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        todaysDate = dateFormatter.string(from: Date())
        return todaysDate
    }
    //Returns Int 1-7 7 being saturday and 1 being sunday
    func loadCurrentDay() -> Int {
        todaysDay = Calendar.current.component(.weekday, from: Date())
        if todaysDay > 1 && todaysDay < 6 {
            print("")
        }else{
            print("comeback during stock hours")
        }
        return todaysDay
    }
    //MARK: - Get Data From API Prices
    func returnPrice(ticker: String, val indexVal: Int?, callback: @escaping (Float) -> Void) {
        let jsonUrlString = "https://api.intrinio.com/data_point?identifier=\(ticker)&item=last_price"
        if let url = URL(string: jsonUrlString) {
            //let day = loadCurrentDay()
            //let date = loadCurrentDate(day: day)
            var request = URLRequest.init(url: url)
            let userName = ""
            let password = ""
            let toEncode = "\(userName):\(password)" //forms the string to be encoded
            let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
            request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                DispatchQueue.main.async {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let priceRightNow = try jsonDecoder.decode(RealTimePrice.self, from: data!)
                        model.priceRightNow = priceRightNow.value
                        
                        
                        /*
                        let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                        let mainArray = (dataDictionary as AnyObject).object(forKey: "data") as! [AnyObject]
                        var dateArray = [String]()
                        var x = 0
                        while x < mainArray.count {
                            dateArray.append(mainArray[x].object(forKey: "date") as! String)
                            x += 1
                        }
                        var foundData = false
                        var index = 0
                        x = 0
                        while !foundData {
                            
                            if date == dateArray[x] {
                                foundData = true
                                index = x
                            }
                            x += 1
                        }
                        let openPrice = mainArray[index].object(forKey: "open") as! Float
                        callback(openPrice)
                        return
                        */
                        let openPrice = priceRightNow.value
                        callback(openPrice)
                        return
                    } catch let jsonErr {
                        print("Error serielaising jason", jsonErr)
                    }
                }
                }.resume()
        }    
    }
    
}

//MARK: - Structs For API Decodable
struct TickerInfo: Decodable {
    let name: String
    let short_description: String
}

struct TickerPriceArray:Decodable {
    let data: Dictionary<String, [TickerPrice]>
}

struct TickerPrice: Decodable {
    let value: Float
    let date: String
    let open: Float
    let high: Float
    let low: Float
    let close: Float
    let volume: Float
    let ex_dividend: Float
    let split_ratio: Float
    let adj_open: Float
    let adj_high: Float
    let adj_low: Float
    let adj_close: Float
    let adj_volume: Float
}
struct PriceForFunc {
    var priceAtOpen: Float
}

struct ChangeInPrice: Decodable {
    var value: Double
}
struct RealTimePrice: Decodable {
    //The Only Value Needed is Value: Float(this is used to display the price in UITableView on load)!!
    let value: Float
}

struct TradeVolumeToday: Decodable {
    let value: Int
}





