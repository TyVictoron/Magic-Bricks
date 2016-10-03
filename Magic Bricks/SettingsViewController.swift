//
//  SettingsViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 12/23/15.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsViewController: UIViewController {

    @IBOutlet weak var gOVCCloseButtonOutlet: UIButton!
    @IBOutlet weak var startVCButtonOutlet: UIButton!
    @IBOutlet weak var secondSelectButtonOutlet: UIButton!
    @IBOutlet weak var secondSelectTextButtonOutlet: UILabel!
    @IBOutlet weak var selectButtonOutlet: UIButton!
    var removeAds = false
    var unlockEasyMode = false
    var counter = 0
    var counter2 = 0
    var highScore = Int()
    var x2 = false
    var activateEasyMode = false
    var activateHardMode = false
    var activateX2 = false
    var selectButtonColor = UIColor.black
    var secondSelectButtonColor = UIColor.black
    var fromGOVC = false
    var fromStartVC = false
    var interstitialEasy: GADInterstitial!
    var interstitialHard: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startVCButtonOutlet.isHidden = true
        gOVCCloseButtonOutlet.isHidden = true
        
        // hide hard mode button
        secondSelectButtonOutlet.isHidden = true
        secondSelectTextButtonOutlet.isHidden = true
        
        if fromGOVC == true {
            startVCButtonOutlet.isHidden = true
            gOVCCloseButtonOutlet.isHidden = false
        }
        
        if fromStartVC == true {
            startVCButtonOutlet.isHidden = false
            gOVCCloseButtonOutlet.isHidden = true
        }
        
        // Preload ad
        self.interstitialEasy = self.createAndLoadAdEasy()
        self.interstitialHard = self.createAndLoadAdHard()
        
        if activateX2 == true {
            x2 = true
        }
        
        selectButtonOutlet.backgroundColor = selectButtonColor
        if selectButtonColor == UIColor.green {
            counter += 1
        }
        
        secondSelectButtonOutlet.backgroundColor = selectButtonColor
        if secondSelectButtonColor == UIColor.green {
            counter2 += 1
        }
        
        // saves high score and other booleans
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(unlockEasyMode, forKey: "unlockEasy")
        defaults.set(removeAds, forKey: "removeAds")
        defaults.set(activateX2, forKey: "X2")
        defaults.synchronize()
        print("Highscore: \(highScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)")
    }
    
    // Creates Easy Mode Ads
    func createAndLoadAdEasy() -> GADInterstitial
    {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-5788120822235976/4171124442")
        
        let request = GADRequest()
        
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        ad.load(request)
        
        return ad
    }
    
    // Creates Hard Mode Ads
    func createAndLoadAdHard() -> GADInterstitial
    {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-5788120822235976/5647857642")
        
        let request = GADRequest()
        
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        ad.load(request)
        
        return ad
    }
    
    @IBAction func closeButton(_ sender: AnyObject) {
        // To: --> StartVC
    }
    
    @IBAction func govcCloseButton(_ sender: AnyObject) {
        // To: --> GameOverVC
    }
    
    //------------------------------------------------------------------------------(FIX)-------------------------------------\\
    //------------------------------------------------------------------------------(FIX)-------------------------------------\\
    @IBAction func selectButton(_ sender: AnyObject) {
        //if unlockEasyMode == true {
            selectButtonOutlet.backgroundColor = UIColor.green
            selectButtonColor = UIColor.green
            activateEasyMode = true
            counter += 1
        
        // other
        secondSelectButtonOutlet.backgroundColor = UIColor.black
        secondSelectButtonColor = UIColor.black
        counter2 = 0
        activateHardMode = false
        
            if counter == 2 && selectButtonColor == UIColor.green {
                selectButtonOutlet.backgroundColor = UIColor.black
                selectButtonColor = UIColor.black
                counter = 0
                activateEasyMode = false
                print(unlockEasyMode)
            }
        //}
        // activate ad
        if (self.interstitialEasy.isReady) {
            self.interstitialEasy.present(fromRootViewController: self)
            
        }
    }
    
    @IBAction func selectButton2(_ sender: UIButton) {
        secondSelectButtonOutlet.backgroundColor = UIColor.green
        secondSelectButtonColor = UIColor.green
        activateHardMode = true
        
        //other
        selectButtonOutlet.backgroundColor = UIColor.black
        selectButtonColor = UIColor.black
        counter = 0
        activateEasyMode = false
        counter2 += 1
        
        if counter == 2 && selectButtonColor == UIColor.green {
            selectButtonOutlet.backgroundColor = UIColor.black
            selectButtonColor = UIColor.black
            counter2 = 0
            activateHardMode = false
        }
        // activate ad
        if (self.interstitialHard.isReady) {
            self.interstitialHard.present(fromRootViewController: self)
            
        }
    }
    //------------------------------------------------------------------------------(FIX)-------------------------------------\\
    //------------------------------------------------------------------------------(FIX)-------------------------------------\\
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartVC" {
            let svc = segue.destination as! ViewController
            svc.removeAds = removeAds
            svc.unlockEasyMode = unlockEasyMode
            svc.activateEasyMode = activateEasyMode
            svc.activateHardMode = activateHardMode
            svc.highScore = highScore
            svc.x2 = x2
            svc.selectButtonColor = selectButtonColor
            svc.activateX2 = activateX2
            svc.activateHardMode = activateHardMode
        }
        if segue.identifier == "GameOverVC" {
            let svc = segue.destination as! GameOverViewController
            svc.removeAds = removeAds
            svc.unlockEasyMode = unlockEasyMode
            svc.activateEasyMode = activateEasyMode
            svc.activateHardMode = activateHardMode
            svc.x2 = x2
            svc.selectButtonColor = selectButtonColor
            svc.activateX2 = activateX2
            svc.highScore = highScore
        }
    }
    
}
