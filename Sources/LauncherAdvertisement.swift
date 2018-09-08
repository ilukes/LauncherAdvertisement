//
//  LauncherAdvertising.swift
//  Todays Exchange Rate
//
//  Created by Lukes Lu on 2018/9/1.
//  Copyright © 2018 Lukes Lu. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class LauncherAdvertisement: NSObject, GADInterstitialDelegate {
    
    // MARK: - Public
    
    public static let instance = LauncherAdvertisement()
    
    // MARK: - Property
    
    private var advertisingViewController: UIViewController!
    private var window: UIWindow!
    private var interstitial: GADInterstitial!
    private var advertisingLoaded: Bool = false
    private var isHide: Bool = false
    private var requestTimeOut: TimeInterval = 4
    
    // MARK: - Lifecycle
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: nil) { (_) in
            self.show()
            self.checkAdvertising()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (_) in
            self.hide()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
            // You can show Advertising here if you want to every time when user come back to your App. But I think is not good to do that.
            //self.show()
            //self.checkAdvertising()
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAdvertising() {
        // You can check your user is unlimit or not, if it is, then you can call the hide method here
        
        #if DEBUG
        self.interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-3940256099942544/4411468910") // Debug use the test id
        #else
        self.interstitial = GADInterstitial.init(adUnitID: "ca-app-pub-6133849407003029/9350301013") // Replace with your id (Note: Here is the Unit ID not Application ID)
        #endif
        
        self.interstitial.delegate = self
        self.interstitial.load(GADRequest())
        
        // If the request got too long(You can change the time out on property to your, the default is 4 seconds), you can just hide the ad view. (P.S  seems GADInterstitial don't have cancel method!?)
        DispatchQueue.main.asyncAfter(deadline: .now()+self.requestTimeOut) {
            if !self.advertisingLoaded {
                self.hide()
            }
        }
    }
    
    private func show() {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.advertisingViewController = UIViewController.init()
        self.window.rootViewController = self.advertisingViewController
        self.window.rootViewController?.view.backgroundColor = .clear
        self.window.rootViewController?.view.isUserInteractionEnabled = false
        
        self.setupSubviews(window: self.window)
        
        self.window.windowLevel = UIWindow.Level.statusBar+1
        self.window.isHidden = false
        self.window.alpha = 1.0
        self.isHide = false
    }
    
    private func hide() {
        if self.isHide {
            return
        }
        
        self.isHide = true
        UIView.animate(withDuration: 0.35, animations: {
            self.window.alpha = 0
        }) { (_) in
            for view in self.window.subviews {
                view.removeFromSuperview()
            }
            
            self.window.isHidden = true
            self.advertisingViewController = nil
            self.window = nil
        }
    }
    
    private func setupSubviews(window: UIWindow) {
        // I use LaunchScreen.storyboard for my launch screen, so I use this way to take a screenshot. If you use LaunchImage or want to different image in here. You can just set the image to UIImageView. (Note: You must set the LaunchViewController identifier to "Launch".)
        let storyboard = UIStoryboard.init(name: "LaunchScreen", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Launch")
        
        let imageView = UIImageView.init(frame: UIScreen.main.bounds)
        imageView.image = vc.view.takeScreenshot()
        imageView.contentMode = .scaleAspectFill
        window.addSubview(imageView)
    }
    
    // MARK: - GADInterstitialDelegate
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        self.advertisingLoaded = true
        self.interstitial.present(fromRootViewController: self.advertisingViewController)
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.advertisingLoaded = true
        self.hide()
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {}
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) { }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.hide()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) { }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        self.hide()
    }
    
}


extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil) {
            return image!
        }
        
        return UIImage()
    }
}

