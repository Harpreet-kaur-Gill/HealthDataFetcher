//
//  FitBitLogin.swift
//  TemApp
//
//  Created by Harpreet_kaur on 01/07/19.
//  Copyright © 2019 Saurav. All rights reserved.
//

import UIKit

@objc class FitBitLogin: UIViewController {
    
    //MARK:-Variables.
    var urlString:String?
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: self.urlString ?? "")
        let requestObj = URLRequest(url: url! as URL)
        webView.loadRequest(requestObj)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
}


//MARK:- UIWebViewDelegate.
extension FitBitLogin:UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("FitbitNotificationFitbitNotificationFitbitNotificationFitbitNotification")
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    }
}

extension FitBitLogin : SFSafariViewControllerDelegate {
    
}
