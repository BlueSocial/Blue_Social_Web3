//
//  WebContentVC.swift
//  Blue
//
//  Created by Blue.

import UIKit
import WebKit

class WebContentVC: BaseVC, UIWebViewDelegate {
    
    // ----------------------------------------------------------
    //                       MARK: - Outlet -
    // ----------------------------------------------------------
    @IBOutlet weak var lblHeaderTitle   : UILabel!
    @IBOutlet weak var webView          : WKWebView!
    @IBOutlet weak var topView          : UIView!
    @IBOutlet weak var btnBack          : UIButton!
    
    // ----------------------------------------------------------
    //                       MARK: - Property -
    // ----------------------------------------------------------
    var contentType = ContentType(rawValue: 0)
    private var fileName = ""
    var webviewStr = ""
    var dismissEvent: (() -> Void)?
    
    // ----------------------------------------------------------
    //                       MARK: - View Life Cycle -
    // ----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnBack.setTitleColor(UIColor.black, for: .normal)
        
        switch self.contentType {
                
            case .Terms:
                //self.webviewStr = "https://www.profiles.blue/terms_and_conditions"
                // self.webviewStr = "Terms_of_use"
                self.fileName = "Terms_of_use"
                self.lblHeaderTitle.text = "Terms of Use"
                break
                
            case .PrivacyPolicy:
                self.fileName = "Privacy_Policy"
                self.lblHeaderTitle.text = "Privacy Policy"
                break
                
            case .Help:
                self.fileName = "help"
                self.lblHeaderTitle.text = "Help"
                break
                
            case .WorldHealthOraganization:
                self.webviewStr = "https://www.who.int/"
                self.lblHeaderTitle.text = "World Health Oraganization"
                break
                
            case .BlueSocial:
                self.webviewStr = "https://www.profiles.blue/"
                self.lblHeaderTitle.text = "Help"
                break
                
            case .QuestionMark:
                self.webviewStr = "https://www.blue.social"
                self.lblHeaderTitle.text = "Learn More"
                break
                
            case .DashboardQues:
                self.webviewStr = "http://bit.ly/2lFR47C"
                self.lblHeaderTitle.text = "Help"
                break
                
            case .Shop:
                self.webviewStr = "https://blue.social/shop-blue/" //"https://www.blue.social/business-cards-smart/"
                self.lblHeaderTitle.text = "Shop"
                break
                
            case .Invest:
                self.webviewStr = "https://republic.co/blue"
                self.lblHeaderTitle.text = "Invest In Blue"
                break
                
            case .PreSale:
                self.webviewStr = "https://blue.social/pages/blue-social-token-presale"
                self.lblHeaderTitle.text = "PreSale"
                break
                
            case .QRCodeProfile:
                self.lblHeaderTitle.text = "Profile Visit"
                
            case .BuyTokens:
                self.webviewStr = "https://web3.blue.social"
                self.lblHeaderTitle.text = "Buy Tokens"
                
            case .WhitePaper:
                self.webviewStr = "https://whitepaper.blue.social"
                self.lblHeaderTitle.text = "White Paper"
        }
        
        self.webView.navigationDelegate = self
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
        self.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        if self.fileName != "" {
            
            let htmlPath = Bundle.main.path(forResource: self.fileName, ofType: "html")
            let folderPath = Bundle.main.bundlePath
            let baseUrl = URL(fileURLWithPath: folderPath, isDirectory: true)
            
            do {
                let htmlString = try NSString(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8.rawValue)
                self.webView.loadHTMLString(htmlString as String, baseURL: baseUrl)
            } catch {}
            
        } else {
            
            //self.webView.load(NSURLRequest(url: NSURL(string: self.webviewStr)! as URL) as URLRequest)
            if let url = URL(string: self.webviewStr) {
                
                print("urlToLoad: \(url)")
                self.webView.load(URLRequest(url: url))
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.contentType == .Shop {
            self.navigationController?.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: dismissEvent)
        }
    }
    
    deinit {
        print("deinit successful. No Retain Cycle/Leak! in \(self)")
    }
}

// ----------------------------------------------------------
//                       MARK: - Action -
// ----------------------------------------------------------
extension WebContentVC {
    
    @IBAction func btnBackCliked(_ sender: UIButton) {
        
        if self.contentType == .Shop || self.contentType == .Terms || self.contentType == .PrivacyPolicy || self.contentType == .WhitePaper || self.contentType == .BuyTokens {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: dismissEvent)
        }
    }
}

// ----------------------------------------------------------
//                       MARK: - WKNavigationDelegate -
// ----------------------------------------------------------
extension WebContentVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Here you can inspect the navigation action and decide whether to allow or cancel the navigation
        if let url = navigationAction.request.url {
            print("Requested URL: \(url.absoluteString)")
        }
        
        // For example, let's allow all navigation requests
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let script = "javascript:(function() { " + "document.getElementsByClassName('tuto1')[0].style.display='none'; " + "})()"
        
        webView.evaluateJavaScript(script) { (result, error) in
            //if error != nil {}
            
            if let evalError = error {
                print("Error evaluating JavaScript: \(evalError.localizedDescription)")
                // Handle the error here
            } else {
                // No error occurred
                print("JavaScript executed successfully.")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        // Handle non-existent URL or other errors
        //self.showAlertWithOKButton(message: "An error occurred while loading the URL. Please check the URL and try again.")
        
        // Handle non-existent URL or other errors
        if (error as NSError).code == NSURLErrorNotConnectedToInternet ||
            (error as NSError).code == NSURLErrorCannotFindHost {
            //showAlert(message: "The URL you entered might not exist. Please try again with a valid URL.")
            self.showAlertWithOKButton(message: "The URL might not exist")
        } else {
            // Handle other errors (optional)
            print("Error loading URL: \(error)")
        }
    }
}
