//
//  GameOverViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 1/28/16.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import GameKit
import StoreKit
import GoogleMobileAds

class GameOverViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var x2CubesOutlet: UIButton!
    @IBOutlet weak var storeButtonOutlet: UIButton!
    @IBOutlet weak var retryOutlet: UIButton!
    @IBOutlet weak var quitOutlet: UIButton!
    
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var insultLabel: UILabel!
    @objc var interstitial: GADInterstitial!
    @objc var banner: GADBannerView!
    @objc var highScore = Int()
    @objc var currentScore = 0
    @objc var backgroundMusic = AVAudioPlayer()
    
    @objc var highScoreUpdated = Bool()
    @objc var gcEnabled = Bool() // Stores if the user has Game Center enabled
    @objc var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    
    @objc var activateX2 = false
    @objc var x2 = false
    @objc var removeAds = false
    @objc var isAdShowing = false
    @objc var unlockEasyMode = false
    @objc var activateEasyMode = false
    @objc var activateHardMode = false
    @objc var selectButtonColor = UIColor.black
    @objc var secondSelectButton = UIColor.black
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if removeAds == true {
            print("No More Ads! ( YAY! )")
            isAdShowing = false
        }
        else {
            loadAd()
            isAdShowing = true
        }
        
        loadAd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeButtonOutlet.isHidden = true
        
        // Preload ad
        self.interstitial = self.createAndLoadAd()
        self.banner = self.loadAd()
        
        loadAd()
        
        print("RemoveAds:",removeAds)
        if removeAds == true {
            print("No More Ads! ( YAY! )")
            isAdShowing = false
        }
        else {
            loadAd()
            isAdShowing = true
        }
        
        x2 = false
        if activateX2 == true {
            x2 = true
        }
        
        print("X2: \(x2)", "RemoveAds: \(removeAds)", "Unlock EasyMode: \(unlockEasyMode)")
        
        x2CubesOutlet.layer.cornerRadius = 10
        storeButtonOutlet.layer.cornerRadius = 10
        retryOutlet.layer.cornerRadius = 10
        quitOutlet.layer.cornerRadius = 10
        
        isAdShowing = false
        
        
        
        // saves high score and other booleans
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(unlockEasyMode, forKey: "unlockEasy")
        defaults.set(removeAds, forKey: "removeAds")
        defaults.set(activateX2, forKey: "X2")
        defaults.synchronize()
        print("Highscore: \(highScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)")
        
        print("Current Score: \(currentScore)")
        
        // sets up labels and updates high score if currentScore is larger
        currentScoreLabel.text = "Current Cubes Eaten: \(currentScore)"
        highScoreLabel.text = "Most Cubes Eaten: \(highScore)"
        if currentScore >= highScore {
            highScore = currentScore
            highScoreLabel.text = "Most Cubes Eaten: \(highScore)"
        }
        
        // Insult Label Insults
        if currentScore <= 5 {
            insultLabel.text = "Come On You Can Do Better Than That!"
        }
        else if currentScore > 5 && currentScore < 30 {
            insultLabel.text = "Well at least its not zero!"
            insultLabel.textColor = UIColor.red
        }
        else if currentScore >= 30 && currentScore < 60 {
            insultLabel.text = "Well Thats... Ok."
            insultLabel.textColor = UIColor.red
        }
        else if currentScore >= 60 && currentScore < 100 {
            insultLabel.text = "I'm Positive You CAN Do Better!"
            insultLabel.textColor = UIColor.orange
        }
        else if currentScore >= 100 && currentScore < 150 {
            insultLabel.text = "Now We're Getting Somewhere! But You Could Still Do Better!"
            insultLabel.textColor = UIColor.yellow
        }
        else if currentScore >= 150 && currentScore < 7000 {
            insultLabel.text = "Finally In a more decent number range! Good Job!"
            insultLabel.textColor = UIColor.green
        }
        else if currentScore >= 7000 {
            insultLabel.text = "Well... I dont even know what to say, you MUST Have used the cheat, this is not possible to get here!"
            insultLabel.textColor = UIColor.cyan
        }
        else if currentScore >= 15000 {
            insultLabel.text = "You Are LITERALY God!"
            insultLabel.textColor = UIColor.blue
        }
        
        // infinently loop the background music
        backgroundMusic = self.setupAudioPlayerWithFile("GameOverViewMusic - Magic Bricks", type:"mp3")
        backgroundMusic.stop()
        backgroundMusic.play()
        backgroundMusic.numberOfLoops = -1
        
    }
    
    // Sound setup
    @objc func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType:type as String)
        let url = URL(fileURLWithPath: path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }
        
        //4
        return audioPlayer!
    }
    
    @IBAction func x2Button(_ sender: UIButton) {
        // activate ad
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
            self.x2 = true
            print("X2 Activated!")
            
        }
    }
    
    @IBAction func gameOverSettingsButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func storeButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func retryButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func quitButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func x2CubesButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    // Creates Ads
    @objc func createAndLoadAd() -> GADInterstitial
    {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-5788120822235976/7574298045")
        
        let request = GADRequest()
        
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        ad.load(request)
        
        return ad
    }
    
    @objc func loadAd() -> GADBannerView {
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.adUnitID = "ca-app-pub-5788120822235976/9618679249"
        banner.rootViewController = self
        let request = GADRequest()
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        banner.load(request)
        banner.frame = CGRect(x: 0, y: view.bounds.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        self.view.addSubview(banner)
        
        return banner
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartVC" {
            let svc = segue.destination as! ViewController
            if highScore > svc.highScore {
                svc.highScore = highScore
                svc.highScoreUpdated = true
                let highScoreDefault = UserDefaults.standard
                highScoreDefault.setValue(highScore, forKey: "highScore")
                highScoreDefault.synchronize()
                svc.x2 = x2
                svc.removeAds = removeAds
                svc.unlockEasyMode = unlockEasyMode
                svc.activateHardMode = activateHardMode
                svc.selectButtonColor = selectButtonColor
            }
            else {
                svc.highScoreUpdated = false
            }
        }
        if segue.identifier == "GameVC" {
            let gvc = segue.destination as! GameViewController
            gvc.higherScore = highScore
            gvc.removeAds = removeAds
            gvc.unlockEasyMode = unlockEasyMode
            gvc.activateEasyMode = activateEasyMode
            gvc.activateHardMode = activateHardMode
            gvc.x2 = x2
            gvc.selectButtonColor = selectButtonColor
            gvc.activateX2 = activateX2
        }
        if segue.identifier == "StoreVC" {
            let gvc = segue.destination as! StoreViewController
            gvc.highScore = highScore
            gvc.removeAds = removeAds
            gvc.unlockEasyMode = unlockEasyMode
            gvc.activateEasyMode = activateEasyMode
            gvc.activateHardMode = activateHardMode
            gvc.x2 = x2
            gvc.selectButtonColor = selectButtonColor
            gvc.activateX2 = activateX2
        }
        if segue.identifier == "GameOverSetingsVC" {
            let gvc = segue.destination as! SettingsViewController
            gvc.removeAds = removeAds
            gvc.unlockEasyMode = unlockEasyMode
            gvc.activateEasyMode = activateEasyMode
            gvc.activateHardMode = activateHardMode
            gvc.highScore = highScore
            gvc.x2 = x2
            gvc.selectButtonColor = selectButtonColor
            gvc.activateX2 = activateX2
            gvc.fromGOVC = true
        }
    }
}
