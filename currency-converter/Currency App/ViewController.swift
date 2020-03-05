//
//  ViewController.swift
//  Currency Converter
//
//  Created by Yoo Bin Shin on 3/2/20.
//  Copyright © 2020 Yoo Bin Shin. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var flagLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    var flag: String = ""
    var symbol: String = ""
    var country: String = ""
    var value: String = ""
    var currency: String = ""
    
    override func viewDidLoad() {
        flagLabel.text = flag
        countryLabel.text = country
        valueLabel.text = value
        currencyLabel.text = currency
    }
}

class ViewController: UITableViewController {

    var currenciesBack = ["USD","EUR", "GBP", "CAD", "AUD", "CNY", "KRW", "JPY", "INR", "SGD", "HKD", "SEK", "CHF", "BTC"]
    
    var currenciesSymbol = ["$","€", "£", "CA$", "AU$", "CN¥", "₩", "¥", "₹", "SG$", "HK$", "Kr", "CHF", "₿"]
    
    var currenciesCountries = ["United States","European Nation", "United Kingdom", "Canada", "Australia", "China", "South Korea", "Japan", "India", "Singapore", "Hong Kong", "Sweden", "Swiss", "Bitcoin"]

    var currencies = ["USD":"🇺🇸","EUR":"🇪🇺","GBP":"🇬🇧","CAD":"🇨🇦","AUD":"🇦🇺","CNY":"🇨🇳","KRW":"🇰🇷","JPY":"🇯🇵","INR":"🇮🇳","SGD":"🇸🇬","HKD":"🇭🇰","SEK":"🇸🇪","CHF":"🇨🇭","BTC":"₿"]
    
    var currencies_data = ["USD":0.0,"EUR":0.0,"GBP":0.0,"CAD":0.0,"AUD":0.0,"CNY":0.0,"KRW":0.0,"JPY":0.0,"INR":0.0,"SGD":0.0,"HKD":0.0,"SEK":0.0,"CHF":0.0,"BTC":0.0]
    
    var currentValue = 1.0 {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = 97
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Offline", message: "Check your connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (s) in}))
            self.present(alert, animated: true, completion: nil)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exchange 1 USD", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add $1", style: .plain, target: self, action: #selector(addOne))]

        loadData()
    }
    
    @objc func addOne() {
        currentValue += 1.0
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exchange " + String(currentValue) + " USD", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add $1", style: .plain, target: self, action: #selector(addOne)), UIBarButtonItem(title: "Sub $1", style: .plain, target: self, action: #selector(subOne))]

    }
    
    @objc func subOne() {
        if currentValue == 2 {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add 1$", style: .plain, target: self, action: #selector(addOne))]
        }
       if currentValue == 1 {
                  return
              }
        currentValue -= 1.0
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exchange " + String(currentValue) + " USD", style: .plain, target: nil, action: nil)
    }
    
    
    @objc func loadData() {
        currencies.keys.forEach {
            let headers = [
                "x-rapidapi-host": "currency-exchange.p.rapidapi.com",
                "x-rapidapi-key": "06b70135bamsh087bf99ed4467a8p12cfc8jsnbc40f6796320"
            ]
            let currency = $0
            let request = NSMutableURLRequest(url: NSURL(string: "https://currency-exchange.p.rapidapi.com/exchange?q=1.0&from=USD&to="+$0)! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                if (error != nil) {
                } else {
                    let valStr = String.init(data: data!, encoding: String.Encoding.utf8)
                    if let doubleValue = Double(valStr!) {
                        
                        DispatchQueue.main.async {
                            let doubleValue = Double(doubleValue)
                            self.currencies_data[currency] = doubleValue

                            self.tableView.reloadData()
                        }
                    }
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                                print(json)
                        } catch {
                            
                        }
                    }
                }
            })

            dataTask.resume()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // your code here
            self.tableView.refreshControl?.endRefreshing()
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currenciesBack.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        let currency = currenciesBack[indexPath.row]
        cell.flagLabel.text = currencies[currency]
        cell.currencyLabel.text = currency
        cell.countryLabel.text = currenciesCountries[indexPath.row]
        cell.symbolLabel.text = currenciesSymbol[indexPath.row]
        cell.valueLabel.text = (currency != "BTC") ? String(format: "%.2f", (currencies_data[currency] ?? 0.0)*currentValue) : String(format: "%.8f", (currencies_data[currency] ?? 0.0)*currentValue)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
            let currency = currenciesBack[indexPath.row]

            if segue.identifier == "detail" {
                let vc = segue.destination as! DetailViewController
                vc.flag = currencies[currency]!
                vc.country = currenciesCountries[indexPath.row]
                vc.currency = currency
                vc.value = currenciesSymbol[indexPath.row]
                let currencyValue = (currency != "BTC") ? String(format: "%.2f", (currencies_data[currency] ?? 0.0)*currentValue) : String(format: "%.8f", (currencies_data[currency] ?? 0.0)*currentValue)
                vc.value = vc.value + " " + currencyValue

            }
        }
    }
}



