//
//  ViewController.swift
//  Stock Screener
//
//  Created by Christian Vila on 1/7/18.
//  Copyright © 2018 NAPPSEntertaiment. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tickerTextField: UITextField!
    
    //MARK: - Properties
    var ticker = ""
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.brown
        tickerTextField.textColor = UIColor.lightGray
        tickerTextField.text = "Search Ticker"
        tickerTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        tickerTextField.text? = "Search Ticker"
    }
    
    //MARK: - TextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        ticker = textField.text!
        getInfoFromAPI()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    //MARK: - COnfigures The TableView Cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.userTicker.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let openPriceForCell =  model.returnPrice(val: indexPath.row, callback: { openPrice in print(openPrice)  })
        let cell = tableView.dequeueReusableCell(withIdentifier: "tickerCell", for: indexPath) as! TickerTableViewCell
        cell.tickerLabel.text = model.userTicker[indexPath.row]
        model.returnPrice(ticker: model.userTicker[indexPath.row], val: indexPath.row, callback: { openPrice in
            DispatchQueue.main.async {
                cell.priceLabel.text = "\(openPrice)"
            }
        })
        return cell
    }
    
    
    //MARK: - Get Current Date
    func getInfoFromAPI() {
        let jsonUrlString = "https://api.intrinio.com/companies?identifier=\(ticker)"
        guard let url = URL(string: jsonUrlString) else { return }
        var request = URLRequest.init(url: url)
        
        //MARK: - Headers according to api docs.....
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
                let tickerPrice = try jsonDecoder.decode(TickerInfo.self, from: data)
                DispatchQueue.main.async {
                    let stockVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "stockVC") as! StockViewController
                    stockVC.summary = tickerPrice.short_description
                    stockVC.ticker = self.ticker
                    self.present(stockVC, animated: false, completion: {
                    }
                    )
                }
            } catch let jsonErr {
                print("Error serielaising json", jsonErr)
            }
            }.resume()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            model.userTicker.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

