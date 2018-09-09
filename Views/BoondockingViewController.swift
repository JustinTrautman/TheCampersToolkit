/*
 ----------------------------------------------------------------------------------------
 
 BoondockingViewController.swift
 TheCampersToolkit
 
 Created by Justin Trautman on 7/13/18.
 Copyright © 2018 Modular Mobile LLC. All rights reserved.
 Justin@modularmobile.net
 
 TODO: - Version 1.5 replace webview with custom API on Firebase.
 
 ----------------------------------------------------------------------------------------
 */

import UIKit
import WebKit

class BoondockingViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: Properties
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://drive.google.com/open?id=1X961m_UTUq8piVbRbB8btwbQQM4mUQ4T&usp=sharing")!
        webView.load(URLRequest(url: url))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
    }
}
