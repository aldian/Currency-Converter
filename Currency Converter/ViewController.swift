//
//  ViewController.swift
//  Currency Converter
//
//  Created by Aldian Fazrihady on 10/28/15.
//  Copyright © 2015 Aldian Fazrihady. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBOutlet weak var textFieldMultiplier: UITextField!
    @IBOutlet weak var textFieldFrom: UITextField!
    @IBOutlet weak var textFieldTo: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    @IBAction func textFieldMultiplierEditingChanged(sender: UITextField) {
        convertCurrency()
    }
    
    @IBAction func textFieldFromEditingChanged(sender: UITextField) {
        convertCurrency()
    }
    
    @IBAction func textFieldToEditingChanged(sender: UITextField) {
        convertCurrency()
    }
    
    @IBAction func textFieldFromValueChanged(sender: UITextField) {
        
    }
    
    @IBAction func textFieldToValueChanged(sender: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func convertCurrency() {
        var multiplierStr = textFieldMultiplier.text!
        let currencyFrom = textFieldFrom.text!
        let currencyTo = textFieldTo.text!
        
        multiplierStr = multiplierStr.stringByReplacingOccurrencesOfString(",", withString: ".")
        let multiplier = Double(multiplierStr) ?? 1
        
        let url = NSURL(string: "https://www.google.com/finance/converter?a=1&from=" + currencyFrom + "&to=" + currencyTo)
        let request = NSURLRequest(URL: url!)
        //<div id=currency_converter_result>1 SGD = <span class=bld>9727.0004 IDR</span>
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            if let data = data {
                let nsStrData = NSString(data: data, encoding: NSASCIIStringEncoding)
                let strData = nsStrData as! String
                let matches = self.regexMatches("currency_converter_result>[^>]+>([\\S]+)", text: strData)
                print("Matches: \(matches)", separator:"\n")
                if matches.count > 0 {
                    let value = Double(matches[0])!
                    let formatter = NSNumberFormatter()
                    formatter.locale = NSLocale(localeIdentifier: "en_US")
                    formatter.numberStyle = .CurrencyISOCodeStyle
                    var formattedMultiplier = formatter.stringFromNumber(multiplier)!
                    formattedMultiplier = (formattedMultiplier as NSString).substringFromIndex(3)
                    var formattedValue = formatter.stringFromNumber(value * multiplier)!
                    formattedValue = (formattedValue as NSString).substringFromIndex(3)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.labelResult.text = "\(formattedMultiplier) \(currencyFrom) is \(formattedValue) \(currencyTo)"
                    })
                   }
            } else {
                print("No data retrieved")
            }
        }
        task.resume()
    }
    
    func regexMatches(pattern: String!, text: String!) -> Array<String> {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            let matches = re.matchesInString(text, options: [], range: NSRange(location: 0, length: text.characters.count))
            
            var collectMatches: Array<String> = []
            for match in matches {
                // range at index 0: full match
                // range at index 1: first capture group
                let substring = (text as NSString).substringWithRange(match.rangeAtIndex(1))
                collectMatches.append(substring)
            }
            return collectMatches
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

