//
//  ViewController.swift
//  jLancaster
//
//  Created by Jake Smith on 14/09/2018.
//  Copyright © 2018 Nebultek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    var timetableInfo = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        let ud: UserDefaults = UserDefaults.standard
        //let data: Data? = ud.object(forKey: "new") as? Data
        if let data: Data = ud.object(forKey: "jLancs") as? Data,let cookie = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookie] {
            cookie.forEach {
                HTTPCookieStorage.shared.setCookie($0)
                print($0)
            }
            
            print("Got the cookies 🍪")
        }
        
        openTimetable()
        
        if let url = URL(string: "https://lancaster.ombiel.co.uk/campusm/home#menu") {
            webview.loadRequest(URLRequest(url: url))
            webview.delegate = self
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTimetable" {
            let timetableVC = segue.destination as! TimetableTableViewController
            timetableVC.timetableInfo = self.timetableInfo
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UIWebViewDelegate {
    
    func openTimetable() {
        let url = URL(string: "https://lancaster.ombiel.co.uk/campusm/sso/calendar/sso_course_timetable/2018281")
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:[[String:String]]],let events = json["events"] {
                    self.timetableInfo = events
                    DispatchQueue.main.sync {
                        //self.performSegue(withIdentifier: "showTimetable", sender: self)
                    }
                }
                
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.getElementById(\"tilesScrollBody\").childNodes[0].style.top='0px';")
        webView.stringByEvaluatingJavaScript(from: "document.getElementById(\"header\").style.display='none';")
        
        let ud: UserDefaults = UserDefaults.standard

            if let cookies = HTTPCookieStorage.shared.cookies {
                if cookies.contains(where: { $0.name == "cosign" }) {
                    let data: NSData = NSKeyedArchiver.archivedData(withRootObject: cookies) as NSData
                    ud.set(data, forKey: "jLancs")
                    print("SAVED COSIGN DATA")
                }
            }
        
    }
    
    
}
