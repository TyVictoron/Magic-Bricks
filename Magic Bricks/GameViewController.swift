//
//  GameViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 12/23/15.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController, AVAudioPlayerDelegate, UICollisionBehaviorDelegate {

    //Quit statememt variables
    @IBOutlet weak var quitLabel: UILabel!
    @IBOutlet weak var noButtonOutlet: UIButton!
    @IBOutlet weak var yesButtonOutlet: UIButton!
    
    //Other Variables
    @IBOutlet weak var pauseButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var moneyCheatActivatedLabel: UILabel!
    @IBOutlet weak var waveLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dificultyLevel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    var backgroundMusic = AVAudioPlayer()
    var collisionBehavior = UICollisionBehavior()
    var dynamicAnimator = UIDynamicAnimator()
    var wave = 0
    var blocks = 0
    var face = UIView()
    var cube = UIView()
    var magicCubes : [UIView] = []
    var waveComplete = false
    var cubeSpeed = 10
    var allObjects : [UIView] = []
    var isWaveEnded = false
    var gameIsOver = false
    var score = 0
    var brickSpeed = Double(0.07)
    var higherScore = 0
    var randomNumberOfBricks = Int(arc4random_uniform(UInt32(5)))
    var lives = 10
    var timesTapped = 0
    
    // Timer Variables
    var time = 5
    var counting = false
    
    var removeAds = false
    var x2 = false
    var unlockEasyMode = false
    var activateX2 = false
    var activateEasyMode = false
    var activateHardMode = false
    var selectButtonColor = UIColor.black
    var secondSelectButton = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if activateX2 == true {
            x2 = true
        }
        
        gameIsOver = false
        
        // saves high score and other booleans
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(higherScore, forKey: "highScore")
        defaults.set(unlockEasyMode, forKey: "unlockEasy")
        defaults.set(removeAds, forKey: "removeAds")
        defaults.set(x2, forKey: "X2")
        defaults.synchronize()

        print("X2: \(x2)", "RemoveAds: \(removeAds)", "Activate EasyMode: \(activateEasyMode)")
        
        yesButtonOutlet.layer.cornerRadius = 10
        noButtonOutlet.layer.cornerRadius = 10
        nextButtonOutlet.layer.cornerRadius = 10
        nextButtonOutlet.isHidden = true
        highScoreLabel.text = "Most Cubes Eaten: \(higherScore)"
        moneyCheatActivatedLabel.isHidden = true
        quitLabel.isHidden = true
        noButtonOutlet.isHidden = true
        yesButtonOutlet.isHidden = true
        
        if score > higherScore {
            higherScore = score
            highScoreLabel.text = "Most Cubes Eaten: \(higherScore)"
        }
        
        // add a yellow ball object to the view
        face = UIView(frame: CGRect(x: view.center.x, y: view.center.y * 1.7
            , width: 40, height: 40))
        face.backgroundColor = UIColor.yellow
        face.layer.cornerRadius = 20
        face.clipsToBounds = true
        view.addSubview(face)
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // create dynamic behavior for the cubes
        let brickDynamicBehavior = UIDynamicItemBehavior(items: magicCubes)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        // create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [face])
        ballDynamicBehavior.friction = 100000000
        ballDynamicBehavior.resistance = 100000000
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        allObjects.append(face)
        
        //creat collision behaviors so ball can bounce off other objects
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        if wave == 0 {
            waveIncrement()
            randomNumberOfBricks = Int(arc4random_uniform(UInt32(5)))
            if randomNumberOfBricks == 0 {
                randomNumberOfBricks += 1
            }
        }
        
        if isWaveEnded == true {
            waveIncrement()
            isWaveEnded = false
            randomNumberOfBricks = Int(arc4random_uniform(UInt32(5)))
            if randomNumberOfBricks == 0 {
                randomNumberOfBricks += 1
            }
        }
        
        // timers created
        if activateEasyMode == false {
            let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.update), userInfo: nil, repeats: true)
            if gameIsOver == true{
                timer.invalidate()
            }
        }
        if activateEasyMode == true {
            let timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.update2), userInfo: nil, repeats: true)
            if gameIsOver == true{
                timer2.invalidate()
            }
        }
        if activateHardMode == true {
            let timer3 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.update3), userInfo: nil, repeats: true)
            if gameIsOver == true{
                timer3.invalidate()
            }
        }
        
        // infinently loop the background music
        backgroundMusic = self.setupAudioPlayerWithFile("MagicBricks - InGameTheme", type:"mp3")
        backgroundMusic.play()
        backgroundMusic.numberOfLoops = -1
        
        // wave settup
        waveLabel.text = "Wave \(wave)"
        
        // insantiate random amount of rows of cubes between 0 and 4
        spawnMoreBlocks(randomNumberOfBricks)
        
        // fading label
        if waveComplete == true {
            counting = true
            waveLabel.isHidden = false
            time = 5
        }
        
                print("Highscore: \(higherScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)")
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        self.backgroundMusic.stop()
    }
    
    // updates counter
    func update() {
        time -= 1
        if time == 0 {
            waveLabel.isHidden = true
            counting = false
        }
    }
    
    // updates counter
    func update2() {
        time -= 1
        instantiateCube()
        if score >= 100 {
            instantiateCube()
        }
        if score >= 200 {
            instantiateCube()
        }
        if time == 0 {
            waveLabel.isHidden = true
        }
    }
    
    // updates counter
    func update3() {
        var easymode = true
        time -= 1
        if easymode == true {
            instantiateCube()
        }
        if time == 0 {
            waveLabel.isHidden = true
            counting = false
            easymode = false
        }
    }
    
    // Secret taping code
    @IBAction func tapCodeForLotsOfScore(_ sender: UITapGestureRecognizer) {
        timesTapped += 1
        if timesTapped == 7 {
            timesTapped = 0
            score += 7777
            moneyCheatActivatedLabel.isHidden = false
        }
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
    
    // pauses game
    @IBAction func pauseButton(_ sender: UIButton) {
        stopCubes()
        quitLabel.isHidden = false
        noButtonOutlet.isHidden = false
        yesButtonOutlet.isHidden = false
        waveLabel.isHidden = true
    }
    
    @IBAction func yesButtonAction(_ sender: UIButton) {
        backgroundMusic.stop()
    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {
        quitLabel.isHidden = true
        noButtonOutlet.isHidden = true
        yesButtonOutlet.isHidden = true
        time = 3
        update()
        if time == 0 {
            for block in magicCubes {
                pushCubes()
            }
        }
    }
    
    
    // check for all blocks hidden
    func addBlock(_ x: Int, y: Int, color: UIColor) {
        let block = UIView(frame: CGRect(x: (CGFloat)(x), y: (CGFloat)(y), width: 20, height: 30))
        block.backgroundColor = color
        view.addSubview(block)
        magicCubes.append(block)
        allObjects.append(block)
        collisionBehavior.addItem(block)
        //blocks = 0
        print(blocks)
    }

    // creates the rows of cubes
    func instantiateCubes() {
        // Set up bricks
        let width = (Int)(view.bounds.size.width - 41)
        let xOffset = ((Int)(view.bounds.size.width) % 42) / 2
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  0, color: UIColor.yellow)}
        pushCubes()
    }
    
    // creates a cube
    func instantiateCube() {
        
        let x = Int(CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (view.bounds.size.width - 20) + 10)
        addBlock(x, y:  0, color: UIColor.yellow)
        pushCubes()
    }
    
    // updates wave
    func waveIncrement() {
        
        print("Next Wave of blocks")
        waveLabel.isHidden = false
        wave += 1
        waveLabel.text = "Wave \(wave)"
        
        dificultyLevel.backgroundColor = UIColor.green
        if wave <= 2 && wave < 5 {
            dificultyLevel.backgroundColor = UIColor.green
        }
        else if wave <= 5 && wave < 10{
            dificultyLevel.backgroundColor = UIColor.yellow
        }
        else if wave <= 10 && wave < 20{
            dificultyLevel.backgroundColor = UIColor.orange
        }
        else if wave >= 20 {
            dificultyLevel.backgroundColor = UIColor.red
        }

    }
    
    // collision behavior deligate method (with boundary)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        var blocksHidden = 0
        for block in magicCubes {
            if item.isEqual(block) && p.y > face.center.y {
                block.isHidden = true
                collisionBehavior.removeItem(block)
                blocksHidden += 1
                blocks += 1
                print(blocks)
                if blocksHidden == magicCubes.count {
                    isWaveEnded = true
                }
            }
        }
        
        // detects if all blocks are gone on the screen and triggers game over function
        if blocks >= 3 {
            collisionBehavior.removeItem(face)
            face.removeFromSuperview()
            face.isHidden = true
            gameOver()
        }
    }
    
    // collision behavior delegate method (with another object)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        var hiddenBlockCount = 0
        for block in magicCubes {
            
            if item1.isEqual(face) && item2.isEqual(block) {
                block.isHidden = true
                if x2 == true {
                    score += 2
                }
                else {
                    score += 1
                }
                scoreLabel.text = "Cubes Eaten: \(score)"
                collisionBehavior.removeItem(block)
            }
            
            if block.isHidden == true {
                hiddenBlockCount += 1
            }
        }
        
        // moves to next wave & speeds up the blocks
        if hiddenBlockCount == magicCubes.count {
            isWaveEnded = true
            randomNumberOfBricks = Int(arc4random_uniform(4) + 1)
            if randomNumberOfBricks == 0
            {
                randomNumberOfBricks = 1
                print("Was 0! now one!")
            }
            if activateEasyMode != true {
                spawnMoreBlocks(randomNumberOfBricks)
                if score <= 20 && score > 50 {
                    brickSpeed += 0.03
                }
                else if score <= 50 && score > 80 {
                    brickSpeed += 0.04
                }
            }
            else {
                instantiateCube()
            }
        }
    }
    
    @IBAction func moveFaceGesture(_ sender: UIPanGestureRecognizer) {
        let panGesture = sender.location(in: view)
        face.center = CGPoint(x: panGesture.x, y: face.center.y)
        dynamicAnimator.updateItem(usingCurrentState: face)
        if infoLabel.isHidden == false {
            infoLabel.isHidden = true
        }
    }
    
    func pushCubes() {
        // create push behavior to get the cubes moving
        let pushBehavior = UIPushBehavior(items: magicCubes, mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0, dy: 1)
        pushBehavior.magnitude = CGFloat(brickSpeed)
        dynamicAnimator.addBehavior(pushBehavior)
    }
    
    func stopCubes() {
        // create push behavior to get the cubes moving
        let pushBehavior = UIPushBehavior(items: magicCubes, mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0, dy: 1)
        pushBehavior.magnitude = 0
        dynamicAnimator.addBehavior(pushBehavior)
        
        // create dynamic behavior for the cubes
        let brickDynamicBehavior = UIDynamicItemBehavior(items: magicCubes)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
    }
    
    // Creates the waves of blocks
    func spawnMoreBlocks(_ numOfBricks: Int) {
        var numOfBricks = numOfBricks
        if numOfBricks < 1 {
            numOfBricks = Int(arc4random_uniform(UInt32(5)))
        }
        blocks = 0
        blocks = numOfBricks - 2
        while numOfBricks > 0 {
            if activateEasyMode == true
            {
                instantiateCube()
            }
            else {
                instantiateCubes()
            }
            numOfBricks -= 1
            if numOfBricks <= 0 {
                isWaveEnded = true
                waveIncrement()
            }
        }
    }
    
    func startAlertActions() {
        let alert = UIAlertController(title: "Paused", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let resumeAction = UIAlertAction(title: "Resume", style: UIAlertActionStyle.default) { (action) -> Void in
            // create push behavior to get the cubes moving
            let pushBehavior = UIPushBehavior(items: self.magicCubes, mode: .instantaneous)
            pushBehavior.pushDirection = CGVector(dx: 0, dy: 1)
            pushBehavior.magnitude = CGFloat(self.brickSpeed)
            self.dynamicAnimator.addBehavior(pushBehavior)
            
            // create dynamic behavior for the cubes
            let brickDynamicBehavior = UIDynamicItemBehavior(items: self.magicCubes)
            brickDynamicBehavior.density = 10000
            brickDynamicBehavior.resistance = 100
            brickDynamicBehavior.allowsRotation = false
            self.dynamicAnimator.addBehavior(brickDynamicBehavior)
            
        }
        
        alert.addAction(resumeAction)
        
        self.present(alert, animated: true, completion: nil)
        
        let quitAction = UIAlertAction(title: "Quit", style: UIAlertActionStyle.destructive) { (action) -> Void in
            if let resultController = self.storyboard?.instantiateViewController(withIdentifier: "StartVC") as? ViewController {
                self.present(resultController, animated: true, completion: nil)
            }
            self.backgroundMusic.stop()
        }
        
        alert.addAction(quitAction)
    }
    
    func gameOver() {
        scoreLabel.isHidden = true
        pauseButtonOutlet.isHidden = true
        dificultyLevel.isHidden = true
        infoLabel.isHidden = false
        infoLabel.text = "Cubes Eaten: \(score)"
        quitLabel.isHidden = false
        quitLabel.text = "Game Over!"
        print("Game Over!")
        nextButtonOutlet.isHidden = false
        waveLabel.isHidden = true
        moneyCheatActivatedLabel.isHidden = true
        
        //hide pause button
        waveLabel.text = "Score: \(score)"
        yesButtonOutlet.isHidden = true
        noButtonOutlet.isHidden = true
        gameIsOver = true
        
        // saves high score
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(higherScore, forKey: "highScore")
        defaults.set(unlockEasyMode, forKey: "unlockEasy")
        defaults.set(removeAds, forKey: "removeAds")
        defaults.set(activateX2, forKey: "X2")
        defaults.synchronize()
        print(higherScore)
        
        if score > higherScore {
            higherScore = score
            highScoreLabel.text = "Most Cubes Eaten: \(score)"
        }
    }
    
    //----------( Passes the score to other ViewControllers )----------\\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameOverVC" {
            let svc = segue.destination as! GameOverViewController
            svc.currentScore = score
            svc.highScore = higherScore
            svc.removeAds = removeAds
            svc.unlockEasyMode = unlockEasyMode
            svc.activateEasyMode = activateEasyMode
            svc.activateHardMode = activateHardMode
            svc.x2 = x2
            svc.selectButtonColor = selectButtonColor
            svc.activateX2 = activateX2
        }
        if segue.identifier == "StartVC" {
            let svc = segue.destination as! ViewController
            svc.highScore = higherScore
            svc.removeAds = removeAds
            svc.unlockEasyMode = unlockEasyMode
            svc.activateEasyMode = activateEasyMode
            svc.activateHardMode = activateHardMode
            svc.x2 = x2
            svc.selectButtonColor = selectButtonColor
            svc.activateX2 = activateX2
        }
    }
    
}
