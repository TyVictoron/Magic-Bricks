//
//  ViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 12/22/15.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import AVFoundation
import iAd
import GameKit
import CoreData

class ViewController: UIViewController, AVAudioPlayerDelegate, ADBannerViewDelegate {

    @IBOutlet weak var playOutlet: UIButton!
    @IBOutlet weak var yalpOutlet: UIButton!
    var backgroundMusic = AVAudioPlayer()
    var clicks = 0
    var highScore = Int()
    var highScoreUpdated = Bool()
    
    var removeAds = false
    var unlockEasyMode = false
    var activateX2 = false
    var x2 = false
    var activateEasyMode = false
    var activateHardMode = false
    var selectButtonColor = UIColor.black
    var secondSelectButton = UIColor.black
    
    @IBOutlet weak var reversePlayButton: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playOutlet.layer.cornerRadius = 10
        yalpOutlet.layer.cornerRadius = 10
        print(unlockEasyMode)
        
        let defaults: UserDefaults = UserDefaults.standard
        let savedScore = defaults.integer(forKey: "highScore")
        highScore = savedScore // Causes App to crash in release mode
        let savedX2 = defaults.bool(forKey: "X2")
        activateX2 = savedX2 // Causes App to crash in release mode
        let savedRemoveAds = defaults.bool(forKey: "removeAds")
        removeAds = savedRemoveAds // Causes App to crash in release mode
        let savedEasy = defaults.bool(forKey: "unlockEasy")
        unlockEasyMode = savedEasy // Causes App to crash in release mode
        
        x2 = false
        if activateX2 == true {
            x2 = true
        }
        
        // saves high score
        if highScoreUpdated == true {
            let defaults: UserDefaults = UserDefaults.standard
            defaults.set(highScore, forKey: "highScore")
            defaults.set(unlockEasyMode, forKey: "unlockEasy")
            defaults.set(removeAds, forKey: "removeAds")
            defaults.set(x2, forKey: "X2")
            defaults.synchronize()
            print("Saved- Highscore: \(highScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)")
            
        }
        
        print("Highscore: \(highScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)", "Remove Ads: \(removeAds)")
        
        reversePlayButton.isHidden = true
        
        if highScore >= 200 {
            reversePlayButton.isHidden = false
        }
        
        lblScore.text = "Cubes Eaten: \(highScore)"
        
        // infinently loop the background music
        backgroundMusic = self.setupAudioPlayerWithFile("MagicBricks - MainTheme", type:"mp3")
        backgroundMusic.play()
        backgroundMusic.numberOfLoops = -1
        
        lblScore.text = "Cubes Eaten: \(highScore)"
    }
    
    // Sound setup
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
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
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func yalpButtonAction(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        backgroundMusic.stop()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        if segue.identifier == "SettingsVC" {
            let gvc = segue.destination as! SettingsViewController
            gvc.removeAds = removeAds
            gvc.unlockEasyMode = unlockEasyMode
            gvc.activateEasyMode = activateEasyMode
            gvc.activateHardMode = activateHardMode
            gvc.highScore = highScore
            gvc.x2 = x2
            gvc.selectButtonColor = selectButtonColor
            gvc.activateX2 = activateX2
            gvc.fromStartVC = true
        }
        if segue.identifier == "ReverseVC" {
            let gvc = segue.destination as! ReverseGameViewController
            gvc.removeAds = removeAds
            gvc.unlockEasyMode = unlockEasyMode
            gvc.activateEasyMode = activateEasyMode
            gvc.activateHardMode = activateHardMode
            gvc.highScore = highScore
            gvc.x2 = x2
            gvc.selectButtonColor = selectButtonColor
            gvc.activateX2 = activateX2
        }
    }
}

