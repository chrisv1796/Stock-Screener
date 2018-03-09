//
//  StockViewController.swift
//  Stock Screener
//
//  Created by Christian Vila on 1/9/18.
//  Copyright © 2018 NAPPSEntertaiment. All rights reserved.
//
// The passModel is a constant of type PasswordModel() which is a class that stores the username and password in one
//place and is called whenever its needs to be accessed.

import UIKit

let passModel = PasswordModel()
class StockViewController: UIViewController {
    let customGrey: UIColor = UIColor(red: 97/255, green: 106/255, blue: 107/255, alpha: 1)
    let customGreen: UIColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    let customRed: UIColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
    var summary = ""
    var ticker = ""
    var volume = 0
    //MARK: - Outlets
    @IBOutlet var tickerLabl: UILabel!
    @IBOutlet var bottomBar: UIView!
    @IBOutlet var rightSideBar: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var summaryTextView: UITextView!
    @IBOutlet var leftSideBar: UIView!
    @IBOutlet var lastPriceLabl: UILabel!
    @IBOutlet var changeInPriceLabl: UILabel!
    @IBOutlet var volumeLabel: UILabel!
    //MARK: - View Did Load
    override func viewDidLoad() {
        testIfThisRuns()
        self.tickerLabl.text = "$\(ticker)"
        self.view.backgroundColor = customGrey
        self.navigationController?.title = "Label"
        super.viewDidLoad()
        volumeForToday(ticker: ticker)
        changeInPrice(ticker: ticker)
        model.returnPrice(ticker: ticker, val: nil, callback: { openPrice in
            DispatchQueue.main.async {
                self.lastPriceLabl.text = " $\(openPrice)"
            }
        })
        summaryTextView.text = summary
        summaryTextView.backgroundColor = customGrey
        //print("summary\(summary)")
        //print("Ticker:\(ticker)")
    }    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func addToArray(_ sender: UIButton) {
        model.userTicker.append(ticker)
    }
    @IBAction func backHome(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func changeInPrice(ticker: String) {
        let jsonUrlString = "https://api.intrinio.com/data_point?identifier=\(ticker)&item=change"
        guard let url = URL(string: jsonUrlString) else { return }
        var request = URLRequest.init(url: url)
        
        //MARK: - Headers according to api docs.....
        let userName =  String(passModel.userName)
        let password = String(passModel.password)
        let toEncode = "\(userName):\(password)" //forms the string to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            //   let dataAsString = String(data: data!, encoding: .utf8)
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let change = try jsonDecoder.decode(ChangeInPrice.self, from: data)
                DispatchQueue.main.async {
                    model.changeInValue = change.value
                    print(model.changeInValue)
                    self.changeInPriceLabl.text = "$ \(model.changeInValue)"
                    if model.changeInValue >= 0.0 {
                        self.changeBackGroundToGreen()
                    }else{
                        self.changeBackGroundToRed()
                    }
                }
            } catch let jsonErr {
                print("Error serielaising json", jsonErr)
            }
            }.resume()
    }
    func volumeForToday(ticker: String) {
        print("This Func Is Indeed Getting called")
        let jsonUrlString = "https://api.intrinio.com/data_point?identifier=\(ticker)&item=volume"
        guard let url = URL(string: jsonUrlString) else { return }
        var request = URLRequest.init(url: url)
        
        //MARK: - Headers according to api docs.....
            //The Username and Password are provied by Intrinio in your profile to access the data
        let userName = String(passModel.userName)
        let password = String(passModel.password)
        let toEncode = "\(userName):\(password)" //forms the string to be encoded
        let encoded = toEncode.data(using: .utf8)?.base64EncodedString()
        request.addValue("Basic \(encoded!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, err) in
            //   let dataAsString = String(data: data!, encoding: .utf8)
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let volume = try jsonDecoder.decode(TradeVolumeToday.self, from: data)
                DispatchQueue.main.async {
                    model.volumeToday = volume.value
                    self.volumeLabel.text = "Volume: \(volume.value)"
                }
            } catch let jsonErr {
                print("Error serielaising json", jsonErr)
            }
            }.resume()
    }
    
    func changeBackGroundToGreen() {
        UIView.animate(withDuration: 0.3, animations: {
            self.headerView.backgroundColor = self.customGreen
            self.leftSideBar.backgroundColor = self.customGreen
            self.rightSideBar.backgroundColor = self.customGreen
            self.bottomBar.backgroundColor = self.customGreen
        })
    }
    func changeBackGroundToRed() {
        UIView.animate(withDuration: 0.3, animations: {
            self.headerView.backgroundColor = self.customRed
            self.leftSideBar.backgroundColor = self.customRed
            self.rightSideBar.backgroundColor = self.customRed
            self.bottomBar.backgroundColor = self.customRed
        })
    }
    func testIfThisRuns() {
        print("Yo What You Doin?")
    }
    
    
}


